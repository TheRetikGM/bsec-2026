import 'package:freezed_annotation/freezed_annotation.dart';
part 'story_model.freezed.dart';
part 'story_model.g.dart';

@freezed
abstract class StoryModel with _$StoryModel {
  factory StoryModel({
    required String story,
  }) = _StoryModel;
  factory StoryModel.fromJson(Map<String, dynamic> json) => _$StoryModelFromJson(json);
}
