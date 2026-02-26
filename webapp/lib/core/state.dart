import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_clipboard/super_clipboard.dart';

import 'api_client.dart';
import 'models.dart';

const _kBaseUrl = 'http://localhost:8080'; // change to your backend
const _kHistoryKey = 'history_items_v1';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient(baseUrl: _kBaseUrl));

final pageIndexProvider = StateProvider<int>((ref) => 0); // 0=start, 1=topics, 2=results

final promptTextProvider = StateProvider<String>((ref) => '');
final promptAttachmentsProvider =
    StateNotifierProvider<PromptAttachmentsNotifier, List<PromptAttachment>>(
  (ref) => PromptAttachmentsNotifier(),
);

class PromptAttachmentsNotifier extends StateNotifier<List<PromptAttachment>> {
  PromptAttachmentsNotifier() : super(const []);

  void addBytes(List<int> bytes) {
    final id = 'img_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(9999)}';
    state = [...state, PromptAttachment(id: id, bytes: Uint8List.fromList(bytes))];
  }

  void remove(String id) {
    state = state.where((e) => e.id != id).toList(growable: false);
  }

  void clear() => state = const [];
}

final globalSettingsProvider =
    NotifierProvider<GlobalSettingsNotifier, GlobalSettings>(GlobalSettingsNotifier.new);

class GlobalSettingsNotifier extends Notifier<GlobalSettings> {
  @override
  GlobalSettings build() => const GlobalSettings(
        language: 'en',
        tone: 'professional',
        length: 'medium',
        includeHashtags: true,
        includeEmojis: false,
      );
}

final topicsProvider = AsyncNotifierProvider<TopicsNotifier, List<Topic>>(TopicsNotifier.new);

class TopicsNotifier extends AsyncNotifier<List<Topic>> {
  @override
  Future<List<Topic>> build() async => const [];

  Future<void> generateFromPrompt() async {
    final api = ref.read(apiClientProvider);
    final text = ref.read(promptTextProvider);
    final attachments = ref.read(promptAttachmentsProvider);

    state = const AsyncLoading();
    final settings = ref.read(globalSettingsProvider);
    state = await AsyncValue.guard(() => api.suggestTopics(
          promptText: text.trim(),
          attachments: attachments,
          settings: settings,
        ));
  }

  void clear() => state = const AsyncData([]);
}

final selectedTopicIdProvider = StateProvider<String?>((ref) => null);

Topic? findSelectedTopic(WidgetRef ref, List<Topic> topics) {
  final id = ref.watch(selectedTopicIdProvider);
  if (id == null) return null;
  for (final t in topics) {
    if (t.id == id) return t;
  }
  return null;
}

final editableTopicProvider = StateProvider<Topic?>((ref) => null);

final outputsProvider =
    AsyncNotifierProvider<OutputsNotifier, GeneratedOutputs?>(OutputsNotifier.new);

class OutputsNotifier extends AsyncNotifier<GeneratedOutputs?> {
  @override
  Future<GeneratedOutputs?> build() async => null;

  Future<void> generate() async {
    final api = ref.read(apiClientProvider);
    final topic = ref.read(editableTopicProvider);
    if (topic == null) return;

    state = const AsyncLoading();
    final settings = ref.read(globalSettingsProvider);
    state = await AsyncValue.guard(() => api.generateOutputs(topic: topic, settings: settings));
  }

  void clear() => state = const AsyncData(null);
}

final historyProvider =
    AsyncNotifierProvider<HistoryNotifier, List<HistoryItem>>(HistoryNotifier.new);

class HistoryNotifier extends AsyncNotifier<List<HistoryItem>> {
  @override
  Future<List<HistoryItem>> build() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kHistoryKey);
    if (raw == null || raw.trim().isEmpty) return const [];
    try {
      final arr = jsonDecode(raw) as List;
      return arr
          .whereType<Map>()
          .map((e) => HistoryItem.fromJson(Map<String, dynamic>.from(e)))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (_) {
      return const [];
    }
  }

  Future<void> add(HistoryItem item) async {
    final next = [item, ...state.value ?? const <HistoryItem>[]]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    state = AsyncValue.data(next);
    await _persist(next);
  }

  Future<void> mergeMany(List<HistoryItem> incoming) async {
    final existing = state;
    final byId = <String, HistoryItem>{for (final e in existing.value ?? []) e.id: e};
    for (final i in incoming) {
      byId[i.id] = i;
    }
    final next = byId.values.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    state = AsyncData(next);
    await _persist(next);
  }

  Future<void> clear() async {
    state = const AsyncData([]);
    await _persist(const []);
  }

  Future<void> importFromJsonFile() async {
    final file = await openFile(
      acceptedTypeGroups: [
        const XTypeGroup(extensions: ['json'])
      ],
    );
    if (file == null) return;

    final text = await file.readAsString();
    final arr = jsonDecode(text) as List;
    final items = arr
        .whereType<Map>()
        .map((e) => HistoryItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    await mergeMany(items);
  }

  Future<void> exportToJsonFile() async {
    final items = state;
    final jsonText = historyToPrettyJson(items.value ?? []);

    // final path = await getSavePath(suggestedName: 'history.json');
    // if (path == null) return;

    // final out = XFile.fromData(
    //   utf8.encode(jsonText),
    //   mimeType: 'application/json',
    //   name: 'history.json',
    // );
    // await out.saveTo(path);
  }

  Future<void> _persist(List<HistoryItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(items.map((e) => e.toJson()).toList());
    await prefs.setString(_kHistoryKey, raw);
  }
}

/// Clipboard paste helper (text + images) using super_clipboard.
Future<({String? text, List<Uint8List> images})> readClipboardTextAndImages() async {
  final clipboard = SystemClipboard.instance;
  if (clipboard == null) return (text: null, images: const <Uint8List>[]);

  final reader = await clipboard.read();
  String? text;
  final images = <Uint8List>[];

  for (final item in reader.items) {
    // Prefer images first
    if (item.canProvide(Formats.png)) {
      final completer = Completer<Uint8List?>();
      item.getFile(
        Formats.png,
        (file) async {
          try {
            completer.complete(await file.readAll());
          } catch (_) {
            completer.complete(null);
          }
        },
        onError: (_) => completer.complete(null),
      );
      final bytes = await completer.future;
      if (bytes != null && bytes.isNotEmpty) images.add(bytes);
    }

    // Then text
    if (text == null && item.canProvide(Formats.plainText)) {
      try {
        text = await item.readValue(Formats.plainText);
      } catch (_) {
        // ignore
      }
    }
  }

  return (text: text, images: images);
}


