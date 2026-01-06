import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/chat_response.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import 'api_config.dart';

class ApiException implements Exception {
  ApiException(
    this.message, {
    this.statusCode,
    this.details,
    this.isOffline = false,
  });

  final String message;
  final int? statusCode;
  final Object? details;
  final bool isOffline;

  @override
  String toString() {
    final statusSuffix = statusCode == null ? '' : '($statusCode)';
    return 'ApiException$statusSuffix: $message';
  }
}

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<Conversation> createConversation() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/conversations');

    try {
      final response = await _client.post(uri);
      _throwForError(response, 'create conversation');

      final body = _decodeBody(response.body);
      return Conversation.fromJson(body);
    } catch (error) {
      throw _wrapError('create conversation', error);
    }
  }

  Future<ChatResponse> sendMessage({
    required String conversationId,
    required List<Message> messages,
  }) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/conversations/$conversationId/chat',
    );

    final payload = jsonEncode({
      'messages': messages.map((message) => message.toJson()).toList(),
    });

    try {
      final response = await _client.post(
        uri,
        headers: const {'Content-Type': 'application/json'},
        body: payload,
      );
      _throwForError(response, 'send message');

      final body = _decodeBody(response.body);
      return ChatResponse.fromJson(body);
    } catch (error) {
      throw _wrapError('send message', error);
    }
  }

  void close() {
    _client.close();
  }

  Map<String, dynamic> _decodeBody(String rawBody) {
    final decoded = jsonDecode(rawBody);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw ApiException('Unexpected response shape.');
  }

  void _throwForError(http.Response response, String action) {
    final status = response.statusCode;
    if (status >= 200 && status < 300) {
      return;
    }

    throw ApiException(
      'Failed to $action. Server responded with $status.',
      statusCode: status,
      details: response.body,
    );
  }

  ApiException _wrapError(String action, Object error) {
    if (error is ApiException) {
      return error;
    }
    if (error is SocketException) {
      return ApiException(
        'No internet connection.',
        details: error,
        isOffline: true,
      );
    }
    return ApiException('Unable to $action: $error', details: error);
  }
}
