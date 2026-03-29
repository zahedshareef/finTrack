# finTrack — Personal Finance & Expense Tracker

A full-featured personal finance app built with Flutter and Material Design 3 (dark theme). Runs on Android, iOS, web, and desktop — all data stored locally with no backend required.

## Features

- **Multiple accounts** with multi-currency support and live exchange rates
- **Transactions** with category filtering, search, and infinite scroll
- **Debt tracking** — money you owe and money owed to you
- **Statistics & charts** — pie, bar, line, and 30-day balance trend
- **Budgets & savings goals** with progress tracking
- **Planned payment reminders** with local notifications and recurring recurrence (weekly / monthly / yearly)
- **CSV & PDF export** with account and category filters
- **Gold investment tracker** — P&L per holding with live gold price
- **Fully offline** — SharedPreferences JSON storage, no backend, no account required

---

## Prerequisites

| Tool | Minimum version | Notes |
|------|----------------|-------|
| Flutter SDK | 3.22+ | Includes Dart SDK |
| Dart SDK | 3.4+ | Bundled with Flutter |
| Git | any | For cloning |
| Android Studio **or** Xcode | latest stable | For mobile targets |

> **Quick check:** Run `flutter doctor` after installation — it will tell you exactly what is missing.

---

## Setup by Platform

### macOS

1. **Install Flutter**
   ```bash
   # Using Homebrew (recommended)
   brew install --cask flutter

   # Or download manually from https://docs.flutter.dev/get-started/install/macos
   ```

2. **Install Xcode** (for iOS/macOS builds)
   ```bash
   xcode-select --install
   sudo xcodebuild -license accept
   ```

3. **Install CocoaPods** (required for iOS)
   ```bash
   sudo gem install cocoapods
   ```

4. **Install Android Studio** (for Android builds)
   - Download from https://developer.android.com/studio
   - Open Android Studio → SDK Manager → install the latest Android SDK

5. **Clone and set up the project**
   ```bash
   git clone https://github.com/zahedshareef/finTrack.git
   cd finTrack/artifacts/expense_tracker
   flutter pub get
   ```

6. **Verify everything is ready**
   ```bash
   flutter doctor
   ```

---

### Linux

1. **Install dependencies**
   ```bash
   sudo apt update
   sudo apt install -y curl git unzip xz-utils zip libglu1-mesa \
     clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev
   ```

2. **Install Flutter**
   ```bash
   cd ~
   git clone https://github.com/flutter/flutter.git -b stable
   echo 'export PATH="$HOME/flutter/bin:$PATH"' >> ~/.bashrc
   source ~/.bashrc
   ```

3. **Install Android Studio** (for Android builds)
   - Download from https://developer.android.com/studio
   - Run the `.tar.gz` installer and follow the setup wizard
   - Open SDK Manager → install the latest Android SDK & build tools

4. **Clone and set up the project**
   ```bash
   git clone https://github.com/zahedshareef/finTrack.git
   cd finTrack/artifacts/expense_tracker
   flutter pub get
   ```

5. **Verify everything is ready**
   ```bash
   flutter doctor
   ```

---

### Windows

1. **Install Flutter**
   - Download the Flutter SDK zip from https://docs.flutter.dev/get-started/install/windows
   - Extract to `C:\flutter` (avoid paths with spaces or special characters)
   - Add `C:\flutter\bin` to your system `PATH`
   - Or use winget: `winget install Flutter.Flutter`

2. **Install Android Studio** (for Android builds)
   - Download from https://developer.android.com/studio
   - Run the installer and follow the setup wizard
   - Open SDK Manager → install the latest Android SDK, build tools, and emulator

3. **Enable Windows desktop support** (for running on Windows)
   ```powershell
   flutter config --enable-windows-desktop
   ```

4. **Install Git for Windows**
   - Download from https://git-scm.com/download/win

5. **Clone and set up the project**
   ```powershell
   git clone https://github.com/zahedshareef/finTrack.git
   cd finTrack\artifacts\expense_tracker
   flutter pub get
   ```

6. **Verify everything is ready**
   ```powershell
   flutter doctor
   ```

---

## Running & Debugging

### List available devices
```bash
flutter devices
```

### Run on a connected device or emulator
```bash
# Android (connected device or emulator)
flutter run -d android

# iOS (macOS only, requires Xcode)
flutter run -d ios

# Web browser
flutter run -d chrome

# macOS desktop
flutter run -d macos

# Windows desktop
flutter run -d windows

# Linux desktop
flutter run -d linux
```

### Run in debug mode (default)
Debug mode includes hot reload, the Flutter DevTools overlay, and verbose logging:
```bash
flutter run
```
- Press **r** in the terminal to hot reload after a code change
- Press **R** to hot restart (clears state)
- Press **d** to detach and keep the app running
- Press **q** to quit

### Attach Flutter DevTools
DevTools gives you a widget inspector, performance profiler, memory view, and network tab:
```bash
flutter pub global activate devtools
flutter run --verbose
# Then open the printed DevTools URL in Chrome
```

Or launch directly:
```bash
dart devtools
```

### View logs
```bash
flutter logs          # streams device logs
flutter run --verbose # includes Flutter framework logs
```

---

## Building for Release

### Android APK
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle (recommended for Play Store)
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### iOS (macOS only)
```bash
flutter build ios --release
# Then open ios/Runner.xcworkspace in Xcode to archive and upload
```

### Web
```bash
flutter build web --release
# Output: build/web/ — deploy this folder to any static host
```

### macOS desktop
```bash
flutter build macos --release
# Output: build/macos/Build/Products/Release/expense_tracker.app
```

### Windows desktop
```powershell
flutter build windows --release
# Output: build\windows\x64\runner\Release\
```

### Linux desktop
```bash
flutter build linux --release
# Output: build/linux/x64/release/bundle/
```

---

## Publishing

### Google Play Store
1. [Create a keystore](https://docs.flutter.dev/deployment/android#create-an-upload-keystore) and configure `android/key.properties`
2. Build the App Bundle:
   ```bash
   flutter build appbundle --release
   ```
3. Upload `app-release.aab` to the [Google Play Console](https://play.google.com/console)

### Apple App Store
1. Open `ios/Runner.xcworkspace` in Xcode
2. Set your Team, Bundle ID, and signing certificate
3. **Product → Archive**, then use the Organizer to upload to App Store Connect
4. Submit for review at [App Store Connect](https://appstoreconnect.apple.com)

### Web (self-hosted)
```bash
flutter build web --release
# Deploy the build/web/ folder to any static host:
# - Firebase Hosting, Vercel, Netlify, GitHub Pages, Nginx, etc.
```

### Firebase Hosting (example)
```bash
npm install -g firebase-tools
firebase login
firebase init hosting          # point public dir to build/web
flutter build web --release
firebase deploy
```

---

## Project Structure

```
artifacts/expense_tracker/
├── lib/
│   ├── main.dart                  # App entry point & theme
│   ├── models/                    # Data models (Account, Transaction, Category, …)
│   ├── providers/
│   │   └── data_provider.dart     # Central state management (Provider)
│   ├── screens/
│   │   ├── home/                  # Dashboard & summary cards
│   │   ├── transactions/          # Transaction list, filters, add/edit
│   │   ├── accounts/              # Account list & detail
│   │   ├── stats/                 # Charts & analytics
│   │   └── more/                  # Debts, budgets, goals, planned payments, gold, reports
│   ├── services/
│   │   ├── storage_service.dart   # SharedPreferences persistence
│   │   ├── currency_service.dart  # Live FX rates (open.er-api.com) + offline cache
│   │   ├── gold_service.dart      # Live gold price (gold-api.com)
│   │   ├── notification_service.dart # Local push notifications
│   │   └── export_service.dart    # CSV & PDF export
│   ├── widgets/                   # Shared UI components
│   └── theme/
│       └── app_theme.dart         # Material 3 dark theme definition
├── android/
├── ios/
├── web/
├── macos/
├── windows/
├── linux/
└── pubspec.yaml
```

## Key Dependencies

| Package | Purpose |
|---------|---------|
| `provider` | State management |
| `shared_preferences` | Local JSON storage |
| `fl_chart` | Pie, bar, and line charts |
| `http` | Exchange rate & gold price API calls |
| `intl` | Number & date formatting |
| `flutter_local_notifications` | Planned payment reminders |
| `timezone` | Accurate notification scheduling |
| `pdf` + `printing` | PDF export & share |
| `csv` | CSV export |
| `share_plus` | Native share sheet |
| `path_provider` | File system access |
| `uuid` | Unique ID generation |

---

## Contributing

1. Fork the repo
2. Create a feature branch: `git checkout -b feature/my-feature`
3. Commit your changes: `git commit -m "feat: add my feature"`
4. Push: `git push origin feature/my-feature`
5. Open a Pull Request

---

## License

MIT License — see [LICENSE](LICENSE) for details.
