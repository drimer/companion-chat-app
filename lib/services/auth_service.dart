import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:openid_client/openid_client.dart';

import '../models/auth_profile.dart';
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
      final errorCode = response['error'] as String?;
      final errorDescription = response['error_description'] as String?;
      throw StateError(
        'Token response did not contain an access token.'
        '${errorCode != null ? ' Error: $errorCode.' : ''}'
        '${errorDescription != null ? ' Description: $errorDescription.' : ''}',
      );
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
    flow.redirectUri = config.redirectUri;

    final authUrl = flow.authenticationUri.toString();

    final options = FlutterWebAuth2Options(
      windowName: 'Companion Chat Login',
      preferEphemeral: preferEphemeralSession,
      intentFlags: preferEphemeralSession
          ? ephemeralIntentFlags
          : defaultIntentFlags,
    );

    final callbackUrl = await FlutterWebAuth2.authenticate(
      url: authUrl,
      callbackUrlScheme: config.redirectUri.scheme,
      options: options,
    );

    final responseUri = Uri.parse(callbackUrl);
    final params = Map<String, String>.from(responseUri.queryParameters);
    if (responseUri.fragment.isNotEmpty) {
      params.addAll(Uri.splitQueryString(responseUri.fragment));
    }
    final credential = await flow.callback(params);
    final tokenResponse = await credential.getTokenResponse();
    final tokens = AuthTokens.fromTokenResponse(tokenResponse, _clock);

    await _persistTokens(tokens);
    _tokens = tokens;
    return tokens;
  }

  Future<AuthProfile?> getCurrentProfile() async {
    final tokens = await _ensureTokensLoaded();
    if (tokens == null) {
      return null;
    }
    return parseIdToken(tokens.idToken);
  }

  AuthProfile? parseIdToken(String? idToken) {
    if (idToken == null || idToken.isEmpty) {
      return null;
    }
    try {
      final claims = _decodeJwtPayload(idToken);
      return AuthProfile.fromClaims(claims);
    } catch (_) {
      return null;
    }
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

  Future<String?> getValidIdToken() async {
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
    return tokens.idToken;
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
    await _performHostedLogout();
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

  Map<String, dynamic> _decodeJwtPayload(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw const FormatException(
        'Invalid ID token: unexpected number of segments.',
      );
    }
    final normalized = _normalizeBase64(parts[1]);
    final decoded = base64Url.decode(normalized);
    final payload = utf8.decode(decoded);
    final claims = jsonDecode(payload);
    if (claims is! Map<String, dynamic>) {
      throw const FormatException('Invalid ID token payload.');
    }
    return claims;
  }

  String _normalizeBase64(String input) {
    final remainder = input.length % 4;
    if (remainder == 0) {
      return input;
    }
    if (remainder == 1) {
      throw const FormatException('Invalid base64url string length.');
    }
    final padding = 4 - remainder;
    final buffer = StringBuffer(input);
    for (var i = 0; i < padding; i++) {
      buffer.write('=');
    }
    return buffer.toString();
  }

  Future<void> _performHostedLogout() async {
    final config = AuthConfig.instance;
    final client = await _ensureClient();
    final authorizationEndpoint = client.issuer.metadata.authorizationEndpoint;
    if (authorizationEndpoint == null) {
      return;
    }

    final authorizeUri = authorizationEndpoint;
    final logoutUri = Uri(
      scheme: authorizeUri.scheme,
      host: authorizeUri.host,
      port: authorizeUri.hasPort ? authorizeUri.port : null,
      path: '/logout',
      queryParameters: <String, String>{
        'client_id': config.clientId,
        'logout_uri': config.redirectUri.toString(),
      },
    );

    final options = FlutterWebAuth2Options(
      windowName: 'Companion Chat Logout',
      intentFlags: defaultIntentFlags,
    );

    try {
      await FlutterWebAuth2.authenticate(
        url: logoutUri.toString(),
        callbackUrlScheme: config.redirectUri.scheme,
        options: options,
      );
    } catch (_) {
      // Ignore logout flow failures; hosted session may persist as a result.
    }
  }
}
