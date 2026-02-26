import 'package:ai_redakcia_frontend/models/history_models/Instagram_history_model.dart';

class InstaStoryModel {
  final String description;
  final String photo_description;

  InstaStoryModel({required this.description, required this.photo_description});

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'photo_description': photo_description,
    };
  }

  factory InstaStoryModel.fromJson(Map<String, dynamic> json) {
    return InstaStoryModel(
      description: json['content'] as String,
      photo_description: "" as String,
    );
  }
}

extension InstagramStoryMapping on InstaStoryModel {
  /// Maps InstaStoryModel to InstagramHistoryModel
  /// [likes] defaults to 0 for new history entries.
  InstagramHistoryModel toHistory({int likes = 0}) {
    return InstagramHistoryModel(
      description: description, // Maps to 'Instagram_popis'
      photo_description: photo_description, // Maps to 'Instagram_fotky'
      likes: 0, // Maps to 'Instagram_likes'
    );
  }
}
