# Companion Chat App

A Flutter mobile app for chatting with an AI language exchange partner.

## Prerequisites

- Flutter SDK 3.0+
- Android Studio or VS Code with Flutter extension
- Android device/emulator or Windows desktop environment

## Quick Start

1. Install dependencies:
   ```bash
   flutter pub get
   ```

2. Run the app:
   ```bash
   flutter run
   ```
   
   For specific platforms:
   ```bash
   flutter run -d windows    # Run on Windows desktop
   flutter run -d android    # Run on Android device/emulator
   flutter run -d chrome     # Run in web browser
   ```

   VS Code users can open **Run and Debug** and start the **Flutter Windows** configuration to launch the desktop build without typing the command.

## Development

- `flutter run` - Run in debug mode
- `r` - Hot reload (apply changes without restarting)
- `R` - Hot restart (restart the app)
- `q` - Quit the app

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
├── services/                 # API and storage services
├── screens/                  # UI screens
│   └── chat_screen.dart      # Main chat interface
└── widgets/                  # Reusable UI components
```

## Implementation Status

See [IMPLEMENTATION_CHECKLIST.md](IMPLEMENTATION_CHECKLIST.md) for detailed implementation progress.

## Troubleshooting

### Common Issues

- **"flutter: command not found"**: Make sure Flutter SDK is added to your PATH
- **Build errors**: Run `flutter clean` then `flutter pub get`
- **No devices found**: For Android, start an emulator. For Windows, make sure Windows desktop support is enabled

### Getting Help

Run `flutter doctor` to check your Flutter installation and see what components need attention.
