import 'package:ai_redakcia_frontend/models/email_story_model.dart';
import 'package:ai_redakcia_frontend/models/insta_story_model.dart';
import 'package:ai_redakcia_frontend/models/tiktok_story_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'youtube_story_model.dart';
part 'platform_stories_model.freezed.dart';
part 'platform_stories_model.g.dart';

@freezed
abstract class PlatformStoriesModel with _$PlatformStoriesModel {
  factory PlatformStoriesModel({
    required YoutubeStoryModel yt_story,
    required InstaStoryModel insta_story,
    required TiktokStoryModel tiktok_story,
    required EmailStoryModel email_story,
  }) = _PlatformStoriesModel;
  factory PlatformStoriesModel.fromJson(Map<String, dynamic> json) =>
      _$PlatformStoriesModelFromJson(json);
}
