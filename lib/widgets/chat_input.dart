import 'package:flutter/material.dart';

class ChatInput extends StatefulWidget {
  const ChatInput({super.key, required this.onSend});

  final ValueChanged<String> onSend;

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      return;
    }
    widget.onSend(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => _handleSend(),
            decoration: const InputDecoration(
              hintText: 'Type your message...',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(icon: const Icon(Icons.send), onPressed: _handleSend),
      ],
    );
  }
}
