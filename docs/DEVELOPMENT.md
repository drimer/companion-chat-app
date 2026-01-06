# Development Guide

## Tooling Reference

Use the official Flutter resources for command usage and IDE integration:

- Flutter CLI overview: [https://docs.flutter.dev/reference/flutter-cli](https://docs.flutter.dev/reference/flutter-cli)
- Hot reload and debugging guide: [https://docs.flutter.dev/tools/hot-reload](https://docs.flutter.dev/tools/hot-reload)
- VS Code extension walkthrough: [https://docs.flutter.dev/tools/vs-code](https://docs.flutter.dev/tools/vs-code)

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

### API Troubleshooting
- Confirm the base URL in `ApiConfig` matches the environment you expect before running the app.
- If responses fail to decode, log the raw body to verify the JSON shape still matches the models.
- When initialization fails, `_isInitializing` stays true and the loading indicator persists—restart after restoring connectivity to retry `createConversation()`.
- Simulate offline mode (airplane mode) to confirm the `SnackBar` error path is working, then toggle connectivity back on and resend to resume the flow.

### Integration Checklist
- Conversation bootstrap: `_initialize()` awaits `_ensureConversation()` and primes any server-seeded history before enabling input.
- Message send flow: `_handleSend()` adds the user message, posts the full history, then appends the assistant reply on success.
- Cleanup: dispose scroll controllers and close services in `dispose()` to prevent leaks during hot reload cycles.

## Debugging Tips

### Development Tools
- **Flutter Inspector**: Visual widget tree debugging
- **DevTools**: Performance and memory profiling
- **Debug Console**: Print statements and error logs

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
