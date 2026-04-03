# 🌤️ Weather App

A Flutter application that provides weather forecasts and city selection with local persistence.

## 📱 Features

- Search and save cities (with country disambiguation)
- View 3-day weather forecast from WeatherAPI
- Local SQLite storage for saved cities
- Light and dark mode support
- Icons and UI animations for various weather types (Lottie or custom SVG)

## 🛠️ TODO (Planned Features)

- [ ] Implement **Alert System** (e.g. severe weather warnings, push notifications)
- [ ] Integrate **AI Features**
- [ ] Suggest cities based on user habits or current location
- [ ] Generate travel suggestions or packing tips based on forecast
- [ ] Add **Geolocation Support**
- [ ] Detect current location and auto-load weather
- [ ] Add **Unit Tests & Widget Tests**
- [ ] Implement **Weather Trends & History View**
- [ ] Add offline support using local caching

## 🚀 Getting Started

1. Clone the repo:

   ```bash
   git clone git@github.com:tomislav98/weather_app_frontend_flutter.git
   cd weather_app
   ```

2. Setting .env file

  ```bash
  WEATHER_API_KEY= your key from [weatherapi site](https://www.weatherapi.com)
  ```
3. How to run flutter
  ```bash
  flutter emulators
```
select for example
```bash
flutter emulators --launch Pixel_10_Pro
```
then run the command
```bash
flutter run
```

---
# Firebase Setup for Flutter

A step-by-step guide to connect your Flutter app to Firebase.

---

## What is Firebase?

Firebase is a collection of Google services. Each service is independent but they all live under the same project:

```
Firebase Project
│
├── 🔐 Firebase Auth       → handles login / signup
├── 🗄️  Cloud Firestore     → stores your app's data
├── 📦 Firebase Storage    → stores files (images, videos)
└── 📲 Cloud Messaging     → push notifications
```

---

## Prerequisites

- Flutter installed
- A Google account
- A Firebase project created at [console.firebase.google.com](https://console.firebase.google.com)

---

## Step 1 — Install Firebase CLI

The Firebase CLI lets you authenticate with your Google account from the terminal.

```bash
curl -sL https://firebase.tools | bash
```

Then log in:

```bash
firebase login
```

This opens a browser → log in with your Google account → authorize it.

---

## Step 2 — Install FlutterFire CLI

FlutterFire CLI uses your Firebase login to connect your Flutter app to your Firebase project. It automatically generates the config files your app needs.

```bash
dart pub global activate flutterfire_cli
```

---

## Step 3 — Add Firebase packages to your Flutter app

In your `pubspec.yaml`:

```yaml
dependencies:
  firebase_core: latest
  firebase_auth: latest       # for authentication
  cloud_firestore: latest     # for database
```

Then run:

```bash
flutter pub get
```

---

## Step 4 — Configure your Flutter app with Firebase

Run this command at the root of your Flutter project:

```bash
flutterfire configure
```

It will ask you:
1. **Select your Firebase project** → choose your project
2. **Select platforms** → choose Android, iOS, Web as needed

This automatically generates and updates:

| File | Purpose |
|---|---|
| `lib/firebase_options.dart` | Firebase config for Flutter |
| `android/app/google-services.json` | Firebase config for Android |
| `ios/Runner/GoogleService-Info.plist` | Firebase config for iOS |

> ⚠️ Never edit these files manually. Always regenerate them with `flutterfire configure`.

---

## Step 5 — Initialize Firebase in main.dart

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase once
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  runApp(MyApp());
}
```

---

## Step 6 — Enable services in Firebase Console

Go to [console.firebase.google.com](https://console.firebase.google.com) → your project and enable the services you need:

- **Authentication** → Sign-in method → Enable Email/Password (or Google, etc.)
- **Firestore Database** → Create database → Start in test mode

---

## Step 7 — Add SHA-1 fingerprint (required for Auth)

Without this, Firebase Auth will fail with `CONFIGURATION_NOT_FOUND`.

```bash
cd android
./gradlew signingReport
```

Copy the `SHA1` value, then:

1. Go to Firebase Console → ⚙️ Project Settings
2. Scroll to **Your apps** → select your Android app
3. Click **Add fingerprint** → paste SHA-1 → Save
4. Download the new `google-services.json` and replace the old one

---

## How Auth and Firestore work together

Firebase Auth and Firestore are **separate services**. Auth does not automatically save users to Firestore — you must do it manually:

```dart
// Step 1 — Create user in Firebase Auth
final userCredential = await FirebaseAuth.instance
    .createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

// Step 2 — Save user data to Firestore manually
await FirebaseFirestore.instance
    .collection('users')
    .doc(userCredential.user!.uid)
    .set({
      'email': email,
      'uid': userCredential.user!.uid,
      'createdAt': DateTime.now(),
    });
```

### Where to see your data

| Service | Where to see it in Console |
|---|---|
| Firebase Auth users | Authentication → Users tab |
| Firestore data | Firestore Database → Data tab |

---

## Switching to a different Firebase project

If you need to connect your app to a different Firebase project:

1. Run `flutterfire configure` again and select the new project
2. Clean and rebuild:

```bash
flutter clean
flutter pub get
flutter run
```

> Both `firebase_options.dart` and `google-services.json` must point to the **same project**.

---

## Free tier limits

Both services have a generous free tier (Spark Plan):

| Service | Free limit |
|---|---|
| Firebase Auth | 10,000 users/month |
| Firestore | 50,000 reads & 20,000 writes per day |

For a new or small app you will likely never hit these limits.

---

## Useful commands

```bash
firebase login           # authenticate with Google
flutterfire configure    # connect Flutter app to Firebase project
flutter clean            # clear build cache
flutter pub get          # fetch dependencies
```
