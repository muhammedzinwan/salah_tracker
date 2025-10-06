# 🎯 START HERE - Critical First Steps

## ⚠️ BEFORE YOU RUN THE APP

You **MUST** run these commands in order:

```bash
# 1. Install dependencies
flutter pub get

# 2. Generate Hive type adapters (REQUIRED!)
flutter pub run build_runner build --delete-conflicting-outputs

# 3. iOS only: Install pods
cd ios && pod install && cd ..

# 4. Run the app
flutter run
```

## ❗ Why Step 2 is Critical

The app uses **Hive** for local storage. Hive requires type adapters to be generated from your model files.

**Without running build_runner, you'll get this error:**
```
Error: PrayerLogAdapter not found
```

## ✅ You'll Know It Worked When:

After running build_runner, you should see:
- `lib/features/prayers/models/prayer_log.g.dart` file created
- Build success message in terminal

## 🚀 Quick Start

For detailed instructions, see:
- **QUICKSTART.md** - For the fastest setup
- **SETUP_GUIDE.md** - For comprehensive guide
- **BUILD_AND_RUN.md** - For quick commands

## 📱 What This App Does

**Salah Tracker** helps you:
- Track your 5 daily prayers
- Get notifications at prayer times
- Log prayers directly from notifications (no need to open app!)
- View your prayer history in a calendar
- See monthly statistics and improve consistency

## 🎨 Features You'll Love

✨ **Quick Log from Notifications** - Just tap Jamaah/Adah/Qalah on the notification
📊 **Beautiful Statistics** - See your prayer consistency with charts
📅 **Calendar View** - Visual history of all your prayers
⏰ **Live Countdown** - Know exactly how much time until next prayer
🎯 **Offline First** - Works perfectly without internet

## 🔥 Let's Get Started!

Run the 3 commands above and you're all set! 🚀

---

**May Allah help us maintain consistency in our prayers! 🕌**
