import 'dart:async';

import 'package:flutter/material.dart';
import '../models/message.dart';
import '../services/api_service.dart';
import '../widgets/chat_input.dart';
import '../widgets/message_bubble.dart';
import '../widgets/typing_indicator.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, this.apiService});

  final ApiService? apiService;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<Message> _messages = <Message>[];
  late final ApiService _apiService;
  late final bool _ownsApiService;
  String? _conversationId;
  bool _isSending = false;
  bool _isInitializing = true;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _apiService = widget.apiService ?? ApiService();
    _ownsApiService = widget.apiService == null;
    _initialize();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    if (_ownsApiService) {
      _apiService.close();
    }
    super.dispose();
  }

  Future<void> _initialize() async {
    try {
      await _ensureConversation();
    } catch (error) {
      final offline = _isOfflineError(error);
      if (offline) {
        _setOffline(true);
      }
      if (mounted) {
        _showError(
          offline
              ? 'You appear to be offline. Check your connection and try again.'
              : 'Unable to start a new conversation.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  bool get _showTypingIndicator => _isSending && _messages.isNotEmpty;

  bool _isOfflineError(Object error) {
    return error is ApiException && error.isOffline;
  }

  void _setOffline(bool value) {
    if (_isOffline == value || !mounted) {
      return;
    }
    setState(() {
      _isOffline = value;
    });
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

    final conversation = await _retry(() => _apiService.createConversation());
    if (!mounted) {
      return conversation.id;
    }

    setState(() {
      _conversationId = conversation.id;
      _isOffline = false;
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
      final history = List<Message>.unmodifiable(
        _messages.where((message) => !message.deliveryFailed),
      );
      final response = await _retry(
        () => _apiService.sendMessage(
          conversationId: conversationId,
          messages: history,
        ),
      );
      _addMessage(Message(role: 'assistant', content: response.message));
      _setOffline(false);
    } catch (error) {
      final offline = _isOfflineError(error);
      if (mounted) {
        setState(() {
          if (userMessage != null) {
            final index = _messages.indexOf(userMessage);
            if (index >= 0) {
              _messages[index] = userMessage.copyWith(deliveryFailed: true);
            }
          }
          if (offline) {
            _isOffline = true;
          }
        });
      }
      _showError(
        offline
            ? 'You appear to be offline. Check your connection and try again.'
            : 'Unable to send message. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  Future<T> _retry<T>(Future<T> Function() action) async {
    Object? lastError;
    StackTrace? lastStack;

    for (var attempt = 0; attempt < 2; attempt++) {
      try {
        return await action();
      } catch (error, stackTrace) {
        lastError = error;
        lastStack = stackTrace;
      }
    }

    if (lastError != null && lastStack != null) {
      Error.throwWithStackTrace(lastError, lastStack);
    }

    throw StateError('Retry attempts exhausted unexpectedly.');
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
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _isOffline
                  ? Container(
                      key: const ValueKey('offline-banner'),
                      width: double.infinity,
                      color: Theme.of(context).colorScheme.errorContainer,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.wifi_off,
                            size: 16,
                            color: Theme.of(
                              context,
                            ).colorScheme.onErrorContainer,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'You are offline. Messages will be sent once you reconnect.',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onErrorContainer,
                                  ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(key: ValueKey('offline-placeholder')),
            ),
            Expanded(
              child: _isInitializing && _messages.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : Builder(
                      builder: (context) {
                        final showTypingIndicator = _showTypingIndicator;
                        final totalMessages = _messages.length;

                        return ListView.separated(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                          reverse: true,
                          itemCount:
                              totalMessages + (showTypingIndicator ? 1 : 0),
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            if (showTypingIndicator && index == 0) {
                              return const TypingIndicator();
                            }

                            final offset = showTypingIndicator
                                ? index - 1
                                : index;
                            final message =
                                _messages[totalMessages - 1 - offset];
                            return MessageBubble(message: message);
                          },
                        );
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
