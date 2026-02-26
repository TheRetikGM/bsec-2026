class ProfileModel {
  final String topic;
  final String goal;
  final String target_group;
  final String main_thought;
  final String tone;
  final String idea;

  ProfileModel({
    required this.topic,
    required this.goal,
    required this.target_group,
    required this.main_thought,
    required this.tone,
    required this.idea,
  });

  ProfileModel copyWith({
    String? theme,
    String? goal,
    String? target_group,
    String? main_thought,
    String? tone,
    String? idea,
  }) {
    return ProfileModel(
      topic: theme ?? this.topic,
      goal: goal ?? this.goal,
      target_group: target_group ?? this.target_group,
      main_thought: main_thought ?? this.main_thought,
      tone: tone ?? this.tone,
      idea: idea ?? this.idea,
    );
  }

  Map<String, dynamic> toJson() => {
        'theme': topic,
        'goal': goal,
        'target_group': target_group,
        'main_thought': main_thought,
        'tone': tone,
        'idea': idea,
      };

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      topic: (json['theme'] ?? '').toString(),
      goal: (json['goal'] ?? '').toString(),
      target_group: (json['target_group'] ?? '').toString(),
      main_thought: (json['main_thought'] ?? '').toString(),
      tone: (json['tone'] ?? '').toString(),
      idea: (json['idea'] ?? '').toString(),
    );
  }
}
