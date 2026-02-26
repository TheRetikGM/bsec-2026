import 'package:freezed_annotation/freezed_annotation.dart';
part 'email_story_model.freezed.dart';
part 'email_story_model.g.dart';

@freezed
abstract class EmailStoryModel with _$EmailStoryModel {
  factory EmailStoryModel({
    required String story,
  }) = _EmailStoryModel;
  factory EmailStoryModel.fromJson(Map<String, dynamic> json) => _$EmailStoryModelFromJson(json);
}
