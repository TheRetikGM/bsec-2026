class InstagramHistoryModel {
  final String description;
  final String photo_description;
  final int likes;

  InstagramHistoryModel(
      {required this.description, required this.photo_description, required this.likes});

  factory InstagramHistoryModel.fromJson(Map<String, dynamic> json) {
    return InstagramHistoryModel(
      description: json['Instagram_popis'],
      photo_description: json['Instagram_fotky'],
      likes: json['Instagram_likes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Instagram_popis': description,
      'Instagram_fotky': photo_description,
      'Instagram_likes': likes,
    };
  }
}


