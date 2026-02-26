import 'package:ai_redakcia_frontend/models/history_models/tiktok_history_model.dart';

class TikTokStoryModel {
  final String description;
  final String scenario;

  TikTokStoryModel({required this.description, required this.scenario});

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'scenario': scenario,
    };
  }

  factory TikTokStoryModel.fromJson(Map<String, dynamic> json) {
    return TikTokStoryModel(
      description: json['content'] as String,
      scenario: "" as String,
    );
  }
}

extension TikTokStoryMapping on TikTokStoryModel {
  /// Maps TikTokStoryModel to TikTokHistoryModel
  /// [views] defaults to 0 for new history entries.
  TikTokHistoryModel toHistory({int views = 0}) {
    return TikTokHistoryModel(
      description: description, // Maps to 'TikTok_popis'
      scenario: scenario, // Maps to 'TikTok_scénář'
      views: 0, // Maps to 'TikTok_views'
    );
  }
}
