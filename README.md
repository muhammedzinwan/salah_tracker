# Salah Tracker

Islamic Prayer Tracker App - Track your daily prayers with Jamaah, Adah, and Qalah status.

## Features

- 🕌 Automatic prayer time calculation based on location
- 🔔 Smart notifications with quick-log actions
- 📊 Monthly statistics and insights
- 📅 Calendar view of prayer history
- 💾 Offline-first with local storage
- 🎨 Beautiful Cupertino (iOS-style) UI

## Getting Started

### Prerequisites

- Flutter SDK (latest stable)
- Dart SDK (latest stable)
- iOS: Xcode 14+ / Android: Android Studio

### Installation

```bash
# Install dependencies
flutter pub get

# Generate Hive type adapters
flutter pub run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

## Tech Stack

- **Flutter & Dart** - Cross-platform framework
- **Riverpod** - State management
- **Hive** - Local NoSQL database
- **Adhan** - Prayer time calculation
- **Flutter Local Notifications** - Push notifications

## Project Structure

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/
│   ├── theme/
│   └── utils/
├── features/
│   ├── home/
│   ├── calendar/
│   ├── statistics/
│   ├── settings/
│   └── prayers/
└── shared/
    └── widgets/
```

## License

Private project - All rights reserved
