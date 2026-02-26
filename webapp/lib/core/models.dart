import 'dart:convert';
import 'dart:typed_data';

import 'package:ai_redakcia_frontend/models/platform_stories_model.dart';
import 'package:ai_redakcia_frontend/models/story_model.dart';

class GlobalSettings {
  final String language;
  final String tone;
  final String length; // short/medium/long
  final bool includeHashtags;
  final bool includeEmojis;

  const GlobalSettings({
    required this.language,
    required this.tone,
    required this.length,
    required this.includeHashtags,
    required this.includeEmojis,
  });

  GlobalSettings copyWith({
    String? language,
    String? tone,
    String? length,
    bool? includeHashtags,
    bool? includeEmojis,
  }) {
    return GlobalSettings(
      language: language ?? this.language,
      tone: tone ?? this.tone,
      length: length ?? this.length,
      includeHashtags: includeHashtags ?? this.includeHashtags,
      includeEmojis: includeEmojis ?? this.includeEmojis,
    );
  }

  Map<String, dynamic> toJson() => {
        'language': language,
        'tone': tone,
        'length': length,
        'includeHashtags': includeHashtags,
        'includeEmojis': includeEmojis,
      };

  static GlobalSettings fromJson(Map<String, dynamic> json) => GlobalSettings(
        language: (json['language'] ?? 'en').toString(),
        tone: (json['tone'] ?? 'professional').toString(),
        length: (json['length'] ?? 'medium').toString(),
        includeHashtags: json['includeHashtags'] == true,
        includeEmojis: json['includeEmojis'] == true,
      );
}

class PromptAttachment {
  final String id;
  final Uint8List bytes;

  const PromptAttachment({required this.id, required this.bytes});

  Map<String, dynamic> toJson() => {
        'id': id,
        'base64': base64Encode(bytes),
      };

  static PromptAttachment fromJson(Map<String, dynamic> json) => PromptAttachment(
        id: (json['id'] ?? '').toString(),
        bytes: base64Decode((json['base64'] ?? '').toString()),
      );
}

class HistoryItem {
  final String id;
  final DateTime createdAt;
  final String promptText;
  final int attachmentCount;
  final String selectedTopicTitle;
  final StoryModel? story;
  final PlatformStoriesModel? platform_stories;

  const HistoryItem({
    required this.id,
    required this.createdAt,
    required this.promptText,
    required this.attachmentCount,
    required this.selectedTopicTitle,
    required this.platform_stories,
    this.story,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'createdAt': createdAt.toIso8601String(),
        'promptText': promptText,
        'attachmentCount': attachmentCount,
        'selectedTopicTitle': selectedTopicTitle,
        'story': story?.toJson(),
        'outputs': platform_stories?.toJson(),
      };

  static HistoryItem fromJson(Map<String, dynamic> json) => HistoryItem(
        id: (json['id'] ?? '').toString(),
        createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()) ??
            DateTime.fromMillisecondsSinceEpoch(0),
        promptText: (json['promptText'] ?? '').toString(),
        attachmentCount: (json['attachmentCount'] is int)
            ? (json['attachmentCount'] as int)
            : int.tryParse((json['attachmentCount'] ?? '0').toString()) ?? 0,
        selectedTopicTitle: (json['selectedTopicTitle'] ?? '').toString(),
        story: (json['story'] is Map<String, dynamic>)
            ? StoryModel.fromJson(json['story'] as Map<String, dynamic>)
            : null,
        platform_stories: (json['outputs'] is Map<String, dynamic>)
            ? PlatformStoriesModel.fromJson(json['outputs'] as Map<String, dynamic>)
            : null,
      );
}

String historyToPrettyJson(List<HistoryItem> items) {
  final arr = items.map((e) => e.toJson()).toList();
  return const JsonEncoder.withIndent('  ').convert(arr);
}
