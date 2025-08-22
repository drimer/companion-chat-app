import 'package:flutter/material.dart';
import 'screens/chat_screen.dart';

void main() {
  runApp(const CompanionChatApp());
}

class CompanionChatApp extends StatelessWidget {
  const CompanionChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Companion Chat',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ChatScreen(),
    );
  }
}


