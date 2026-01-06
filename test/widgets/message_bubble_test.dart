import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:companion_chat_app/models/message.dart';
import 'package:companion_chat_app/widgets/message_bubble.dart';

Widget _wrapWithApp(Widget child) {
  return MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  testWidgets('renders user message content without warning by default', (
    WidgetTester tester,
  ) async {
    const message = Message(role: 'user', content: 'Hello there');

    await tester.pumpWidget(
      _wrapWithApp(const MessageBubble(message: message)),
    );

    expect(find.text('Hello there'), findsOneWidget);
    expect(
      find.text('Not delivered. An unexpected error occurred.'),
      findsNothing,
    );
    expect(find.byIcon(Icons.warning_amber_rounded), findsNothing);
  });

  testWidgets('shows warning indicator for undelivered user message', (
    WidgetTester tester,
  ) async {
    const message = Message(
      role: 'user',
      content: 'Please work!',
      deliveryFailed: true,
    );

    await tester.pumpWidget(
      _wrapWithApp(const MessageBubble(message: message)),
    );

    expect(find.text('Please work!'), findsOneWidget);
    expect(
      find.text('Not delivered. An unexpected error occurred.'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
  });
}
