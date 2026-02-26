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
  ///   { "promptText": "...", "attachments": [{id, base64}, ...] }
  /// Response:
  ///   { "topics": [{...Topic fields...}, ...] }
  Future<List<Topic>> suggestTopics({
    required String promptText,
    required List<PromptAttachment> attachments,
  }) async {
    final payload = {
      'promptText': promptText,
      'attachments': attachments.map((a) => a.toJson()).toList(),
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
      // Fallback: local mock (so UI works immediately)
      return _mockTopics(promptText.isEmpty ? 'Trending' : promptText);
    }
  }

  /// POST /v1/content/generate
  /// Request: { "topic": { ... } }
  /// Response: { "youtube": "...", "tiktok": "...", "telegram": "..." }
  Future<GeneratedOutputs> generateOutputs({required Topic topic}) async {
    final payload = {'topic': topic.toJson()};
    try {
      final res = await _dio.post('/v1/content/generate', data: payload);
      return GeneratedOutputs.fromJson(res.data as Map<String, dynamic>);
    } catch (_) {
      // Fallback mock
      return GeneratedOutputs(
        youtube:
            'YouTube Script\n\nHook: ${topic.hook}\n\n${topic.keyPoints.map((e) => '• $e').join('\n')}\n\nCTA: Subscribe.',
        tiktok:
            'TikTok Scenario\n\n0-2s: ${topic.hook}\n2-12s: ${topic.keyPoints.take(3).join(' / ')}\n12-18s: Punchline + CTA',
        telegram:
            'Telegram Post\n\n${topic.title}\n\n${topic.keyPoints.map((e) => '— $e').join('\n')}\n\nReply with “MORE” for part 2.',
      );
    }
  }

  /// GET /v1/history?youtube=...&tiktok=...&telegram=...
  /// Response: { "history": [ ...HistoryItem... ] }
  Future<List<HistoryItem>> fetchHistoryByUsernames({
    required String youtube,
    required String tiktok,
    required String telegram,
  }) async {
    try {
      final res = await _dio.get('/v1/history', queryParameters: {
        'youtube': youtube,
        'tiktok': tiktok,
        'telegram': telegram,
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
      'Telegram channel growth tactics',
    ]..shuffle(r);

    return List.generate(8, (i) {
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
}
