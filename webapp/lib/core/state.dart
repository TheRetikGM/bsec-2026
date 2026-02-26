import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:ai_redakcia_frontend/models/history_models/history_model.dart';
import 'package:ai_redakcia_frontend/models/platform_stories_model.dart';
import 'package:ai_redakcia_frontend/models/profile_model.dart';
import 'package:ai_redakcia_frontend/models/story_model.dart';
import 'package:ai_redakcia_frontend/models/topic_model.dart';
import 'package:ai_redakcia_frontend/services/story_gen_service.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_clipboard/super_clipboard.dart';

import 'models.dart';

const _kHistoryKey = 'history_items_v3';

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
        length: 'medium',
      );

  void update(GlobalSettings s) => state = s;
}

/// User characteristics text returned by history upload.
final userCharacteristicsProvider =
    AsyncNotifierProvider<UserCharacteristicsNotifier, String?>(UserCharacteristicsNotifier.new);

class UserCharacteristicsNotifier extends AsyncNotifier<String?> {
  static const _kKey = 'user_characteristics_text';

  @override
  Future<String?> build() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kKey);
    return (raw == null || raw.trim().isEmpty) ? null : raw;
  }

  Future<void> clear() async => set(null);

  Future<void> set(String? text) async {
    state = AsyncData(text);
    final prefs = await SharedPreferences.getInstance();
    if (text == null || text.trim().isEmpty) {
      await prefs.remove(_kKey);
    } else {
      await prefs.setString(_kKey, text);
    }
  }

  /// Calls the API to analyze the given history list and stores the returned text.
  Future<void> analyzeFromHistory(List<HistoryModel> histories) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final text = await ref.read(storyGenServiceProvider).submitHistory(histories);
      final normalized = (text ?? '').trim();
      // Persist only on success.
      final prefs = await SharedPreferences.getInstance();
      if (normalized.isEmpty) {
        await prefs.remove(_kKey);
        return null;
      }
      await prefs.setString(_kKey, normalized);
      return normalized;
    });
  }
}

final promptAttachmentsProvider =
    NotifierProvider<PromptAttachmentsNotifier, List<PromptAttachment>>(
        PromptAttachmentsNotifier.new);

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

/// Generated topic profiles (ProfileModel list)
final topicsProvider =
    AsyncNotifierProvider<TopicsNotifier, List<ProfileModel>>(TopicsNotifier.new);

class TopicsNotifier extends AsyncNotifier<List<ProfileModel>> {
  @override
  Future<List<ProfileModel>> build() async => const [];

  Future<void> generateFromPrompt() async {
    final text = ref.read(promptTextProvider);
    final topic = TopicModel(prompt: text);

    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(storyGenServiceProvider).generateTopics(topic));
  }

  void clear() => state = const AsyncData([]);
}

/// Selected topic index in the generated list
final selectedTopicIdProvider =
    NotifierProvider<SelectedTopicIndexNotifier, int?>(SelectedTopicIndexNotifier.new);

class SelectedTopicIndexNotifier extends Notifier<int?> {
  @override
  int? build() => null;

  void set(int? v) => state = v;
}

/// Expanded (dropdown open) topic index
final expandedTopicIdProvider =
    NotifierProvider<ExpandedTopicIndexNotifier, int?>(ExpandedTopicIndexNotifier.new);

class ExpandedTopicIndexNotifier extends Notifier<int?> {
  @override
  int? build() => null;

  void toggle(int index) => state = (state == index) ? null : index;

  void close() => state = null;
}

/// Currently edited topic profile (ProfileModel)
final editableTopicProvider =
    NotifierProvider<EditableProfileNotifier, ProfileModel?>(EditableProfileNotifier.new);

class EditableProfileNotifier extends Notifier<ProfileModel?> {
  @override
  ProfileModel? build() => null;

  void set(ProfileModel? p) => state = p;
}

/// Story overview (single text for now)
final storyProvider = AsyncNotifierProvider<StoryNotifier, StoryModel?>(StoryNotifier.new);

class StoryNotifier extends AsyncNotifier<StoryModel?> {
  @override
  Future<StoryModel?> build() async => null;

  Future<void> generate() async {
    final profile = ref.read(editableTopicProvider);
    if (profile == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(storyGenServiceProvider).writeStory(profile));
  }

  void clear() => state = const AsyncData(null);
}

/// Platform posts/scenarios
final postsProvider =
    AsyncNotifierProvider<PostsNotifier, PlatformStoriesModel?>(PostsNotifier.new);

class PostsNotifier extends AsyncNotifier<PlatformStoriesModel?> {
  @override
  Future<PlatformStoriesModel?> build() async => null;

  Future<void> generate() async {
    final story = ref.read(storyProvider).value;
    if (story == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(
        () => ref.read(storyGenServiceProvider).createPlatformStories(story));
  }

  void clear() => state = const AsyncData(null);
}

final historyProvider =
    AsyncNotifierProvider<HistoryNotifier, List<HistoryModel>>(HistoryNotifier.new);

class HistoryNotifier extends AsyncNotifier<List<HistoryModel>> {
  static const _kHistoryKey = 'history_data';

  @override
  Future<List<HistoryModel>> build() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kHistoryKey);

    if (raw == null || raw.trim().isEmpty) return const [];

    try {
      final List<dynamic> arr = jsonDecode(raw);
      return arr.map((e) => HistoryModel.fromJson(Map<String, dynamic>.from(e))).toList()
        // Sort by date descending (newest first)
        ..sort((a, b) => b.date.compareTo(a.date));
    } catch (e) {
      // In a production app, you might want to log this error
      return const [];
    }
  }

  /// Adds a single HistoryModel to the state
  Future<void> add(HistoryModel item) async {
    final existing = state.value ?? <HistoryModel>[];
    final next = [item, ...existing]..sort((a, b) => b.date.compareTo(a.date));

    state = AsyncData(next);
    await _persist(next);
  }

  /// Merges a list of HistoryModels, overwriting existing IDs
  Future<void> mergeMany(List<HistoryModel> incoming) async {
    final existing = state.value ?? <HistoryModel>[];

    // Map items by ID for easy lookup and replacement
    final byId = <int, HistoryModel>{for (final e in existing) e.id: e};

    // Merge incoming items (overwrites existing items with same ID)
    for (final i in incoming) {
      byId[i.id] = i;
    }

    final next = byId.values.toList()..sort((a, b) => b.date.compareTo(a.date));

    state = AsyncData(next);
    await _persist(next);
  }

  /// Clears all history
  Future<void> clear() async {
    state = const AsyncData([]);
    await _persist(const []);
  }

  /// Imports from a JSON file and merges with existing state
  Future<void> importFromJsonFile() async {
    // Note: Ensure openFile and XTypeGroup are imported from file_selector or similar
    final file = await openFile(
      acceptedTypeGroups: [
        const XTypeGroup(label: 'JSON', extensions: ['json'])
      ],
    );
    if (file == null) return;

    try {
      final text = await file.readAsString();
      final List<dynamic> arr = jsonDecode(text);
      final items = arr.map((e) => HistoryModel.fromJson(Map<String, dynamic>.from(e))).toList();

      await mergeMany(items);
    } catch (e) {
      // Handle or log parsing errors
    }
  }

  /// Internal method to save to SharedPreferences
  Future<void> _persist(List<HistoryModel> items) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(items.map((e) => e.toJson()).toList());
    await prefs.setString(_kHistoryKey, encoded);
  }
}

/// Clipboard paste helper (text + images)
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
