# 🚀 Salah Tracker - Quick Start Guide

## ⚡ TL;DR - Get Running in 3 Steps

```bash
# 1. Get dependencies
flutter pub get

# 2. Generate Hive adapters (CRITICAL - Don't skip!)
flutter pub run build_runner build --delete-conflicting-outputs

# 3. Run the app
flutter run
```

---

## 📋 What You Need

- Flutter SDK (latest stable)
- For iOS: Xcode 14+ (macOS only)
- For Android: Android Studio + SDK

Check if you're ready:
```bash
flutter doctor
```

---

## 🎯 Complete Setup (First Time)

### Step 1: Clone/Download (Already Done ✓)

You're already in the project directory!

### Step 2: Install Dependencies

```bash
flutter pub get
```

### Step 3: Generate Type Adapters (**CRITICAL**)

```bash
flutter pub run build_runner build --delete-conflating-outputs
```

❗ **Why this matters:** The app uses Hive for storage. Without this step, you'll get "PrayerLogAdapter not found" errors.

### Step 4: Platform-Specific Setup

#### For iOS:

```bash
cd ios
pod install
cd ..
```

#### For Android:

Nothing extra needed! Just make sure you have Android SDK installed.

---

## ▶️ Run the App

### Option 1: Using Command Line

```bash
# iOS
flutter run -d ios

# Android
flutter run -d android

# Or just let Flutter choose
flutter run
```

### Option 2: Using IDE

**VS Code:**
1. Press F5 or click "Run and Debug"
2. Select your device

**Android Studio:**
1. Select device from dropdown
2. Click the green play button

---

## 🧪 Testing the App

Once the app launches:

### 1. First Launch Experience

The app will ask for:
1. **Location Permission** - For accurate prayer times
2. **Notification Permission** - For prayer reminders

✅ Grant both for full functionality

### 2. Home Screen

You should see:
- Next prayer card with countdown
- Today's 5 prayers list
- Monthly statistics

### 3. Test Notification

1. Go to **Settings** tab (bottom right)
2. Ensure "Prayer Reminders" is **ON**
3. Tap **"Test Notification"**
4. Check your notification center

### 4. Test Quick Logging

**Method 1: From Home Screen**
1. Tap any prayer in today's list
2. Select Jamaah/Adah/Qalah
3. Prayer gets logged ✓

**Method 2: From Notification** (The Cool Part!)
1. Wait for a prayer time notification (or change device time for testing)
2. Swipe down on the notification
3. Tap Jamaah/Adah/Qalah button
4. Prayer gets logged WITHOUT opening the app! 🎉

### 5. Calendar View

1. Tap **Calendar** tab
2. Tap on any date
3. See detailed prayer breakdown

### 6. Statistics

1. Tap **Statistics** tab
2. View beautiful charts and breakdowns

---

## 🎨 What You'll See

### Home Screen
```
┌─────────────────────────────────┐
│  Salah Tracker        Settings  │
├─────────────────────────────────┤
│ ╔═══════════════════════════╗   │
│ ║   NEXT PRAYER: DHUHR     ║   │
│ ║   🕐 12:34 PM            ║   │
│ ║   ⏱️  2h 15m remaining    ║   │
│ ║   [ 📝 Quick Log ]       ║   │
│ ╚═══════════════════════════╝   │
│                                 │
│ TODAY'S PRAYERS                 │
│ ✓ Fajr    [Jamaah]   5:30 AM   │
│ ⏳ Dhuhr   [Log Now]  12:34 PM  │
│ ⚪ Asr     Pending    3:45 PM   │
│ ⚪ Maghrib Pending    6:12 PM   │
│ ⚪ Isha    Pending    7:30 PM   │
│                                 │
│ THIS MONTH (OCTOBER)            │
│ 🟢 Jamaah:  45% (67/150)       │
│ 🟡 Adah:    30% (45/150)       │
│ 🟠 Qalah:   15% (22/150)       │
│ 🔴 Missed:  10% (16/150)       │
└─────────────────────────────────┘
```

---

## 🐛 Common Issues & Fixes

### "PrayerLogAdapter not found"

**Problem:** You skipped Step 3
**Fix:**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Prayer times showing default Mumbai times

**Problem:** Location permission denied
**Fix:**
1. Grant location permission in device settings
2. Restart app

### Notifications not working

**Fix:**
1. Settings → Ensure "Prayer Reminders" is ON
2. Check device notification permissions
3. Tap "Test Notification" to verify

### iOS build fails

**Fix:**
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter run
```

### Android build fails

**Fix:**
```bash
flutter clean
cd android
./gradlew clean
cd ..
flutter run
```

---

## 📱 App Features

### ✅ Implemented & Working

- [x] Automatic prayer time calculation (based on your location)
- [x] 5 daily prayer tracking (Fajr, Dhuhr, Asr, Maghrib, Isha)
- [x] 4 status types (Jamaah, Adah, Qalah, Not Performed)
- [x] Quick log from home screen
- [x] **Quick log from notification actions** ⭐
- [x] Live countdown to next prayer
- [x] Monthly calendar with visual indicators
- [x] Day detail view
- [x] Monthly statistics with charts
- [x] Prayer-wise breakdown
- [x] Notifications at exact prayer times
- [x] Location-based times
- [x] Offline support (works without internet!)
- [x] Beautiful Cupertino (iOS-style) UI
- [x] Data persistence with Hive
- [x] Export data feature
- [x] Settings panel

---

## 🏗️ Project Structure

```
lib/
├── main.dart                 # App entry
├── app.dart                  # Root widget
├── core/
│   ├── constants/           # App constants
│   ├── theme/              # Cupertino theme
│   ├── utils/              # Helper functions
│   └── providers/          # Core Riverpod providers
├── features/
│   ├── home/               # Home screen
│   ├── calendar/           # Calendar view
│   ├── statistics/         # Charts & stats
│   ├── settings/           # Settings
│   └── prayers/
│       ├── models/         # Data models
│       ├── services/       # Business logic
│       └── repositories/   # Data access
└── shared/
    └── widgets/            # Reusable widgets
```

---

## 🔧 Development Commands

```bash
# Run app
flutter run

# Run with hot reload
flutter run (then press 'r' to hot reload)

# Check for issues
flutter doctor

# Analyze code
flutter analyze

# Clean build
flutter clean

# Regenerate Hive adapters (after model changes)
flutter pub run build_runner build --delete-conflicting-outputs

# Build for release
flutter build apk --release        # Android
flutter build ios --release        # iOS
```

---

## 📚 Documentation

- **SETUP_GUIDE.md** - Comprehensive setup instructions
- **BUILD_AND_RUN.md** - Quick build commands
- **changelog.md** - Detailed change log
- **README.md** - Project overview

---

## 🎯 Next Steps After Setup

1. **Use the app daily** to track your prayers
2. **Check the calendar** to see your consistency
3. **Review statistics** to identify areas for improvement
4. **Customize** (optional):
   - Add app icon
   - Add splash screen
   - Customize colors in `lib/core/constants/colors.dart`

---

## 💡 Pro Tips

### Tip 1: Notification Actions are GAME CHANGING
Instead of opening the app, just swipe down on the notification and tap your prayer status. Super fast! ⚡

### Tip 2: Check Your Stats Weekly
The statistics screen shows which prayers you're missing most. Use it to improve!

### Tip 3: Calendar View Motivation
Seeing all those green dots (Jamaah prayers) is super motivating. Check it often!

### Tip 4: Set it and Forget it
Once you grant permissions and enable notifications, the app works silently in the background. Just check it daily to log your prayers.

---

## 🤝 Tech Stack

- **Flutter** - Cross-platform framework
- **Riverpod** - State management
- **Hive** - Local database
- **Adhan** - Prayer time calculation
- **FL Chart** - Beautiful charts
- **Table Calendar** - Calendar widget
- **Flutter Local Notifications** - Smart notifications

---

## ❤️ Final Note

This app was built to help Muslims maintain consistency in their daily prayers. May Allah accept all our prayers and grant us the ability to pray on time, preferably in congregation (Jamaah).

**Jazakallahu Khairan** (May Allah reward you with goodness) for using this app!

---

## 🆘 Need Help?

1. Check **SETUP_GUIDE.md** for detailed instructions
2. Review **Common Issues** section above
3. Run `flutter doctor` to check your setup
4. Ensure you ran the build_runner command

---

**🕌 May Allah make this app a means of increasing our worship and consistency in prayer! 🤲**

---

**Version:** 1.0.0
**Platform:** iOS & Android
**Minimum iOS:** 12.0
**Minimum Android:** 5.0 (SDK 21)
