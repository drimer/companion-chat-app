import 'package:flutter/material.dart';
import '../models/message.dart';
import '../widgets/chat_input.dart';
import '../widgets/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<Message> _messages = List<Message>.of([
    Message(role: 'user', content: 'Hi! How is your day going?'),
    Message(role: 'assistant', content: 'Konnichiwa! Totemo ii kanji desu.'),
    Message(
      role: 'user',
      content: 'Glad to hear it! What are you practicing today?',
    ),
  ]);

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _addMessage(Message message) {
    setState(() {
      _messages.add(message);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  void _handleSend(String content) {
    _addMessage(Message(role: 'user', content: content));
    Future<void>.delayed(
      const Duration(seconds: 1),
      () => _addMessage(
        Message(role: 'assistant', content: 'Thanks for sharing: $content'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Companion Chat'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              reverse: true,
              itemCount: _messages.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final message = _messages[_messages.length - 1 - index];
                return MessageBubble(message: message);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ChatInput(onSend: _handleSend),
          ),
        ],
      ),
    );
  }
}
