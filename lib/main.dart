import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'screens/chat_screen.dart';
import 'screens/login_screen.dart';
import 'services/api_config.dart';
import 'services/auth_config.dart';
import 'state/auth_controller.dart';

void main() {
  ApiConfig.ensureConfigured();
  AuthConfig.ensureLoaded();
  runApp(const ProviderScope(child: CompanionChatApp()));
}

class CompanionChatApp extends ConsumerWidget {
  const CompanionChatApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    return MaterialApp(
      title: 'Companion Chat',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: switch (authState.status) {
        AuthStatus.authenticated when authState.tokens != null =>
          const ChatScreen(),
        _ => const LoginScreen(),
      },
    );
  }
}
