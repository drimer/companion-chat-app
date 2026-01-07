class AuthProfile {
  const AuthProfile({
    this.subject,
    this.email,
    this.emailVerified,
    this.name,
    this.givenName,
    this.familyName,
    this.picture,
    this.rawClaims = const <String, dynamic>{},
  });

  final String? subject;
  final String? email;
  final bool? emailVerified;
  final String? name;
  final String? givenName;
  final String? familyName;
  final String? picture;
  final Map<String, dynamic> rawClaims;

  String get displayName => name ?? email ?? subject ?? 'Signed in';
  String? get subtitle => email ?? name ?? subject;

  factory AuthProfile.fromClaims(Map<String, dynamic> claims) {
    return AuthProfile(
      subject: claims['sub'] as String?,
      email: claims['email'] as String?,
      emailVerified: claims['email_verified'] as bool?,
      name: claims['name'] as String?,
      givenName: claims['given_name'] as String?,
      familyName: claims['family_name'] as String?,
      picture: claims['picture'] as String?,
      rawClaims: Map<String, dynamic>.unmodifiable(claims),
    );
  }
}
