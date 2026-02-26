class EmailStoryModel {
  final String story;

  EmailStoryModel({required this.story});

  Map<String, dynamic> toJson() {
    return {
      'story': story,
    };
  }

  factory EmailStoryModel.fromJson(Map<String, dynamic> json) {
    return EmailStoryModel(
      story: json['story'] as String,
    );
  }
}
