# 🏙️ CityZen - Smart Civic Issue Reporting App

**CityZen** is a Flutter-based mobile application designed for the Smart India Hackathon (SIH) project. It enables citizens to report civic issues in their area with location tracking, image uploads, and real-time status updates. The app integrates with a backend API (using ngrok for development) to manage and track reported issues.

---

## 📋 Table of Contents

- [Features](#-features)
- [Tech Stack](#-tech-stack)
- [Prerequisites](#-prerequisites)
- [Installation](#-installation)
- [Configuration](#-configuration)
- [Running the App](#-running-the-app)
- [Backend Integration](#-backend-integration)
- [Project Structure](#-project-structure)
- [Permissions](#-permissions)
- [Troubleshooting](#-troubleshooting)
- [Contributing](#-contributing)
- [License](#-license)

---

## ✨ Features

### 🗺️ **Interactive Map View**
- View all reported civic issues on an interactive Google Map
- Color-coded markers based on issue status:
  - 🔴 **Red**: Pending issues
  - 🟠 **Orange**: In Progress
  - 🟢 **Green**: Resolved
- Real-time location tracking with GPS
- Tap markers to view issue details

### 📝 **Issue Reporting**
- Report civic issues across multiple categories:
  - Road & Infrastructure
  - Sewage & Water
  - Waste Management
  - Streetlights
  - Public Safety
  - Other
- Upload images from camera or gallery
- Automatic GPS location capture or manual coordinate entry
- Detailed description and title fields

### 📊 **My Reports Dashboard**
- View all your submitted reports
- Track status updates (Pending, In Progress, Resolved)
- Filter by category and date

### 🔐 **User Authentication**
- Simple login screen with email validation
- Secure user session management

---

## 🛠️ Tech Stack

- **Framework**: Flutter 3.2.0+
- **Language**: Dart
- **State Management**: StatefulWidget
- **Maps**: Google Maps Flutter
- **HTTP Client**: http package
- **Location Services**: Geolocator
- **Image Handling**: Image Picker
- **Backend**: RESTful API (via ngrok tunnel)

---

## 📦 Prerequisites

Before running this project, ensure you have the following installed:

1. **Flutter SDK** (3.2.0 or higher)
   ```bash
   flutter --version
   ```

2. **Dart SDK** (comes with Flutter)

3. **Android Studio** or **Xcode** (for mobile development)

4. **Git**

5. **Google Maps API Key** (already configured in the project)

6. **Backend Server** running with ngrok tunnel

---

## 🚀 Installation

### 1. Clone the Repository

```bash
git clone https://github.com/Shashwat072006/CityZen-SIH-PROJECT-.git
cd CityZen-SIH-PROJECT-/mobile_app
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Verify Flutter Installation

```bash
flutter doctor
```

Fix any issues reported by Flutter Doctor before proceeding.

---

## ⚙️ Configuration

### 1. Backend URL Configuration

The app uses **ngrok** to connect to the backend API. Update the backend URL in `lib/main.dart`:

```dart
// Line 14-15 in lib/main.dart
const String backendUrl = 'https://YOUR-NGROK-URL.ngrok-free.app/api';
```

**Important**: Replace `YOUR-NGROK-URL` with your current ngrok tunnel URL every time you restart ngrok.

### 2. Google Maps API Key

The Google Maps API key is already configured in:
- **Android**: `android/app/src/main/AndroidManifest.xml` (Line 16)
- **iOS**: Configure in `ios/Runner/AppDelegate.swift` if needed

**Note**: For production, replace the API key with your own from [Google Cloud Console](https://console.cloud.google.com/).

### 3. Permissions

The app requires the following permissions (already configured):

**Android** (`android/app/src/main/AndroidManifest.xml`):
- `INTERNET` - For API calls
- `ACCESS_FINE_LOCATION` - For GPS location
- `ACCESS_COARSE_LOCATION` - For approximate location

**iOS** (`ios/Runner/Info.plist`):
- Add location permissions if not already present

---

## 🏃 Running the App

### For Android

1. Connect an Android device or start an emulator
2. Run the app:
   ```bash
   flutter run
   ```

### For iOS

1. Open the iOS project in Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```
2. Configure signing certificates
3. Run the app:
   ```bash
   flutter run
   ```

### For Web (Development)

```bash
flutter run -d chrome
```

---

## 🔌 Backend Integration

### API Endpoints

The app connects to the following backend endpoints:

1. **GET** `/api/issues` - Fetch all reported issues
2. **POST** `/api/issues` - Submit a new issue report

### Request Format (POST /api/issues)

```json
{
  "title": "Issue title",
  "description": "Detailed description",
  "latitude": 12.8231,
  "longitude": 80.0444,
  "category": "Road & Infrastructure",
  "image": "<multipart file>"
}
```

### Response Format (GET /api/issues)

```json
[
  {
    "id": 1,
    "title": "Pothole on Main Street",
    "category": "Road & Infrastructure",
    "status": "Pending",
    "latitude": 12.8231,
    "longitude": 80.0444
  }
]
```

### Setting Up ngrok

1. Start your backend server (e.g., on port 5000)
2. Start ngrok tunnel:
   ```bash
   ngrok http 5000
   ```
3. Copy the HTTPS URL (e.g., `https://abc123.ngrok-free.app`)
4. Update `backendUrl` in `lib/main.dart`

**Important**: The app includes ngrok bypass headers to avoid browser warnings:
```dart
const Map<String, String> ngrokHeaders = {
  'ngrok-skip-browser-warning': 'true',
};
```

---

## 📁 Project Structure

```
mobile_app/
├── android/                 # Android-specific files
│   └── app/
│       └── src/main/
│           └── AndroidManifest.xml
├── ios/                     # iOS-specific files
├── lib/
│   └── main.dart           # Main application code (1150 lines)
├── web/                    # Web-specific files
├── windows/                # Windows-specific files
├── linux/                  # Linux-specific files
├── macos/                  # macOS-specific files
├── pubspec.yaml            # Dependencies and project metadata
└── README.md               # This file
```

### Key Files

- **`lib/main.dart`**: Contains all app logic including:
  - Login Screen
  - Map View with markers
  - Report Issue Screen
  - My Reports Dashboard
  - API integration
  - Location services

---

## 🔑 Permissions

### Android Permissions

Configured in `android/app/src/main/AndroidManifest.xml`:
- Internet access
- Fine and coarse location access

### iOS Permissions

Add to `ios/Runner/Info.plist`:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs location access to report civic issues</string>
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to capture issue photos</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs photo library access to select issue images</string>
```

---

## 🐛 Troubleshooting

### Common Issues

1. **"Failed to load issues from server"**
   - Verify backend is running
   - Check ngrok URL is correct and active
   - Ensure ngrok tunnel hasn't expired

2. **"Location permissions denied"**
   - Enable location permissions in device settings
   - Restart the app after granting permissions

3. **Google Maps not showing**
   - Verify API key is valid
   - Enable Maps SDK for Android/iOS in Google Cloud Console
   - Check billing is enabled for the API key

4. **Build errors**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

5. **Gradle build issues (Android)**
   - Update Android Studio
   - Sync Gradle files
   - Check Java version compatibility

---

## 🤝 Contributing

This is a Smart India Hackathon project. Contributions are welcome!

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is developed for the Smart India Hackathon 2025.

---

## 👥 Team

**Project**: CityZen - Smart Civic Issue Reporting System  
**Event**: Smart India Hackathon (SIH)  
**Repository**: [GitHub](https://github.com/Shashwat072006/CityZen-SIH-PROJECT-)

---

## 📞 Support

For issues or questions:
- Open an issue on GitHub
- Contact the development team

---

## 🎯 Future Enhancements

- [ ] Real-time notifications for status updates
- [ ] User authentication with backend
- [ ] Issue voting and priority system
- [ ] Admin dashboard integration
- [ ] Offline mode with local storage
- [ ] Multi-language support
- [ ] Dark mode theme

---

**Made with ❤️ for Smart India Hackathon 2025**
