import 'package:freezed_annotation/freezed_annotation.dart';
part 'youtube_story_model.freezed.dart';
part 'youtube_story_model.g.dart';

@freezed
abstract class YoutubeStoryModel with _$YoutubeStoryModel {
  factory YoutubeStoryModel({
    required String story,
  }) = _YoutubeStoryModel;
  factory YoutubeStoryModel.fromJson(Map<String, dynamic> json) =>
      _$YoutubeStoryModelFromJson(json);
}
