import 'package:freezed_annotation/freezed_annotation.dart';
part 'topic_model.freezed.dart';
part 'topic_model.g.dart';

@freezed
abstract class TopicModel with _$TopicModel {
  factory TopicModel({
    required String prompt,
  }) = _TopicModel;

  factory TopicModel.fromJson(Map<String, dynamic> json) => _$TopicModelFromJson(json);
}
