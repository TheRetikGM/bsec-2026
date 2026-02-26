class InstaStoryModel {
  final String description;
  final String photo_description;

  InstaStoryModel({required this.description, required this.photo_description});

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'photo_description': photo_description,
    };
  }

  factory InstaStoryModel.fromJson(Map<String, dynamic> json) {
    return InstaStoryModel(
      description: json['description'] as String,
      photo_description: json['photo_description'] as String,
    );
  }
}
