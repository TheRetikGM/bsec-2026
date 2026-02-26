import 'package:ai_redakcia_frontend/services/api_service.dart';

import '../models/platform_stories_model.dart';
import '../models/profile_model.dart';
import '../models/story_model.dart';
import '../models/topic_model.dart';

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
}
