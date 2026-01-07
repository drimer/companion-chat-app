import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:openid_client/openid_client.dart';

import 'auth_config.dart';

const Duration _tokenRefreshTolerance = Duration(seconds: 60);
const String _tokenStorageKey = 'auth.tokens';

class AuthTokens {
  const AuthTokens({
    required this.accessToken,
    required this.expiry,
    this.refreshToken,
    this.idToken,
    this.tokenType,
  });

  final String accessToken;
  final DateTime expiry;
  final String? refreshToken;
  final String? idToken;
  final String? tokenType;

  bool isExpiring({Duration tolerance = Duration.zero, DateTime? now}) {
    final comparisonBase = now ?? DateTime.now().toUtc();
    return expiry.isBefore(comparisonBase.add(tolerance));
  }

  Map<String, dynamic> toJson() => {
    'accessToken': accessToken,
    'expiry': expiry.toIso8601String(),
    'refreshToken': refreshToken,
    'idToken': idToken,
    'tokenType': tokenType,
  };

  static AuthTokens fromJson(Map<String, dynamic> json) {
    final expiry = DateTime.parse(json['expiry'] as String).toUtc();
    final accessToken = json['accessToken'] as String?;
    if (accessToken == null || accessToken.isEmpty) {
      throw const FormatException('Persisted auth tokens missing access token');
    }
    return AuthTokens(
      accessToken: accessToken,
      expiry: expiry,
      refreshToken: json['refreshToken'] as String?,
      idToken: json['idToken'] as String?,
      tokenType: json['tokenType'] as String?,
    );
  }

  static AuthTokens fromTokenResponse(
    TokenResponse response,
    DateTime Function() clock,
  ) {
    final accessToken = response.accessToken;
    if (accessToken == null || accessToken.isEmpty) {
      throw StateError('Token response did not contain an access token.');
    }

    final expiry =
        (response.expiresAt ??
                (response.expiresIn != null
                    ? clock().toUtc().add(response.expiresIn!)
                    : clock().toUtc().add(const Duration(hours: 1))))
            .toUtc();

    return AuthTokens(
      accessToken: accessToken,
      expiry: expiry,
      refreshToken: response.refreshToken,
      idToken: response.idToken?.toCompactSerialization(),
      tokenType: response.tokenType,
    );
  }
}

class AuthService {
  AuthService({FlutterSecureStorage? secureStorage, DateTime Function()? clock})
    : _storage = secureStorage ?? const FlutterSecureStorage(),
      _clock = clock ?? DateTime.now;

  final FlutterSecureStorage _storage;
  final DateTime Function() _clock;

  Issuer? _issuer;
  Client? _client;
  AuthTokens? _tokens;

  static final AuthService instance = AuthService();

  Future<AuthTokens?> loadPersistedTokens() async {
    if (_tokens != null) {
      return _tokens;
    }
    final raw = await _storage.read(key: _tokenStorageKey);
    if (raw == null) {
      return null;
    }
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    _tokens = AuthTokens.fromJson(decoded);
    return _tokens;
  }

  Future<Client> _ensureClient() async {
    if (_client != null) {
      return _client!;
    }
    final config = AuthConfig.instance;
    _issuer ??= await Issuer.discover(Uri.parse(config.issuer));
    _client = Client(_issuer!, config.clientId);
    return _client!;
  }

  Future<AuthTokens?> _ensureTokensLoaded() async {
    if (_tokens != null) {
      return _tokens;
    }
    return loadPersistedTokens();
  }

  Future<AuthTokens> signIn({bool preferEphemeralSession = false}) async {
    final config = AuthConfig.instance;
    final client = await _ensureClient();

    final flow = Flow.authorizationCodeWithPKCE(client, scopes: config.scopes);

    final authUrl = flow.authenticationUri.toString();

    final callbackUrl = await FlutterWebAuth2.authenticate(
      url: authUrl,
      callbackUrlScheme: config.redirectUri.scheme,
      options: FlutterWebAuth2Options(
        windowName: 'Companion Chat Login',
        preferEphemeral: preferEphemeralSession,
      ),
    );

    final responseUri = Uri.parse(callbackUrl);
    final credential = await flow.callback(responseUri.queryParameters);
    final tokenResponse = await credential.getTokenResponse();
    final tokens = AuthTokens.fromTokenResponse(tokenResponse, _clock);

    await _persistTokens(tokens);
    _tokens = tokens;
    return tokens;
  }

  Future<AuthTokens> refreshTokens() async {
    final existing = await _ensureTokensLoaded();
    if (existing == null) {
      throw StateError('Cannot refresh without existing tokens.');
    }
    final refreshToken = existing.refreshToken;
    if (refreshToken == null || refreshToken.isEmpty) {
      throw StateError('No refresh token available to renew access token.');
    }

    final client = await _ensureClient();
    final credential = client.createCredential(
      accessToken: existing.accessToken,
      tokenType: existing.tokenType,
      refreshToken: refreshToken,
      expiresAt: existing.expiry,
      idToken: existing.idToken,
    );

    final response = await credential.getTokenResponse(true);
    final tokens = AuthTokens.fromTokenResponse(response, _clock);
    await _persistTokens(tokens);
    _tokens = tokens;
    return tokens;
  }

  Future<String?> getValidAccessToken() async {
    final tokens = await _ensureTokensLoaded();
    if (tokens == null) {
      return null;
    }
    if (tokens.isExpiring(
      tolerance: _tokenRefreshTolerance,
      now: _clock().toUtc(),
    )) {
      if (tokens.refreshToken == null || tokens.refreshToken!.isEmpty) {
        throw StateError('Access token expired and cannot be refreshed.');
      }
      final refreshed = await refreshTokens();
      return refreshed.accessToken;
    }
    return tokens.accessToken;
  }

  Future<void> signOut({bool revokeTokens = true}) async {
    final tokens = await _ensureTokensLoaded();
    if (tokens != null && revokeTokens) {
      final refreshToken = tokens.refreshToken;
      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          final client = await _ensureClient();
          final credential = client.createCredential(
            accessToken: tokens.accessToken,
            refreshToken: refreshToken,
            tokenType: tokens.tokenType,
            expiresAt: tokens.expiry,
            idToken: tokens.idToken,
          );
          await credential.revoke();
        } catch (_) {
          // Ignore revoke failures to avoid blocking logout.
        }
      }
    }
    await _clearTokens();
  }

  Future<void> _persistTokens(AuthTokens tokens) async {
    await _storage.write(
      key: _tokenStorageKey,
      value: jsonEncode(tokens.toJson()),
    );
  }

  Future<void> _clearTokens() async {
    await _storage.delete(key: _tokenStorageKey);
    _tokens = null;
  }
}
