import 'message.dart';

class Conversation {
  const Conversation({
    required this.id,
    required this.systemPrompt,
    required this.userId,
    required this.createdAt,
    required this.messages,
  });

  final String id;
  final String systemPrompt;
  final String userId;
  final DateTime createdAt;
  final List<Message> messages;

  factory Conversation.fromJson(Map<String, dynamic> json) {
    final rawMessages = json['messages'];
    final messageList = rawMessages is List
        ? rawMessages
              .whereType<Map<String, dynamic>>()
              .map(Message.fromJson)
              .toList()
        : <Message>[];

    return Conversation(
      id: json['id'] as String,
      systemPrompt: json['system_prompt'] as String,
      userId: json['user_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      messages: messageList,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'system_prompt': systemPrompt,
      'user_id': userId,
      'created_at': createdAt.toUtc().toIso8601String(),
      'messages': messages.map((message) => message.toJson()).toList(),
    };
  }
}
