# Quick Start - Build & Run

## One-Time Setup (First Time Only)

Run these commands in order:

```bash
# 1. Install Flutter dependencies
flutter pub get

# 2. Generate Hive type adapters (REQUIRED!)
flutter pub run build_runner build --delete-conflicting-outputs

# 3. iOS only: Install CocoaPods
cd ios && pod install && cd ..
```

## Run the App

### iOS

```bash
flutter run -d ios
```

### Android

```bash
flutter run -d android
```

## Quick Troubleshooting

### "PrayerLogAdapter not found" error?

Run:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Build errors on iOS?

Run:
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter run
```

### Build errors on Android?

Run:
```bash
flutter clean
cd android && ./gradlew clean && cd ..
flutter run
```

## That's It!

The app should now launch on your device/simulator.

For detailed setup instructions, see `SETUP_GUIDE.md`.
