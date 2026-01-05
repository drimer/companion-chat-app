class Conversation {
  const Conversation({
    required this.id,
    required this.systemPrompt,
    required this.userId,
    required this.createdAt,
  });

  final String id;
  final String systemPrompt;
  final String userId;
  final DateTime createdAt;

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as String,
      systemPrompt: json['system_prompt'] as String,
      userId: json['user_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'system_prompt': systemPrompt,
      'user_id': userId,
      'created_at': createdAt.toUtc().toIso8601String(),
    };
  }
}
