class TikTokStoryModel {
  final String description;
  final String scenario;

  TikTokStoryModel({required this.description, required this.scenario});

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'scenario': scenario,
    };
  }

  factory TikTokStoryModel.fromJson(Map<String, dynamic> json) {
    return TikTokStoryModel(
      description: json['description'] as String,
      scenario: json['scenario'] as String,
    );
  }
}
