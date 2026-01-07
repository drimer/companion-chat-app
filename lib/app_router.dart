import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'screens/chat_screen.dart';
import 'screens/login_screen.dart';
import 'state/auth_controller.dart';

class AppRouter {
  AppRouter(this._ref) : _guard = AuthRouteGuard(_ref);

  static const String loginRoute = '/';
  static const String chatRoute = '/chat';

  final Ref _ref;
  final AuthRouteGuard _guard;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  String _currentRoute = loginRoute;

  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final routeName = settings.name ?? loginRoute;

    if (routeName == chatRoute) {
      if (!_guard.canActivateProtectedRoute()) {
        _currentRoute = loginRoute;
        return _guard.redirectToLogin(settings);
      }
      _currentRoute = chatRoute;
      return MaterialPageRoute<void>(
        builder: (_) => const ChatScreen(),
        settings: const RouteSettings(name: chatRoute),
      );
    }

    _currentRoute = loginRoute;
    return MaterialPageRoute<void>(
      builder: (_) => const LoginScreen(),
      settings: const RouteSettings(name: loginRoute),
    );
  }

  void handleAuthState(AuthState? _previous, AuthState next) {
    if (next.status == AuthStatus.authenticating) {
      return;
    }

    final targetRoute = next.isAuthenticated ? chatRoute : loginRoute;
    if (_currentRoute == targetRoute) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navigator = navigatorKey.currentState;
      if (navigator == null) {
        return;
      }
      navigator.pushNamedAndRemoveUntil(targetRoute, (route) => false);
      _currentRoute = targetRoute;
    });
  }
}

class AuthRouteGuard {
  AuthRouteGuard(this._ref);

  final Ref _ref;

  bool canActivateProtectedRoute() {
    final state = _ref.read(authControllerProvider);
    return state.isAuthenticated;
  }

  Route<dynamic> redirectToLogin(RouteSettings _settings) {
    return MaterialPageRoute<void>(
      builder: (_) => const LoginScreen(),
      settings: const RouteSettings(name: AppRouter.loginRoute),
    );
  }
}

final appRouterProvider = Provider<AppRouter>((ref) {
  final router = AppRouter(ref);
  ref.listen<AuthState>(
    authControllerProvider,
    (previous, next) => router.handleAuthState(previous, next),
    fireImmediately: true,
  );
  return router;
});
