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

#### Working with `setState`
- Keep widget state inside the owning `State` class and mutate it only inside `setState` callbacks.
- Schedule side effects (timers, animations, API calls) outside the `build` method to avoid unintended rebuild loops.
- When updating collections like lists or maps, create a new instance or mutate and then wrap the change in `setState` so Flutter knows to rebuild.

#### Debugging UI State
- Add `debugPrint` calls around `setState` to confirm when state transitions happen.
- Use Flutter Inspector's widget rebuild highlights to ensure only the expected widgets redraw.
- If UI is not updating, verify that the widget depends on the mutated state and that `setState` is executed (breakpoints help).

### Widget Hierarchy
```
CompanionChatApp (MaterialApp)
└── ChatScreen (Scaffold)
    ├── AppBar
    └── Column
        ├── Expanded (Message List)
        └── Padding (Input Area)
```

## Widget Development

### Building Reusable Widgets
- Use stateless widgets for pure presentation (for example, `MessageBubble`).
- Promote complex UI fragments into their own widgets to keep `build` methods short.
- Expose behavior through callbacks (for example, `ChatInput.onSend`) so parent widgets control data flow.

### Common Layout Patterns
- **Column + Expanded** keeps the message list flexible while pinning the input field to the bottom.
- **ListView.separated** renders long chat histories efficiently and inserts consistent spacing.
- **Align + ConstrainedBox** shapes each chat bubble while keeping messages readable on tablets and phones.

### Widget Tree Concepts
- Prefer composition: build small widgets and assemble them higher in the tree.
- Pass immutable model objects (like `Message`) down the tree to keep widgets predictable.
- When debugging layout, use `Flutter Inspector`'s Layout Explorer to visualize padding, alignment, and constraints.

## API Integration

### Endpoints Used
- **Create Conversation**: `POST https://uycxfk6mv4.execute-api.eu-west-2.amazonaws.com/dev`
- **Send Message**: `POST https://uycxfk6mv4.execute-api.eu-west-2.amazonaws.com/dev/conversations/{id}/chat`

### HTTP Package
Install dependencies with `flutter pub get` after updating `pubspec.yaml`.

We use the `http` package for API calls:
```dart
import 'package:http/http.dart' as http;
```

### Base URL Configuration
- The API base URL lives in `ApiConfig.baseUrl` so it can be updated in a single place.
- Build endpoint paths with `Uri.parse('${ApiConfig.baseUrl}/conversations/$conversationId/chat')` to keep code readable.
- Keep this config file free of environment-specific logic; later we can swap it for injected settings.

### Api Service
- `ApiService` wraps the http client and exposes `createConversation()` and `sendMessage()` helpers.
- Inject a custom `http.Client` when testing to stub network calls.
- Always close the service (or client) when you are done to release sockets.

### Error Handling
- Failures throw `ApiException` which includes optional status code and raw response.
- Catch `ApiException` in the UI to display actionable messages and log the `details` payload for debugging.
- When wrapping additional endpoints, reuse `_throwForError` so all HTTP error handling stays consistent.

### Network Debugging Tips
- Use `flutter pub global run devtools` to inspect logs and verify request payloads.
- Enable a logging client (e.g., add an `http.Client` wrapper) to print requests/responses during development.
- If calls fail with `ApiException`, check the `details` payload for backend error messages before retrying.

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
