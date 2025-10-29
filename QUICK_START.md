# 🚀 CityZen Quick Start Guide

Get the CityZen app running in 5 minutes!

---

## ⚡ Prerequisites Check

Run this command to verify your setup:
```bash
flutter doctor
```

You need:
- ✅ Flutter SDK 3.2.0+
- ✅ Android Studio (for Android)
- ✅ Xcode (for iOS, macOS only)
- ✅ Backend server with ngrok

---

## 📱 Step-by-Step Setup

### Step 1: Get the Code
```bash
git clone https://github.com/Shashwat072006/CityZen-SIH-PROJECT-.git
cd CityZen-SIH-PROJECT-/mobile_app
```

### Step 2: Install Dependencies
```bash
flutter pub get
```

### Step 3: Configure Backend URL

**IMPORTANT**: Update the ngrok URL in `lib/main.dart`

1. Start your backend server
2. Start ngrok tunnel:
   ```bash
   ngrok http 5000
   ```
3. Copy the HTTPS URL (e.g., `https://abc123.ngrok-free.app`)
4. Open `lib/main.dart` and update line 15:
   ```dart
   const String backendUrl = 'https://YOUR-NGROK-URL.ngrok-free.app/api';
   ```

### Step 4: Run the App

**For Android**:
```bash
# Connect device or start emulator
flutter run
```

**For iOS**:
```bash
# First time only - add permissions to ios/Runner/Info.plist
flutter run -d ios
```

**For Web** (Development):
```bash
flutter run -d chrome
```

---

## 🔧 Troubleshooting

### "Failed to load issues"
- ✅ Check backend is running
- ✅ Verify ngrok URL is correct
- ✅ Ensure ngrok tunnel is active

### "Location permissions denied"
- ✅ Enable location in device settings
- ✅ Restart the app

### Build errors
```bash
flutter clean
flutter pub get
flutter run
```

---

## 📋 Testing Checklist

Once the app is running:

- [ ] Login screen appears
- [ ] Can navigate to Map View
- [ ] Map loads with current location
- [ ] Can click "Report Issue" button
- [ ] Can select category
- [ ] Can capture/select image
- [ ] Can get GPS location
- [ ] Can submit report
- [ ] Issues appear as markers on map

---

## 🎯 Default Test Location

If GPS fails, the app defaults to:
- **Location**: Kattankulathur, Tamil Nadu
- **Coordinates**: 12.8231°N, 80.0444°E

---

## 📞 Need Help?

Check these files:
- `README.md` - Full documentation
- `PROJECT_STATUS.md` - Detailed project analysis
- GitHub Issues - Report problems

---

**Happy Coding! 🎉**
