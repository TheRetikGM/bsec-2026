import 'dart:convert';
import 'dart:typed_data';

class GlobalSettings {
  final String language;
  final String length; // short/medium/long

  const GlobalSettings({
    required this.language,
    required this.length,
  });

  GlobalSettings copyWith({
    String? language,
    String? length,
  }) {
    return GlobalSettings(
      language: language ?? this.language,
      length: length ?? this.length,
    );
  }

  Map<String, dynamic> toJson() => {
        'language': language,
        'length': length,
      };

  static GlobalSettings fromJson(Map<String, dynamic> json) => GlobalSettings(
        language: (json['language'] ?? 'en').toString(),
        length: (json['length'] ?? 'medium').toString(),
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
