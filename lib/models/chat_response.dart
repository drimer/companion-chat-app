class ChatResponse {
  const ChatResponse({required this.message});

  final String message;

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(message: json['message'] as String);
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{'message': message};
  }
}
