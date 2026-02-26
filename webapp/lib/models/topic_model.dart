class TopicModel {
  final String prompt;

  TopicModel({required this.prompt});

  Map<String, dynamic> toJson() => {'prompt': prompt};

  factory TopicModel.fromJson(Map<String, dynamic> json) {
    return TopicModel(prompt: (json['prompt'] ?? '').toString());
  }
}
