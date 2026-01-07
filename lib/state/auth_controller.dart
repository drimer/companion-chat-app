import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/auth_service.dart';

enum AuthStatus { unauthenticated, authenticating, authenticated, failure }

class AuthState {
  const AuthState._({
    required this.status,
    this.tokens,
    this.error,
    this.stackTrace,
  });

  const AuthState.unauthenticated()
    : this._(status: AuthStatus.unauthenticated);

  const AuthState.authenticating() : this._(status: AuthStatus.authenticating);

  const AuthState.authenticated(AuthTokens tokens)
    : this._(status: AuthStatus.authenticated, tokens: tokens);

  const AuthState.failure(Object error, [StackTrace? stackTrace])
    : this._(status: AuthStatus.failure, error: error, stackTrace: stackTrace);

  final AuthStatus status;
  final AuthTokens? tokens;
  final Object? error;
  final StackTrace? stackTrace;

  bool get isAuthenticated =>
      status == AuthStatus.authenticated && tokens != null;
}

class AuthController extends StateNotifier<AuthState> {
  AuthController({AuthService? service})
    : _service = service ?? AuthService.instance,
      super(const AuthState.unauthenticated());

  final AuthService _service;
  Completer<void>? _ongoingRestore;

  Future<void> restoreSession() async {
    if (_ongoingRestore != null) {
      return _ongoingRestore!.future;
    }
    final completer = Completer<void>();
    _ongoingRestore = completer;
    try {
      state = const AuthState.authenticating();
      final tokens = await _service.loadPersistedTokens();
      if (tokens != null) {
        state = AuthState.authenticated(tokens);
        await refreshTokensIfNeeded();
      } else {
        state = const AuthState.unauthenticated();
      }
    } catch (error, stackTrace) {
      state = AuthState.failure(error, stackTrace);
    } finally {
      completer.complete();
      _ongoingRestore = null;
    }
  }

  Future<void> signIn({bool preferEphemeralSession = false}) async {
    state = const AuthState.authenticating();
    try {
      final tokens = await _service.signIn(
        preferEphemeralSession: preferEphemeralSession,
      );
      state = AuthState.authenticated(tokens);
    } catch (error, stackTrace) {
      state = AuthState.failure(error, stackTrace);
    }
  }

  Future<void> refreshTokensIfNeeded() async {
    final current = state.tokens;
    if (current == null) {
      return;
    }
    try {
      final accessToken = await _service.getValidAccessToken();
      if (accessToken != null && state.tokens?.accessToken != accessToken) {
        final refreshedTokens = await _service.loadPersistedTokens();
        if (refreshedTokens != null) {
          state = AuthState.authenticated(refreshedTokens);
        }
      }
    } catch (error, stackTrace) {
      state = AuthState.failure(error, stackTrace);
    }
  }

  Future<void> signOut({bool revokeTokens = true}) async {
    await _service.signOut(revokeTokens: revokeTokens);
    state = const AuthState.unauthenticated();
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) {
    final controller = AuthController();
    // Fire and forget session restoration.
    unawaited(controller.restoreSession());
    return controller;
  },
);
