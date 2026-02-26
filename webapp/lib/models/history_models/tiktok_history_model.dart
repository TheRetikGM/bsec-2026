class TikTokHistoryModel {
  final String description;
  final String scenario;
  final int views;

  TikTokHistoryModel({required this.description, required this.scenario, required this.views});

  factory TikTokHistoryModel.fromJson(Map<String, dynamic> json) {
    return TikTokHistoryModel(
      description: json['TikTok_popis'],
      scenario: json['TikTok_scénář'],
      views: json['TikTok_views'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'TikTok_popis': description,
      'TikTok_scénář': scenario,
      'TikTok_views': views,
    };
  }
}
