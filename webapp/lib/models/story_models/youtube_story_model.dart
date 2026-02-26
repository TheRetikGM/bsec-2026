import 'package:ai_redakcia_frontend/models/history_models/youtube_history_model.dart';

class YoutubeStoryModel {
  final String title;
  final String description;
  final String scenario;

  YoutubeStoryModel({required this.title, required this.description, required this.scenario});

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'scenario': scenario,
    };
  }

  factory YoutubeStoryModel.fromJson(Map<String, dynamic> json) {
    return YoutubeStoryModel(
      title: json['title'] as String,
      description: json['description'] as String,
      scenario: json['scenario'] as String,
    );
  }
}

extension YoutubeStoryMapping on YoutubeStoryModel {
  /// Maps a YoutubeStoryModel to a YoutubeHistoryModel
  /// [views] defaults to 0 as it's a new entry in history.
  YoutubeHistoryModel toHistory({int views = 0}) {
    return YoutubeHistoryModel(
      title: title,
      description: description,
      views: 0,
      scenario: scenario,
    );
  }
}
