import 'dart:math';
import 'package:dio/dio.dart';

import 'models.dart';

class ApiClient {
  final Dio _dio;

  ApiClient({
    required String baseUrl,
  }) : _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 12),
          receiveTimeout: const Duration(seconds: 25),
        ));

  /// POST /v1/topics/suggest
  /// Request:
  ///   { "promptText": "...", "attachments": [{id, base64}, ...], "settings": {...} }
  /// Response:
  ///   { "topics": [{...Topic fields...}, ...] }
  Future<List<Topic>> suggestTopics({
    required String promptText,
    required List<PromptAttachment> attachments,
    required GlobalSettings settings,
  }) async {
    final payload = {
      'promptText': promptText,
      'attachments': attachments.map((a) => a.toJson()).toList(),
      'settings': settings.toJson(),
    };

    try {
      final res = await _dio.post('/v1/topics/suggest', data: payload);
      final data = res.data as Map<String, dynamic>;
      final list = (data['topics'] as List?) ?? const [];
      return list
          .whereType<Map>()
          .map((e) => Topic.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return _mockTopics(promptText.isEmpty ? 'Trending' : promptText);
    }
  }

  /// POST /v1/story/overview
  /// Request: { "topic": {...}, "settings": {...} }
  /// Response: { "title": "...", "overview": "...", "beats": ["...", ...] }
  Future<StoryOverview> generateStoryOverview({
    required Topic topic,
    required GlobalSettings settings,
  }) async {
    final payload = {
      'topic': topic.toJson(),
      'settings': settings.toJson(),
    };
    try {
      final res = await _dio.post('/v1/story/overview', data: payload);
      return StoryOverview.fromJson(res.data as Map<String, dynamic>);
    } catch (_) {
      return _mockStory(topic, settings);
    }
  }

  /// POST /v1/posts/generate
  /// Request: { "topic": {...}, "story": {...}, "settings": {...} }
  /// Response: { "youtube": "...", "tiktok": "...", "instagram": "..." }
  Future<GeneratedOutputs> generatePosts({
    required Topic topic,
    required StoryOverview story,
    required GlobalSettings settings,
  }) async {
    final payload = {
      'topic': topic.toJson(),
      'story': story.toJson(),
      'settings': settings.toJson(),
    };
    try {
      final res = await _dio.post('/v1/posts/generate', data: payload);
      return GeneratedOutputs.fromJson(res.data as Map<String, dynamic>);
    } catch (_) {
      return _mockPosts(topic, story, settings);
    }
  }

  /// GET /v1/history?youtube=...&tiktok=...&instagram=...
  /// Response: { "history": [ ...HistoryItem... ] }
  Future<List<HistoryItem>> fetchHistoryByUsernames({
    required String youtube,
    required String tiktok,
    required String instagram,
  }) async {
    try {
      final res = await _dio.get('/v1/history', queryParameters: {
        'youtube': youtube,
        'tiktok': tiktok,
        'instagram': instagram,
      });
      final data = res.data as Map<String, dynamic>;
      final list = (data['history'] as List?) ?? const [];
      return list
          .whereType<Map>()
          .map((e) => HistoryItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  List<Topic> _mockTopics(String seed) {
    final r = Random(seed.hashCode);
    final picks = <String>[
      'AI workflow for creators',
      '3 hooks that increase retention',
      'How to validate ideas fast',
      'Editing checklist that saves hours',
      'Mistakes when using AI for content',
      'Content repurposing system',
      'From long video to short clips',
      'Instagram growth with reels',
    ]..shuffle(r);

    return List.generate(10, (i) {
      final title = picks[i % picks.length];
      return Topic(
        id: 't_${seed.hashCode}_$i',
        title: title,
        hook: 'Stop doing X — do this instead (${i + 1}).',
        angle: 'Practical, step-by-step, minimal fluff.',
        keyPoints: const [
          'Explain the core idea in 1 sentence',
          'Give a concrete example',
          'Add a common pitfall + fix',
          'End with a clear CTA',
        ],
      );
    });
  }

  StoryOverview _mockStory(Topic topic, GlobalSettings settings) {
    final overview = 'Overview story for: ${topic.title}\n\n'
        'This piece follows a simple narrative: a common pain → a surprise insight → '
        'a concrete, repeatable system → a clear payoff.\n\n'
        'Tone: ${settings.tone} • Language: ${settings.language} • Length: ${settings.length}';
    return StoryOverview(
      title: topic.title,
      overview: overview,
      beats: const [
        'Cold open: call out the pain in one sentence',
        'Reveal: the 1 idea that changes the approach',
        'Steps: 3 actionable moves viewers can copy',
        'Pitfall: what people do wrong + fix',
        'Payoff: what improves and how fast',
        'CTA: ask for comment/save/follow',
      ],
    );
  }

  GeneratedOutputs _mockPosts(Topic topic, StoryOverview story, GlobalSettings settings) {
    final beats = story.beats.map((e) => '• $e').join('\n');
    return GeneratedOutputs(
      youtube: 'YouTube Script\n\n${story.overview}\n\nBeats:\n$beats\n\nCTA: Subscribe + comment “SYSTEM”.',
      tiktok: 'TikTok Scenario (20–35s)\n\n0–2s: ${topic.hook}\n'
          '2–18s: 3 steps from the story\n'
          '18–28s: Pitfall + fix\n'
          '28–35s: CTA (follow + save)\n\nNotes: ${settings.tone}',
      instagram: 'Instagram Caption\n\n${topic.title}\n\n'
          '${story.beats.take(5).map((e) => '— $e').join('\n')}\n\n'
          '${settings.includeHashtags ? '#content #creator #ai' : ''}'
          '${settings.includeEmojis ? ' ✨🚀' : ''}',
    );
  }
}
