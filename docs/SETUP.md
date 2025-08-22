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
