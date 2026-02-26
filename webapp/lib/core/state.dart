import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_clipboard/super_clipboard.dart';

import 'api_client.dart';
import 'models.dart';

const _kBaseUrl = 'http://localhost:8080'; // change to your backend
const _kHistoryKey = 'history_items_v2';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient(baseUrl: _kBaseUrl));

// Pages: 0 Start -> 1 Topics -> 2 Story -> 3 Posts
final pageIndexProvider = NotifierProvider<PageIndexNotifier, int>(PageIndexNotifier.new);
class PageIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;
  void set(int v) => state = v;
}

final promptTextProvider = NotifierProvider<PromptTextNotifier, String>(PromptTextNotifier.new);
class PromptTextNotifier extends Notifier<String> {
  @override
  String build() => '';
  void set(String v) => state = v;
}

final settingsProvider = NotifierProvider<SettingsNotifier, GlobalSettings>(SettingsNotifier.new);
class SettingsNotifier extends Notifier<GlobalSettings> {
  @override
  GlobalSettings build() => const GlobalSettings(
        language: 'en',
        tone: 'professional',
        length: 'medium',
        includeHashtags: true,
        includeEmojis: false,
      );
  void update(GlobalSettings s) => state = s;
}

final promptAttachmentsProvider =
    NotifierProvider<PromptAttachmentsNotifier, List<PromptAttachment>>(PromptAttachmentsNotifier.new);

class PromptAttachmentsNotifier extends Notifier<List<PromptAttachment>> {
  @override
  List<PromptAttachment> build() => const [];

  void addBytes(List<int> bytes) {
    final id = 'img_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(9999)}';
    state = [...state, PromptAttachment(id: id, bytes: Uint8List.fromList(bytes))];
  }

  void remove(String id) {
    state = state.where((e) => e.id != id).toList(growable: false);
  }

  void clear() => state = const [];
}

final topicsProvider = AsyncNotifierProvider<TopicsNotifier, List<Topic>>(TopicsNotifier.new);

class TopicsNotifier extends AsyncNotifier<List<Topic>> {
  @override
  Future<List<Topic>> build() async => const [];

  Future<void> generateFromPrompt() async {
    final api = ref.read(apiClientProvider);
    final text = ref.read(promptTextProvider);
    final attachments = ref.read(promptAttachmentsProvider);
    final settings = ref.read(settingsProvider);

    state = const AsyncLoading();
    state = await AsyncValue.guard(() => api.suggestTopics(
          promptText: text.trim(),
          attachments: attachments,
          settings: settings,
        ));
  }

  void clear() => state = const AsyncData([]);
}

final selectedTopicIdProvider = NotifierProvider<SelectedTopicIdNotifier, String?>(SelectedTopicIdNotifier.new);
class SelectedTopicIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void set(String? v) => state = v;
}

final expandedTopicIdProvider = NotifierProvider<ExpandedTopicIdNotifier, String?>(ExpandedTopicIdNotifier.new);
class ExpandedTopicIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void toggle(String id) => state = (state == id) ? null : id;
  void close() => state = null;
}

final editableTopicProvider = NotifierProvider<EditableTopicNotifier, Topic?>(EditableTopicNotifier.new);
class EditableTopicNotifier extends Notifier<Topic?> {
  @override
  Topic? build() => null;
  void set(Topic? t) => state = t;
}

final storyProvider = AsyncNotifierProvider<StoryNotifier, StoryOverview?>(StoryNotifier.new);
class StoryNotifier extends AsyncNotifier<StoryOverview?> {
  @override
  Future<StoryOverview?> build() async => null;

  Future<void> generate() async {
    final api = ref.read(apiClientProvider);
    final topic = ref.read(editableTopicProvider);
    final settings = ref.read(settingsProvider);
    if (topic == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() => api.generateStoryOverview(topic: topic, settings: settings));
  }

  void clear() => state = const AsyncData(null);
}

final postsProvider = AsyncNotifierProvider<PostsNotifier, GeneratedOutputs?>(PostsNotifier.new);
class PostsNotifier extends AsyncNotifier<GeneratedOutputs?> {
  @override
  Future<GeneratedOutputs?> build() async => null;

  Future<void> generate() async {
    final api = ref.read(apiClientProvider);
    final topic = ref.read(editableTopicProvider);
    final story = ref.read(storyProvider).value;
    final settings = ref.read(settingsProvider);
    if (topic == null || story == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() => api.generatePosts(topic: topic, story: story, settings: settings));
  }

  void clear() => state = const AsyncData(null);
}

final historyProvider = AsyncNotifierProvider<HistoryNotifier, List<HistoryItem>>(HistoryNotifier.new);
class HistoryNotifier extends AsyncNotifier<List<HistoryItem>> {
  @override
  Future<List<HistoryItem>> build() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kHistoryKey);
    if (raw == null || raw.trim().isEmpty) return const [];
    try {
      final arr = jsonDecode(raw) as List;
      final items = arr
          .whereType<Map>()
          .map((e) => HistoryItem.fromJson(Map<String, dynamic>.from(e)))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return items;
    } catch (_) {
      return const [];
    }
  }

  Future<void> add(HistoryItem item) async {
    final existing = state.value ?? const <HistoryItem>[];
    final next = [item, ...existing]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    state = AsyncData(next);
    await _persist(next);
  }

  Future<void> mergeMany(List<HistoryItem> incoming) async {
    final existing = state.value ?? const <HistoryItem>[];
    final byId = <String, HistoryItem>{for (final e in existing) e.id: e};
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
      acceptedTypeGroups: [const XTypeGroup(extensions: ['json'])],
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
    final items = state.value ?? const <HistoryItem>[];
    final jsonText = historyToPrettyJson(items);

    final location = await getSaveLocation(
      suggestedName: 'history.json',
      acceptedTypeGroups: [const XTypeGroup(extensions: ['json'])],
    );
    if (location == null) return;

    final out = XFile.fromData(
      utf8.encode(jsonText),
      mimeType: 'application/json',
      name: 'history.json',
    );
    await out.saveTo(location.path);
  }

  Future<void> _persist(List<HistoryItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(items.map((e) => e.toJson()).toList());
    await prefs.setString(_kHistoryKey, raw);
  }
}

Future<({String? text, List<Uint8List> images})> readClipboardTextAndImages() async {
  final clipboard = SystemClipboard.instance;
  if (clipboard == null) return (text: null, images: const <Uint8List>[]);

  final reader = await clipboard.read();
  String? text;
  final images = <Uint8List>[];

  for (final item in reader.items) {
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
