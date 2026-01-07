import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_router.dart';
import 'services/api_config.dart';
import 'services/auth_config.dart';

void main() {
  ApiConfig.ensureConfigured();
  AuthConfig.ensureLoaded();
  runApp(const ProviderScope(child: CompanionChatApp()));
}

class CompanionChatApp extends ConsumerWidget {
  const CompanionChatApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp(
      title: 'Companion Chat',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      navigatorKey: router.navigatorKey,
      initialRoute: AppRouter.loginRoute,
      onGenerateRoute: router.onGenerateRoute,
    );
  }
}
