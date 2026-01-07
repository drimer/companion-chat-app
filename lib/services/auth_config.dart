class AuthConfig {
  AuthConfig._({
    required this.issuer,
    required this.userPoolId,
    required this.clientId,
    required this.region,
    required this.redirectUri,
    this.postLogoutRedirectUri,
    required this.scopes,
  });

  final String issuer;
  final String userPoolId;
  final String clientId;
  final String region;
  final Uri redirectUri;
  final Uri? postLogoutRedirectUri;
  final List<String> scopes;

  static AuthConfig? _instance;

  static AuthConfig get instance => _instance ??= AuthConfig.fromEnv();

  static void ensureLoaded() {
    instance;
  }

  factory AuthConfig.fromEnv() {
    const issuer = String.fromEnvironment('COGNITO_ISSUER');
    const userPoolId = String.fromEnvironment('COGNITO_USER_POOL_ID');
    const clientId = String.fromEnvironment('COGNITO_CLIENT_ID');
    const region = String.fromEnvironment('COGNITO_REGION');
    const redirectUriRaw = String.fromEnvironment('COGNITO_REDIRECT_URI');
    const logoutRedirectUriRaw = String.fromEnvironment(
      'COGNITO_LOGOUT_REDIRECT_URI',
    );
    const scopesRaw = String.fromEnvironment('COGNITO_SCOPES');

    if (issuer.isEmpty || clientId.isEmpty || redirectUriRaw.isEmpty) {
      throw StateError(
        'Missing Cognito configuration. Ensure COGNITO_ISSUER, COGNITO_CLIENT_ID, '
        'and COGNITO_REDIRECT_URI are provided via --dart-define or env/settings.env.',
      );
    }

    if (userPoolId.isEmpty || region.isEmpty) {
      throw StateError(
        'Missing Cognito configuration. Provide COGNITO_USER_POOL_ID and COGNITO_REGION.',
      );
    }

    final redirectUri = Uri.tryParse(redirectUriRaw);
    if (redirectUri == null || !redirectUri.hasScheme) {
      throw StateError('Invalid COGNITO_REDIRECT_URI: $redirectUriRaw');
    }

    Uri? postLogoutRedirectUri;
    if (logoutRedirectUriRaw.isNotEmpty) {
      postLogoutRedirectUri = Uri.tryParse(logoutRedirectUriRaw);
      if (postLogoutRedirectUri == null) {
        throw StateError(
          'Invalid COGNITO_LOGOUT_REDIRECT_URI: $logoutRedirectUriRaw',
        );
      }
    }

    final scopes = scopesRaw
        .split(RegExp(r'\s+'))
        .where((scope) => scope.isNotEmpty)
        .toList(growable: false);

    if (scopes.isEmpty) {
      throw StateError(
        'Missing Cognito scopes. Provide space-delimited values in COGNITO_SCOPES.',
      );
    }

    return AuthConfig._(
      issuer: issuer,
      userPoolId: userPoolId,
      clientId: clientId,
      region: region,
      redirectUri: redirectUri,
      postLogoutRedirectUri: postLogoutRedirectUri,
      scopes: scopes,
    );
  }
}
