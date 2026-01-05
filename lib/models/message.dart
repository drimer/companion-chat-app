class Message {
  const Message({required this.role, required this.content});

  final String role;
  final String content;

  bool get isUser => role == 'user';
  bool get isAssistant => role == 'assistant';

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      role: json['role'] as String,
      content: json['content'] as String,
    );
  }

  Map<String, String> toJson() {
    return <String, String>{'role': role, 'content': content};
  }
}
