import 'package:freezed_annotation/freezed_annotation.dart';
part 'tiktok_story_model.freezed.dart';
part 'tiktok_story_model.g.dart';

@freezed
abstract class TiktokStoryModel with _$TiktokStoryModel {
  factory TiktokStoryModel({
    required String story,
  }) = _TiktokStoryModel;
  factory TiktokStoryModel.fromJson(Map<String, dynamic> json) => _$TiktokStoryModelFromJson(json);
}
