# Development Guide

## Common Flutter Commands

### Development
- `flutter run` - Run in debug mode
- `flutter run -d <device>` - Run on specific device
- `flutter run --release` - Run in release mode (optimized)

### Hot Reload
- `r` - Hot reload (apply changes without restarting)
- `R` - Hot restart (restart the app completely)
- `q` - Quit the app

### Building
- `flutter build apk` - Build Android APK
- `flutter build windows` - Build Windows executable
- `flutter build web` - Build for web

### Debugging
- `flutter logs` - View device logs
- `flutter analyze` - Static code analysis
- `flutter test` - Run unit tests

### Dependencies
- `flutter pub get` - Install dependencies
- `flutter pub upgrade` - Upgrade dependencies
- `flutter pub deps` - Show dependency tree

### Cleanup
- `flutter clean` - Clean build artifacts
- `flutter pub cache repair` - Repair pub cache

## Project Architecture

### Folder Structure
```
lib/
├── main.dart           # App entry point
├── models/             # Data models (Message, Conversation, etc.)
├── services/           # Business logic (API calls, storage)
├── screens/            # Full-screen UI components
└── widgets/            # Reusable UI components
```

### State Management
This project uses Flutter's built-in `setState` for state management.

### Widget Hierarchy
```
CompanionChatApp (MaterialApp)
└── ChatScreen (Scaffold)
    ├── AppBar
    └── Column
        ├── Expanded (Message List)
        └── Padding (Input Area)
```

## API Integration

### Endpoints Used
- **Create Conversation**: `POST https://uycxfk6mv4.execute-api.eu-west-2.amazonaws.com/dev`
- **Send Message**: `POST https://uycxfk6mv4.execute-api.eu-west-2.amazonaws.com/dev/conversations/{id}/chat`

### HTTP Package
We use the `http` package for API calls:
```dart
import 'package:http/http.dart' as http;
```

### Error Handling
All API calls are wrapped in try-catch blocks with meaningful error messages.

## Debugging Tips

### Common Issues
1. **Import errors**: Check file paths and ensure files exist
2. **State not updating**: Make sure to call `setState()`
3. **API errors**: Check network connectivity and API endpoints
4. **Build errors**: Run `flutter clean` and `flutter pub get`

### Development Tools
- **Flutter Inspector**: Visual widget tree debugging
- **DevTools**: Performance and memory profiling
- **Debug Console**: Print statements and error logs

### Hot Reload Best Practices
- Hot reload works for UI changes
- Hot restart needed for:
  - App initialization code
  - Method signatures
  - Static variables

## Testing

### Running Tests
```bash
flutter test                    # Run all tests
flutter test test/unit/         # Run unit tests
flutter test test/widget/       # Run widget tests
```

### Test Structure
```
test/
├── unit/           # Business logic tests
├── widget/         # UI component tests
└── integration/    # End-to-end tests
```

## Performance

### Best Practices
- Use `const` constructors when possible
- Avoid rebuilding widgets unnecessarily
- Use `ListView.builder` for long lists
- Profile with DevTools

### Common Performance Issues
- Large widget trees
- Expensive build methods
- Memory leaks from listeners
- Blocking the UI thread
