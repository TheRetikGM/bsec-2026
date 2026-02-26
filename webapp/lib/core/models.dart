import 'dart:convert';
import 'dart:typed_data';

class Topic {
  final String id;
  final String title;

  // “Detailed” fields (editable on Topics page)
  final String hook;
  final String angle;
  final List<String> keyPoints;

  const Topic({
    required this.id,
    required this.title,
    required this.hook,
    required this.angle,
    required this.keyPoints,
  });

  Topic copyWith({
    String? id,
    String? title,
    String? hook,
    String? angle,
    List<String>? keyPoints,
  }) {
    return Topic(
      id: id ?? this.id,
      title: title ?? this.title,
      hook: hook ?? this.hook,
      angle: angle ?? this.angle,
      keyPoints: keyPoints ?? this.keyPoints,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'hook': hook,
        'angle': angle,
        'keyPoints': keyPoints,
      };

  static Topic fromJson(Map<String, dynamic> json) => Topic(
        id: (json['id'] ?? '').toString(),
        title: (json['title'] ?? '').toString(),
        hook: (json['hook'] ?? '').toString(),
        angle: (json['angle'] ?? '').toString(),
        keyPoints: (json['keyPoints'] is List)
            ? (json['keyPoints'] as List).map((e) => e.toString()).toList()
            : const <String>[],
      );
}

class GeneratedOutputs {
  final String youtube;
  final String tiktok;
  final String telegram;

  const GeneratedOutputs({
    required this.youtube,
    required this.tiktok,
    required this.telegram,
  });

  Map<String, dynamic> toJson() => {
        'youtube': youtube,
        'tiktok': tiktok,
        'telegram': telegram,
      };

  static GeneratedOutputs fromJson(Map<String, dynamic> json) => GeneratedOutputs(
        youtube: (json['youtube'] ?? '').toString(),
        tiktok: (json['tiktok'] ?? '').toString(),
        telegram: (json['telegram'] ?? '').toString(),
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
  final GeneratedOutputs? outputs;

  const HistoryItem({
    required this.id,
    required this.createdAt,
    required this.promptText,
    required this.attachmentCount,
    required this.selectedTopicTitle,
    required this.outputs,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'createdAt': createdAt.toIso8601String(),
        'promptText': promptText,
        'attachmentCount': attachmentCount,
        'selectedTopicTitle': selectedTopicTitle,
        'outputs': outputs?.toJson(),
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
        outputs: (json['outputs'] is Map<String, dynamic>)
            ? GeneratedOutputs.fromJson(json['outputs'] as Map<String, dynamic>)
            : null,
      );
}

String historyToPrettyJson(List<HistoryItem> items) {
  final arr = items.map((e) => e.toJson()).toList();
  return const JsonEncoder.withIndent('  ').convert(arr);
}
class GlobalSettings {
  final String language; // e.g. 'en', 'cs', 'sk'
  final String tone; // e.g. 'professional', 'casual'
  final String length; // 'short', 'medium', 'long'
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
