class Message {
  const Message({required this.role, required this.content});

  final String role;
  final String content;

  bool get isUser => role == 'user';
  bool get isAssistant => role == 'assistant';
}
