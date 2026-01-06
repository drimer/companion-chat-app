import 'package:companion_chat_app/models/chat_response.dart';
import 'package:companion_chat_app/models/conversation.dart';
import 'package:companion_chat_app/models/message.dart';
import 'package:companion_chat_app/services/api_service.dart';

class ApiServiceMock extends ApiService {
  ApiServiceMock({List<Message>? initialMessages, this.onSend})
    : _initialMessages = List<Message>.unmodifiable(
        initialMessages ?? const <Message>[],
      );

  final List<Message> _initialMessages;
  final Future<ChatResponse> Function(List<Message> history)? onSend;

  @override
  Future<Conversation> createConversation() async {
    return Conversation(
      id: 'test-conversation',
      systemPrompt: 'Test prompt',
      userId: 'tester',
      createdAt: DateTime.utc(2025, 1, 1),
      messages: List<Message>.from(_initialMessages),
    );
  }

  @override
  Future<ChatResponse> sendMessage({
    required String conversationId,
    required List<Message> messages,
  }) async {
    if (onSend != null) {
      return onSend!(messages);
    }
    final latest = messages.last;
    return ChatResponse(message: 'Echo: ${latest.content}');
  }

  @override
  void close() {
    // Tests manage lifecycle; nothing to dispose.
  }
}
