import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:companion_chat_app/main.dart';

void main() {
  testWidgets('Chat screen renders sample messages', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const CompanionChatApp());

    expect(find.text('Companion Chat'), findsOneWidget);
    expect(find.text('Hi! How is your day going?'), findsOneWidget);
    expect(find.text('Konnichiwa! Totemo ii kanji desu.'), findsOneWidget);
  });

  testWidgets('Sending a message updates the conversation', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const CompanionChatApp());

    final textField = find.byType(TextField);
    final sendButton = find.byIcon(Icons.send);

    await tester.enterText(textField, 'This is a test');
    await tester.tap(sendButton);
    await tester.pump();

    expect(find.text('This is a test'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Thanks for sharing: This is a test'), findsOneWidget);
    final textFieldWidget = tester.widget<TextField>(textField);
    expect(textFieldWidget.controller?.text, isEmpty);
  });
}
