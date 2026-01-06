class Message {
  const Message({
    required this.role,
    required this.content,
    this.deliveryFailed = false,
  });

  final String role;
  final String content;
  final bool deliveryFailed;

  bool get isUser => role == 'user';
  bool get isAssistant => role == 'assistant';

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      role: json['role'] as String,
      content: json['content'] as String,
      deliveryFailed: json['delivery_failed'] as bool? ?? false,
    );
  }

  Map<String, String> toJson() {
    return <String, String>{'role': role, 'content': content};
  }

  Message copyWith({String? role, String? content, bool? deliveryFailed}) {
    return Message(
      role: role ?? this.role,
      content: content ?? this.content,
      deliveryFailed: deliveryFailed ?? this.deliveryFailed,
    );
  }
}
