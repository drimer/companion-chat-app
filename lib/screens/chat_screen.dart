import 'dart:async';

import 'package:flutter/material.dart';
import '../models/message.dart';
import '../services/api_service.dart';
import '../widgets/chat_input.dart';
import '../widgets/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final ApiService _apiService = ApiService();
  final List<Message> _messages = <Message>[];
  String? _conversationId;
  bool _isSending = false;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _apiService.close();
    super.dispose();
  }

  Future<void> _initialize() async {
    try {
      await _ensureConversation();
    } catch (error) {
      if (mounted) {
        _showError('Unable to start a new conversation.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
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

  Future<String> _ensureConversation() async {
    if (_conversationId != null) {
      return _conversationId!;
    }

    final conversation = await _apiService.createConversation();
    if (!mounted) {
      return conversation.id;
    }

    setState(() {
      _conversationId = conversation.id;
    });

    if (conversation.messages.isNotEmpty) {
      for (final message in conversation.messages) {
        _addMessage(message);
      }
    }

    return conversation.id;
  }

  Future<void> _handleSend(String content) async {
    if (_isSending) {
      return;
    }

    setState(() {
      _isSending = true;
    });

    Message? userMessage;

    try {
      final conversationId = await _ensureConversation();
      userMessage = Message(role: 'user', content: content);
      _addMessage(userMessage);
      final history = List<Message>.unmodifiable(_messages);
      final response = await _apiService.sendMessage(
        conversationId: conversationId,
        messages: history,
      );
      _addMessage(Message(role: 'assistant', content: response.message));
    } catch (error) {
      if (mounted) {
        setState(() {
          if (userMessage != null) {
            _messages.remove(userMessage);
          }
        });
      }
      _showError('Unable to send message. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Companion Chat'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            if (_isInitializing || _isSending) const LinearProgressIndicator(),
            Expanded(
              child: _isInitializing && _messages.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.separated(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
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
              child: ChatInput(
                onSend: _handleSend,
                enabled: !_isSending && !_isInitializing,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
