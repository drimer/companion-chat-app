# Cognito SSO Integration Plan

- [ ] Add dependencies in `pubspec.yaml`: include `flutter_appauth`, `flutter_secure_storage`, and `flutter_riverpod` (or chosen state manager); run `flutter pub get` and adjust Android/iOS Gradle settings if build errors appear.
- [ ] Configure platform redirect handling: register redirect URI in Cognito; add `CompanionChatRedirectActivity` intent filter in `android/app/src/main/AndroidManifest.xml`; register URL type `companionchat` in `ios/Runner/Info.plist`.
- [ ] Create `AuthConfig` class in `lib/services/auth_config.dart` with factory `AuthConfig.fromEnv()` reading issuer/client/redirect/scopes from environment, loaded before `runApp`.
- [ ] Implement `AuthService` in `lib/services/auth_service.dart` with methods `signIn()`, `signOut()`, `refreshTokens()`, and `getValidAccessToken()`, leveraging `flutter_appauth` and storing tokens via `flutter_secure_storage`.
- [ ] Add `AuthController` (Riverpod `StateNotifier` or equivalent) in `lib/state/auth_controller.dart` exposing states `AuthState.unauthenticated`, `AuthState.authenticating`, `AuthState.authenticated(tokenSet)`, calling `AuthService` methods.
- [ ] Introduce `LoginScreen` widget in `lib/screens/login_screen.dart` that listens to `AuthController`, drives `AuthService.signIn()`, and displays errors/status; set it as the initial route in `lib/main.dart`.
- [ ] Wrap protected navigation in `lib/app_router.dart` (or existing navigator) with a guard `AuthRouteGuard` that checks `AuthController` before presenting screens; ensure sign-out clears navigation stack.
- [ ] Display user profile info in `lib/screens/home_screen.dart` (or equivalent) by decoding ID token via helper `parseIdToken` in `AuthService`; add logout button calling `AuthService.signOut()`.
- [ ] Integrate API calls: update `lib/services/api_client.dart` (or equivalent) to call `AuthService.getValidAccessToken()` and attach the bearer token to every request; handle 401 by triggering controller sign-out.
- [ ] Write widget/unit tests: e.g., `test/services/auth_service_test.dart` for token lifecycle, `test/state/auth_controller_test.dart` for state transitions, and integration tests in `integration_test/auth_flow_test.dart` covering login/logout.
- [ ] Update docs (`docs/SETUP.md`, `docs/DEVELOPMENT.md`) with app auth setup, required environment variables, and testing steps; ensure CI scripts load required env vars without committing secrets.
