import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Companion Chat'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const Column(
        children: [
          // Message list will go here
          Expanded(
            child: Center(
              child: Text('Chat messages will appear here'),
            ),
          ),
          // Input field will go here
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Text('Text input will go here'),
                ),
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
