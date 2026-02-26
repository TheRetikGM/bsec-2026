class YoutubeHistoryModel {
  final String title;
  final String description;
  final String scenario;
  final int views;

  YoutubeHistoryModel({
    required this.title,
    required this.description,
    required this.views,
    required this.scenario,
  });

  factory YoutubeHistoryModel.fromJson(Map<String, dynamic> json) {
    return YoutubeHistoryModel(
      title: json['YouTube_názov'],
      description: json['YouTube_popis'],
      scenario: json['YouTube_scénář'],
      views: json['YouTube_views'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'YouTube_názov': title,
      'YouTube_popis': description,
      'YouTube_scénář': scenario,
      'YouTube_views': views,
    };
  }
}
