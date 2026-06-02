# Voice Screen App 🎙️🔒

A premium, enterprise-level Voice Lock and Unlock application built with Flutter and Dart. This application provides robust, offline-capable voice authentication featuring an Apple-inspired glassmorphism design language and highly dynamic security controls.

## ✨ Features

- **Advanced Voice Security**: Set custom voice commands for locking and unlocking your device.
- **Dynamic Sensitivity Controls**: Adjust the voice match confidence threshold (0-100%) dynamically. Higher percentages enforce stricter biometric security.
- **Premium Apple-Inspired UI**: Beautiful glassmorphism, dynamic waveform animations, blur effects, and smooth micro-interactions throughout the app.
- **Robust Backup Authentication**: Enforced fallback methods (PIN, Pattern, or Password) when voice recognition fails. 
- **Offline Capable Architecture**: Designed to utilize offline machine learning models (Vosk for Speech-to-Text and TFLite for speaker embedding verification).
- **Background Listening & Services**: Dedicated configuration for continuous voice detection when the screen is locked, including auto-restart capabilities.
- **Strict Data Deletion**: Completely wipe your biometric voice profile and custom commands securely with a single action.

## 🛠️ Technology Stack

- **Framework**: [Flutter](https://flutter.dev/) (Dart)
- **Architecture**: Clean Architecture paradigm
- **State Management**: Stateful widgets & SharedPreferences for local configuration
- **UI/UX**: `flutter_animate`, `google_fonts`
- **Core AI**: (Designed for integration with Vosk offline STT and TensorFlow Lite)

## 📱 Screenshots & UI

The application boasts a cutting-edge interface:
- **Splash Screen**: Animated minimalist purple waveform on a clean background.
- **Home Screen**: Floating dynamic microphone dashboard that reacts to the Master Lock state.
- **Settings**: 11-item ordered Apple-style glassmorphism list, including dedicated native configuration intents.

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (`>=3.0.0`)
- Android Studio / Xcode
- Android SDK 21+ (For Android deployment)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/DarshanAjudiya7/voice-screen-flutter-app.git
   cd voice-screen-flutter-app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run
   ```

## ⚙️ System Configuration Requirements (Android)

To utilize the full capabilities of the Voice Screen App on Android, specific system permissions and configurations must be granted:
- **Microphone & Foreground Service**: Required for continuous background voice detection.
- **Battery Optimization**: You must exclude the app from Android's aggressive Battery Optimization via the in-app settings portal to ensure the background service is not killed by the OS.

## 📁 Project Structure

The project follows a standard Flutter architectural pattern emphasizing separation of concerns:
```
lib/
├── core/
│   ├── theme/          # App-wide theming, colors, and fonts
│   └── services/       # Core service locators
├── presentation/
│   ├── splash/         # Animated startup experience
│   ├── onboarding/     # Voice registration & Terms
│   ├── home/           # Main dashboard and mic toggle
│   ├── lockscreen/     # Voice verification & backup auth UI
│   └── settings/       # Master config, battery intents, and thresholds
└── main.dart           # Application entry point
```

## 🔒 Privacy & Security

Your biometric data is processed entirely on your device. The application does not rely on third-party cloud APIs (like Google Speech-to-Text) for the core lock/unlock verification, ensuring your voice embeddings remain private and secure.

---
*Built with ❤️ using Flutter.*
