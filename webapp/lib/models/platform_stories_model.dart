import 'package:ai_redakcia_frontend/models/story_models/insta_story_model.dart';
import 'package:ai_redakcia_frontend/models/story_models/tiktok_story_model.dart';
import 'package:ai_redakcia_frontend/models/story_models/youtube_story_model.dart';

class PlatformStoriesModel {
  final YoutubeStoryModel yt_story;
  final InstaStoryModel insta_story;
  final TikTokStoryModel tiktok_story;

  PlatformStoriesModel({
    required this.yt_story,
    required this.insta_story,
    required this.tiktok_story,
  });

  Map<String, dynamic> toJson() => {
        'yt_story': yt_story.toJson(),
        'insta_story': insta_story.toJson(),
        'tiktok_story': tiktok_story.toJson(),
      };

  factory PlatformStoriesModel.fromJson(dynamic json) {
    return PlatformStoriesModel(
      yt_story: YoutubeStoryModel.fromJson(json[0]['message'] as Map<String, dynamic>),
      insta_story: InstaStoryModel.fromJson(json[1]['message'] as Map<String, dynamic>),
      tiktok_story: TikTokStoryModel.fromJson(json[2]['message'] as Map<String, dynamic>),
    );
  }
}
