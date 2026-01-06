# Flutter Companion Chat App Implementation Checklist

## Project Structure Overview

```
companion-chat-app/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── models/                   # Data models
│   │   ├── conversation.dart
│   │   ├── message.dart
│   │   └── chat_response.dart
│   ├── services/                 # API services
│   │   └── api_service.dart
│   ├── screens/                  # UI screens
│   │   └── chat_screen.dart
│   └── widgets/                  # Reusable UI components
│       ├── message_bubble.dart
│       └── chat_input.dart
├── pubspec.yaml                  # Dependencies
├── README.md                     # Developer setup and run instructions
└── docs/                         # Documentation
    ├── SETUP.md                  # Development environment setup
    └── DEVELOPMENT.md            # Development workflow and commands
```

## Phase 0: Development Environment Setup

### Step 0.1: Install Flutter SDK
- [x] Follow official Flutter installation guide for Windows
- [x] Download Flutter SDK and add to PATH
- [x] Install required tools: Git, Android Studio, VS Code with Flutter extension
- [x] Run `flutter doctor` to verify installation

### Step 0.2: Set Up Android Development
- [x] Install Android Studio
- [x] Install Android SDK and create virtual device (AVD)
- [x] Accept Android licenses with `flutter doctor --android-licenses`
- [x] Test emulator launches correctly

### Step 0.3: Create Development Documentation
- [x] Update `README.md` with developer setup instructions
- [x] Create `docs/SETUP.md` with detailed environment setup steps
- [x] Create `docs/DEVELOPMENT.md` with common Flutter commands
- [x] Document how to run on emulator and physical devices

### 🧪 Test Phase 0:
- [x] Run `flutter doctor` and verify all checkmarks are green
- [x] Launch Android emulator successfully
- [x] Create and run a test Flutter app (`flutter create test_app`)
- [x] Verify VS Code Flutter extension works (syntax highlighting, hot reload)

## Phase 1: Project Setup and Basic UI

### Step 1.1: Initialize Flutter Project
- [x] Run `flutter create .` in the companion-chat-app directory

### Step 1.2: Create Basic App Structure
- [x] Set up main.dart with MaterialAppí
- [x] Create basic folder structure (lib/screens/)
- [x] Run `flutter run` to verify setup works
- [x] Update `README.md` with basic run instructions

### Step 1.3: Create Empty Chat Screen Layout
- [x] Create `chat_screen.dart` with basic AppBar
- [x] Add empty ListView for messages
- [x] Add placeholder Container at bottom for input (no functionality yet)
- [x] Wire up to main.dart and test visual appearance

### Step 1.4: Document Development Workflow
- [x] Add "How to Run" section to `README.md`
- [x] Document `flutter run`, `flutter hot reload` commands
- [x] Add troubleshooting section for common issues
- [x] Document how to run on different devices/emulators

### 🧪 Test Phase 1:
- [x] Run `flutter run` on Android/iOS emulator or physical device
- [x] Verify app launches without errors
- [x] Check that you see an empty chat screen with AppBar title
- [x] Confirm the basic layout looks like a chat app
- [x] Test hot reload functionality (make a small UI change and see it update)

## Phase 2: Basic Message Display

### Step 2.1: Create Static Message Model
- [x] Create simple `Message` class in `lib/models/message.dart`
- [x] Include: role (String), content (String)
- [x] No JSON serialization yet, just basic constructor

### Step 2.2: Create Message Bubble Widget
- [x] Create `message_bubble.dart` widget
- [x] Style user messages (right-aligned, blue)
- [x] Style AI messages (left-aligned, grey)
- [x] Test with hardcoded sample messages

### Step 2.3: Display Sample Messages
- [x] Add 2-3 hardcoded messages to chat screen
- [x] Verify message bubbles render correctly
- [x] Test scrolling behavior

### Step 2.4: Document UI Development
- [x] Add section to DEVELOPMENT.md about widget development
- [x] Document Flutter widget tree concepts
- [x] Add examples of common Flutter layouts used in the project

### 🧪 Test Phase 2:
- [ ] Hot reload and verify hardcoded messages appear
- [ ] Check user messages are blue and right-aligned
- [ ] Check AI messages are grey and left-aligned
- [ ] Test scrolling up and down in the message list
- [ ] Verify messages look like typical chat bubbles

## Phase 3: Basic Input UI

### Step 3.1: Create Chat Input Widget
- [x] Create `chat_input.dart` with TextField and IconButton
- [x] Position at bottom of screen
- [x] No functionality yet, just visual layout
- [x] Test that it looks like a proper chat input

### Step 3.2: Add Input Interaction
- [x] Add TextEditingController
- [x] Handle send button press (just print message for now)
- [x] Clear input field after send
- [x] Add basic validation (don't send empty messages)

### Step 3.3: Add Messages to List Locally
- [x] Modify chat screen to maintain List<Message>
- [x] Add user messages to list when send is pressed
- [x] Add mock AI response after 1-second delay
- [x] Verify chat updates properly

### Step 3.4: Document State Management
- [x] Add section to DEVELOPMENT.md about Flutter state management
- [x] Document setState pattern used in the project
- [x] Add debugging tips for UI state issues

### 🧪 Test Phase 3:
- [ ] Type a message and verify the input field works
- [ ] Press send button and check message appears in chat
- [ ] Verify input field clears after sending
- [ ] Check that a mock AI response appears after 1 second
- [ ] Test that empty messages are not sent
- [ ] Verify new messages appear at the bottom and auto-scroll

## Phase 4: API Integration Setup

### Step 4.1: Add HTTP Dependency
- [x] Update `pubspec.yaml` with `http` package
- [x] Run `flutter pub get`
- [x] Document dependency management in DEVELOPMENT.md

### Step 4.2: Create Conversation Model
- [x] Define `Conversation` class matching API response
- [x] Include JSON serialization (fromJson/toJson)
- [ ] Test JSON parsing with sample data

### Step 4.3: Create Chat Response Model
- [x] Define `ChatResponse` class for API responses (it only contains a field called "message", which will be used to store a new Message with role "assistant")
- [x] Include JSON serialization
- [ ] Test JSON parsing

### Step 4.4: Document API Integration
- [x] Add section to DEVELOPMENT.md about HTTP requests in Flutter
- [x] Document the API endpoints being used
- [x] Add examples of JSON model classes

### 🧪 Test Phase 4:
- [ ] Run `flutter pub get` successfully
- [ ] Create unit tests or debug prints to verify JSON parsing works
- [ ] Test `Conversation.fromJson()` with sample API response
- [ ] Test `ChatResponse.fromJson()` with sample API response
- [ ] Verify no compilation errors

## Phase 5: Basic API Service

### Step 5.1: Create API Service Class
- [x] Create `api_service.dart` with base URL constant
- [x] Add `createConversation()` method
- [ ] Test API call in isolation (print response)

### Step 5.2: Add Chat API Method
- [x] Add `sendMessage(conversationId, message)` method
- [x] Include proper headers and request body
- [ ] Test both API methods work

### Step 5.3: Add Error Handling
- [x] Wrap API calls in try-catch
- [x] Handle network errors gracefully
- [x] Return meaningful error messages

### Step 5.4: Document API Service
- [x] Add API service documentation to DEVELOPMENT.md
- [x] Document error handling patterns
- [x] Add network debugging tips for development

### 🧪 Test Phase 5:
- [ ] Test `createConversation()` API call manually (print response)
- [ ] Verify you get back a valid conversation ID
- [ ] Test `sendMessage()` with the conversation ID
- [ ] Verify you get back an AI response
- [ ] Test error handling with invalid URLs or network disconnection
- [ ] Check that error messages are meaningful

## Phase 6: Connect API to UI

### Step 6.1: Integrate Conversation Creation
- [x] Modify chat screen to call API on first message
- [x] Store conversation ID in widget state
- [x] Show loading indicator during API calls

### Step 6.2: Integrate Chat API
- [x] Replace mock AI responses with real API calls
- [x] Handle loading states properly
- [x] Display API errors to user

### Step 6.3: Test Complete Flow
- [x] Test first message (creates conversation + gets response)
- [x] Test subsequent messages (uses existing conversation)
- [x] Verify error handling works

### Step 6.4: Document Integration Patterns
- [x] Add section about connecting services to UI
- [x] Document async/await patterns used
- [x] Add troubleshooting guide for API integration issues

### 🧪 Test Phase 6:
- [x] Send your first message and verify conversation is created
- [x] Check that you get a real AI response (in Japanese for language exchange)
- [x] Send a second message and verify it uses the same conversation
- [x] Test with airplane mode to verify error handling
- [x] Verify loading indicators appear during API calls
- [x] Test that the app recovers gracefully from API errors

## Phase 7: Polish and Error Handling

### Step 7.1: Improve Loading States
- [ ] Add typing indicator for AI responses
- [ ] Disable send button during API calls
- [ ] Better visual feedback

### Step 7.2: Enhanced Error Handling
- [ ] Retry failed API calls
- [ ] Handle offline scenarios
- [ ] User-friendly error messages

### Step 7.3: Finalize Documentation
- [ ] Add deployment section (how to build APK/release)
- [ ] Create troubleshooting guide for common issues
- [ ] Document testing procedures

### 🧪 Test Phase 7:
- [ ] Verify typing indicators work properly
- [ ] Test retry functionality when network is flaky
- [ ] Verify graceful handling of offline scenarios
- [ ] Test auto-scroll behavior with long conversations
- [ ] Verify the app feels polished and responsive
- [ ] Do a complete end-to-end test of the chat experience
- [ ] Verify documentation is complete and accurate

## API Endpoints Reference

- **Create Conversation**: `POST https://uycxfk6mv4.execute-api.eu-west-2.amazonaws.com/dev`
- **Send Message**: `POST https://uycxfk6mv4.execute-api.eu-west-2.amazonaws.com/dev/conversations/{conversation_id}/chat`

### Expected API Responses

**Create Conversation Response:**
```json
{
    "id": "3ab51ed5-6fed-4f4a-9cfd-e1a3c1695fe0",
    "system_prompt": "You are a language exchange student who speaks Japanese natively and wants to learn English. I am learning Japanese, and will help you improve your English as we speak.",
    "user_id": "default-user-123",
    "created_at": "2025-08-22T09:32:18.767264Z"
}
```

**Chat Response:**
```json
{
    "message": "よかったです！私の好きな色は青です。あなたの好きな色は何ですか？",
    "usage": {
        "prompt_tokens": 169,
        "completion_tokens": 23,
        "total_tokens": 192
    }
}
```

## Documentation Templates

### README.md Structure
```markdown
# Companion Chat App

A Flutter mobile app for chatting with an AI language exchange partner.

## Prerequisites
- Flutter SDK 3.0+
- Android Studio or VS Code
- Android device/emulator

## Quick Start
1. `flutter pub get`
2. `flutter run`

## Development
See [docs/DEVELOPMENT.md] for detailed development guide.

## Troubleshooting
[Common issues and solutions]
```

### DEVELOPMENT.md Structure
```markdown
# Development Guide

## Common Commands
- `flutter run` - Run in debug mode
- `r` - Hot reload
- `R` - Hot restart
- `flutter build apk` - Build release APK

## Architecture
[Project structure explanation]

## API Integration
[How the app connects to the companion-chat API]

## Debugging
[How to debug common issues]
```

---

## Progress Tracking

**Overall Progress:** 2/7 phases complete

- [x] **Phase 0:** Development Environment Setup
- [x] **Phase 1:** Project Setup and Basic UI
- [ ] **Phase 2:** Basic Message Display
- [ ] **Phase 3:** Basic Input UI
- [ ] **Phase 4:** API Integration Setup
- [ ] **Phase 5:** Basic API Service
- [ ] **Phase 6:** Connect API to UI
- [ ] **Phase 7:** Polish and Error Handling

**Next Steps:** Start with Phase 2 - Basic Message Display
