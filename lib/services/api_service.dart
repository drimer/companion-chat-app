import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/chat_response.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import 'api_config.dart';
import 'auth_service.dart';

class ApiException implements Exception {
  ApiException(
    this.message, {
    this.statusCode,
    this.details,
    this.isOffline = false,
    this.unauthorized = false,
  });

  final String message;
  final int? statusCode;
  final Object? details;
  final bool isOffline;
  final bool unauthorized;

  @override
  String toString() {
    final statusSuffix = statusCode == null ? '' : '($statusCode)';
    return 'ApiException$statusSuffix: $message';
  }
}

class ApiService {
  ApiService({
    http.Client? client,
    AuthService? authService,
    FutureOr<void> Function()? onUnauthorized,
  }) : _client = client ?? http.Client(),
       _authService = authService ?? AuthService.instance,
       _onUnauthorized = onUnauthorized;

  final http.Client _client;
  final AuthService _authService;
  final FutureOr<void> Function()? _onUnauthorized;

  Future<Conversation> createConversation() async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/conversations');

    try {
      final headers = await _authorizedHeaders();
      final response = await _client.post(uri, headers: headers);
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
      final headers = await _authorizedHeaders(const {
        'Content-Type': 'application/json',
      });
      final response = await _client.post(uri, headers: headers, body: payload);
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

    final unauthorized = status == 401 || status == 403;
    if (unauthorized) {
      _handleUnauthorized();
    }

    throw ApiException(
      'Failed to $action. Server responded with $status.',
      statusCode: status,
      details: response.body,
      unauthorized: unauthorized,
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

  Future<Map<String, String>> _authorizedHeaders([
    Map<String, String>? headers,
  ]) async {
    try {
      final token = await _authService.getValidIdToken();
      if (token == null || token.isEmpty) {
        throw ApiException(
          'User session has expired.',
          statusCode: 401,
          unauthorized: true,
        );
      }
      return {
        if (headers != null) ...headers,
        'Authorization': 'Bearer $token',
      };
    } catch (error) {
      if (error is ApiException && error.unauthorized) {
        _handleUnauthorized();
        throw error;
      }
      _handleUnauthorized();
      throw ApiException(
        'Unable to obtain access token.',
        statusCode: 401,
        unauthorized: true,
        details: error,
      );
    }
  }

  void _handleUnauthorized() {
    final callback = _onUnauthorized;
    if (callback == null) {
      return;
    }
    try {
      final result = callback();
      if (result is Future<void>) {
        unawaited(result);
      }
    } catch (_) {
      // Ignore callback failures.
    }
  }
}
