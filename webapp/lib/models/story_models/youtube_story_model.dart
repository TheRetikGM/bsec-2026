class YoutubeStoryModel {
  final String title;
  final String description;
  final String scenario;

  YoutubeStoryModel({required this.title, required this.description, required this.scenario});

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'scenario': scenario,
    };
  }

  factory YoutubeStoryModel.fromJson(Map<String, dynamic> json) {
    return YoutubeStoryModel(
      title: json['title'] as String,
      description: json['description'] as String,
      scenario: json['scenario'] as String,
    );
  }
}
