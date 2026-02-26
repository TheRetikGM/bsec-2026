import 'package:freezed_annotation/freezed_annotation.dart';
part 'insta_story_model.freezed.dart';
part 'insta_story_model.g.dart';

@freezed
abstract class InstaStoryModel with _$InstaStoryModel {
  factory InstaStoryModel({
    required String story,
  }) = _InstsaStoryModel;
  factory InstaStoryModel.fromJson(Map<String, dynamic> json) => _$InstaStoryModelFromJson(json);
}
