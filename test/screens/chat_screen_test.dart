import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:companion_chat_app/models/chat_response.dart';
import 'package:companion_chat_app/models/message.dart';
import 'package:companion_chat_app/screens/chat_screen.dart';
import 'package:companion_chat_app/services/api_service.dart';
import 'package:companion_chat_app/services/auth_service.dart';
import 'package:companion_chat_app/state/auth_controller.dart';
import '../mocks/api_service_mock.dart';

Widget _wrapWithApp(Widget child) {
  return ProviderScope(
    overrides: [
      authControllerProvider.overrideWith((ref) => _TestAuthController()),
    ],
    child: MaterialApp(title: 'Test Companion Chat', home: child),
  );
}

class _TestAuthController extends AuthController {
  _TestAuthController() : super(service: AuthService.instance) {
    state = AuthState.authenticated(
      AuthTokens(
        accessToken: 'test-access-token',
        expiry: DateTime.now().toUtc().add(const Duration(hours: 1)),
      ),
    );
  }

  @override
  Future<void> restoreSession() async {}

  @override
  Future<void> signOut({bool revokeTokens = true}) async {}
}

void main() {
  testWidgets('Chat screen renders seeded conversation history', (
    WidgetTester tester,
  ) async {
    final service = ApiServiceMock(
      initialMessages: const <Message>[
        Message(role: 'assistant', content: 'Hi! How is your day going?'),
        Message(role: 'user', content: 'Konnichiwa! Totemo ii kanji desu.'),
      ],
    );

    await tester.pumpWidget(_wrapWithApp(ChatScreen(apiService: service)));
    await tester.pumpAndSettle();

    expect(find.text('Companion Chat'), findsOneWidget);
    expect(find.text('Hi! How is your day going?'), findsOneWidget);
    expect(find.text('Konnichiwa! Totemo ii kanji desu.'), findsOneWidget);
  });

  testWidgets('Sending a message updates the conversation', (
    WidgetTester tester,
  ) async {
    final service = ApiServiceMock(
      onSend: (history) async {
        final latest = history.last;
        return ChatResponse(message: 'Thanks for sharing: ${latest.content}');
      },
    );

    await tester.pumpWidget(_wrapWithApp(ChatScreen(apiService: service)));
    await tester.pumpAndSettle();

    final textField = find.byType(TextField);
    final sendButton = find.byIcon(Icons.send);

    await tester.enterText(textField, 'This is a test');
    await tester.tap(sendButton);
    await tester.pump();

    expect(find.text('This is a test'), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.text('Thanks for sharing: This is a test'), findsOneWidget);
    final textFieldWidget = tester.widget<TextField>(textField);
    expect(textFieldWidget.controller?.text, isEmpty);
  });

  testWidgets('Displays offline banner when send fails with offline error', (
    WidgetTester tester,
  ) async {
    final service = ApiServiceMock(
      onSend: (_) async {
        throw ApiException('No internet connection.', isOffline: true);
      },
    );

    await tester.pumpWidget(_wrapWithApp(ChatScreen(apiService: service)));
    await tester.pumpAndSettle();

    final textField = find.byType(TextField);
    final sendButton = find.byIcon(Icons.send);

    await tester.enterText(textField, 'Offline test');
    await tester.tap(sendButton);

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Offline test'), findsOneWidget);
    expect(
      find.text('You are offline. Messages will be sent once you reconnect.'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.wifi_off), findsOneWidget);
    expect(
      find.text('Not delivered. An unexpected error occurred.'),
      findsOneWidget,
    );
    expect(
      find.text(
        'You appear to be offline. Check your connection and try again.',
      ),
      findsOneWidget,
    );
  });
}
