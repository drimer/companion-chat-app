import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:companion_chat_app/models/chat_response.dart';
import 'package:companion_chat_app/models/message.dart';
import 'package:companion_chat_app/screens/chat_screen.dart';
import 'mocks/api_service_mock.dart';

Widget _wrapWithApp(Widget child) {
  return MaterialApp(title: 'Test Companion Chat', home: child);
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
}
