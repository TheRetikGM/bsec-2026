class StoryModel {
  final String story;

  StoryModel({required this.story});

  Map<String, dynamic> toJson() => {'story': story};

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    return StoryModel(story: (json['story'] ?? '').toString());
  }
}
