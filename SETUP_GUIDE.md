# Salah Tracker - Setup Guide

## Prerequisites

Before running the app, ensure you have:

1. **Flutter SDK** (latest stable version)
   ```bash
   flutter --version
   ```

2. **Dart SDK** (comes with Flutter)

3. **Platform-specific tools:**
   - **iOS:** Xcode 14+ (macOS only)
   - **Android:** Android Studio with SDK 21+

## Setup Instructions

### Step 1: Install Dependencies

```bash
flutter pub get
```

### Step 2: Generate Hive Type Adapters

The app uses Hive for local storage. You must generate type adapters before running:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

This will generate:
- `lib/features/prayers/models/prayer_log.g.dart`

### Step 3: Platform-Specific Setup

#### iOS Setup

1. Navigate to iOS folder:
   ```bash
   cd ios
   ```

2. Install CocoaPods dependencies:
   ```bash
   pod install
   ```

3. Open Xcode and configure signing:
   ```bash
   open Runner.xcworkspace
   ```
   - Select Runner project
   - Go to Signing & Capabilities
   - Add your Apple Developer account
   - Enable "Automatically manage signing"

4. Return to root directory:
   ```bash
   cd ..
   ```

#### Android Setup

1. Open `android/local.properties` and ensure Flutter SDK path is set:
   ```
   sdk.dir=/path/to/Android/sdk
   flutter.sdk=/path/to/flutter
   ```

2. The app is configured with minimum SDK 21 (Android 5.0)

### Step 4: Run the App

#### iOS (Simulator or Device)

```bash
flutter run -d ios
```

#### Android (Emulator or Device)

```bash
flutter run -d android
```

## Important Notes

### 1. Hive Type Adapters

**CRITICAL:** You MUST run the build_runner command before first launch:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

If you see errors about missing `PrayerLogAdapter`, it means you skipped this step.

### 2. Location Permissions

The app requires location permissions to calculate prayer times:

- **iOS:** Permission dialog will appear on first launch
- **Android:** Permission dialog will appear on first launch

If denied, the app will use default location (Mumbai, India).

### 3. Notification Permissions

The app requires notification permissions for prayer reminders:

- **iOS:** Permission dialog will appear after location permission
- **Android 13+:** Permission dialog will appear on first launch

### 4. Timezone Database

The app initializes timezone data on startup. This is handled automatically in `main.dart`.

## Testing the App

### 1. First Launch

On first launch, the app will:
- Request location permission
- Request notification permission
- Calculate prayer times for today
- Schedule notifications for remaining prayers

### 2. Test Notifications

1. Go to Settings tab
2. Ensure "Prayer Reminders" is enabled
3. Tap "Test Notification"
4. Check your notification center

### 3. Test Quick Logging

1. Wait for a prayer notification (or change device time)
2. Swipe down on the notification
3. Tap Jamaah/Adah/Qalah buttons
4. Open app and verify the prayer was logged

### 4. Test Calendar View

1. Log some prayers for different days
2. Go to Calendar tab
3. Tap on different dates to see details

### 5. Test Statistics

1. Log prayers for a few days
2. Go to Statistics tab
3. View monthly breakdown and charts

## Common Issues

### Issue: "PrayerLogAdapter not found"

**Solution:** Run build_runner:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Issue: Prayer times showing default times

**Solution:**
1. Check location permission is granted
2. Restart the app
3. Check internet connection (for geocoding)

### Issue: Notifications not appearing

**Solution:**
1. Check notification permission is granted
2. Go to Settings > Test Notification
3. Check device notification settings
4. Ensure "Prayer Reminders" is enabled in app Settings

### Issue: Build errors on iOS

**Solution:**
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter pub get
flutter run
```

### Issue: Build errors on Android

**Solution:**
```bash
flutter clean
flutter pub get
cd android
./gradlew clean
cd ..
flutter run
```

## Building for Release

### iOS

```bash
flutter build ios --release
```

Then use Xcode to archive and upload to App Store.

### Android

```bash
flutter build apk --release
```

Or for app bundle:

```bash
flutter build appbundle --release
```

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── app.dart                     # Root widget with navigation
├── core/
│   ├── constants/              # App constants
│   ├── theme/                  # Cupertino theme
│   ├── utils/                  # Utility functions
│   └── providers/              # Core providers
├── features/
│   ├── home/                   # Home screen
│   ├── calendar/               # Calendar view
│   ├── statistics/             # Stats and charts
│   ├── settings/               # Settings screen
│   └── prayers/
│       ├── models/             # Data models
│       ├── services/           # Business logic
│       └── repositories/       # Data access
└── shared/
    └── widgets/                # Reusable widgets
```

## Development Workflow

### Making Changes to Models

If you modify any Hive models (files with `@HiveType`), regenerate adapters:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Adding New Dependencies

1. Add to `pubspec.yaml`
2. Run `flutter pub get`
3. If it's a plugin with native code:
   - iOS: Run `cd ios && pod install`
   - Android: Rebuild the app

### Debugging

```bash
# Run with verbose logging
flutter run -v

# Check for issues
flutter doctor

# Analyze code
flutter analyze
```

## Performance Tips

1. **Use Profile Mode** for testing performance:
   ```bash
   flutter run --profile
   ```

2. **Check app size:**
   ```bash
   flutter build apk --analyze-size
   ```

3. **Monitor memory:**
   - Use Flutter DevTools
   - Enable performance overlay in app

## Next Steps

After successful setup:

1. Test all features thoroughly
2. Customize app icon and splash screen
3. Add Arabic/Urdu localization (optional)
4. Implement additional calculation methods (optional)
5. Add data export/import functionality (optional)

## Support

For issues or questions:
- Check Flutter documentation: https://docs.flutter.dev
- Check package documentation for specific issues
- Review the comprehensive project specification

## Credits

- Built with Flutter & Dart
- Prayer time calculation: `adhan` package
- Local storage: `hive` package
- State management: `riverpod` package
- Charts: `fl_chart` package
- Calendar: `table_calendar` package

---

**May Allah accept your prayers and help you maintain consistency in worship!** 🕌
