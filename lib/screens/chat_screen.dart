import 'package:flutter/material.dart';
import '../models/message.dart';
import '../widgets/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Message> _messages = const [
    Message(role: 'user', content: 'Hi! How is your day going?'),
    Message(role: 'assistant', content: 'Konnichiwa! Totemo ii kanji desu.'),
    Message(
      role: 'user',
      content: 'Glad to hear it! What are you practicing today?',
    ),
  ];

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
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(child: Text('Text input will go here')),
                SizedBox(width: 8),
                Text('Send button will go here'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
