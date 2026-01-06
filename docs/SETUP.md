# Development Environment Setup

## Flutter Installation

### Windows Setup

1. **Download Flutter SDK**
   - Go to https://docs.flutter.dev/get-started/install/windows
   - Download the latest stable release
   - Extract to a permanent location (e.g., `C:\flutter`)

2. **Add Flutter to PATH**
   - Open System Properties > Environment Variables
   - Add `C:\flutter\bin` to your PATH variable

3. **Install Required Tools**
   - **Git**: Download from https://git-scm.com/download/win
   - **Android Studio**: Download from https://developer.android.com/studio
   - **VS Code**: Download from https://code.visualstudio.com/

4. **VS Code Extensions**
   - Flutter (includes Dart support)
   - Android iOS Emulator

5. **Verify Installation**
   ```bash
   flutter doctor
   ```

   ## VS Code Debugging

   - Open the project in VS Code.
   - Go to **Run and Debug** and select **Flutter Windows** to launch the app using the predefined configuration (equivalent to `flutter run -d windows`).
   - Use the standard debug controls for hot reload, breakpoints, and logging.

## Android Development Setup

1. **Install Android Studio**
   - Follow the installation wizard
   - Install Android SDK and build tools

2. **Accept Android Licenses**
   ```bash
   flutter doctor --android-licenses
   ```

3. **Create Virtual Device**
   - Open Android Studio
   - Go to Tools > AVD Manager
   - Create a new virtual device (recommended: Pixel 5 with API 30+)

4. **Test Emulator**
   ```bash
   flutter emulators
   flutter emulators --launch <emulator_name>
   ```

## Windows Desktop Development

Windows desktop support is included with Flutter by default on Windows.

## Verification

Run these commands to verify your setup:

```bash
flutter doctor -v
flutter create test_app
cd test_app
flutter run
```

All checkmarks should be green, and the test app should run successfully.

## Environment Configuration

1. Copy `env/settings.env.template` to `env/settings.env` (git ignored) and replace the placeholder value:
   ```text
   API_BASE_URL=http://localhost:4000
   # API_BASE_URL=https://example.your-domain.com
   ```
   Lines starting with `#` are treated as comments, so keep alternative values handy without changing the active one.
2. Update `.vscode/launch.json` so the Android `deviceId` matches your connected device; the Windows entry is preconfigured.
3. Launch the app with the shared file:
   - Windows desktop: `flutter run -d windows --dart-define-from-file=env/settings.env`
   - Android device (auto-detected when only one is connected): `flutter run --dart-define-from-file=env/settings.env`
4. Building also uses the same flag, for example: `flutter build apk --dart-define-from-file=env/settings.env`.

Whichever command you use (VS Code or terminal), always supply `--dart-define-from-file=env/settings.env` so the app receives the base URL at runtime.

## Installing Dependencies

From the project root:

```bash
flutter pub get
```

Run this command any time `pubspec.yaml` changes so packages stay in sync.

## Troubleshooting

- **"flutter: command not found"**: Ensure the Flutter SDK path is on your system PATH.
- **Build errors after pulling changes**: Run `flutter clean` followed by `flutter pub get`.
- **No devices found**: Start an Android emulator or connect a physical device; for Windows ensure desktop support is enabled (`flutter config --enable-windows-desktop`).
- **General diagnostics**: `flutter doctor` highlights missing components or permission issues.
