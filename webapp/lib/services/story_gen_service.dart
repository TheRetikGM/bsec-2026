import 'package:ai_redakcia_frontend/models/history_models/youtube_history_model.dart';
import 'package:ai_redakcia_frontend/services/api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/platform_stories_model.dart';
import '../models/profile_model.dart';
import '../models/story_model.dart';
import '../models/topic_model.dart';
import '../core/models.dart';

final storyGenServiceProvider = Provider<StoryGenService>((ref) {
  return StoryGenService();
});

class StoryGenService {
  final ApiService _apiService;

  StoryGenService() : _apiService = ApiService(host: "https://nn.datovka.eu") {}

  Future<List<ProfileModel>> generateTopics(TopicModel topic) async {
    try {
      final response = await _apiService.postJson(
        path: '/dummy-endpoint', // change later
        body: topic.toJson(), // 🔥 serialize Freezed model
      );

      final profilesJson = response['profiles'] as List<dynamic>;

      return profilesJson.map((e) => ProfileModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      // Optional: log or wrap error
      rethrow;
    }
  }

  Future<StoryModel> writeStory(ProfileModel topic) async {
    final json = await _apiService.postJson(
      path: '/write-story', // change later
      body: topic.toJson(),
    );

    return StoryModel.fromJson(json);
  }

  Future<PlatformStoriesModel> createPlatformStories(StoryModel topic) async {
    final json = await _apiService.postJson(
      path: '/create-platform-stories', // change later
      body: topic.toJson(),
    );

    return PlatformStoriesModel.fromJson(json);
  }


Future<List<HistoryItem>> fetchHistoryByUsernames({
  required String youtube,
  required String tiktok,
  required String instagram,
}) async {
  final json = await _apiService.getJson(
    path: '/history',
    queryParameters: {
      'youtube': youtube,
      'tiktok': tiktok,
      'instagram': instagram,
    },
  );

  final list = (json['history'] as List?) ?? const [];
  return list
      .whereType<Map>()
      .map((e) => HistoryItem.fromJson(Map<String, dynamic>.from(e)))
      .toList();
}

  Future<bool> submitYoutubeHistory(List<YoutubeHistoryModel> youtube_histories) async {
    final jsonList = youtube_histories.map((history) => history.toJson()).toList();

    final json = await _apiService.postJson(
      path: '/submit_youtube_history', // change later
      body: jsonList,
    );

    return true;
  }
}
