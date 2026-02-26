import 'package:ai_redakcia_frontend/models/email_story_model.dart';
import 'package:ai_redakcia_frontend/models/tiktok_story_model.dart';
import 'package:ai_redakcia_frontend/models/youtube_story_model.dart';
import 'package:ai_redakcia_frontend/services/api_service.dart';

import '../models/insta_story_model.dart';
import '../models/platform_stories_model.dart';
import '../models/profile_model.dart';
import '../models/story_model.dart';
import '../models/topic_model.dart';

class StoryGenService {
  final ApiService apiService;

  StoryGenService() : apiService = ApiService(host: "https://nn.datovka.eu") {}

  Future<List<ProfileModel>> generateTopics(TopicModel topic) async {
    await Future.delayed(Duration(seconds: 1));
    return [];
  }

  Future<StoryModel> writeStory(ProfileModel topic) async {
    await Future.delayed(Duration(seconds: 1));
    return StoryModel(story: "This is a dummy story");
  }

  Future<PlatformStoriesModel> createPlatformStories(StoryModel topic) async {
    await Future.delayed(Duration(seconds: 1));
    return PlatformStoriesModel(
      yt_story: YoutubeStoryModel(story: "Youtube story script"),
      insta_story: InstaStoryModel(story: "Instagram story post"),
      tiktok_story: TiktokStoryModel(story: "Tiktok story post"),
      email_story: EmailStoryModel(story: "Email to send to evaluators"),
    );
  }
}
