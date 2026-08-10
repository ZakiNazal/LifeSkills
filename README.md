# LifeSkills — Exercise & Wellness App

<img width="800" height="600" alt="lifeskills" src="https://github.com/user-attachments/assets/3f2bf5bc-1337-4a87-ba06-a71861bbbedd" />

A Flutter mobile app for tracking exercises, exploring activities, and building healthy habits. Built with Firebase for auth and data persistence.

---

## Features

- **Authentication** — Email/password sign-up and login with Firebase Auth
- **Home Dashboard** — Time-based greeting, streak tracker, mood check-in, and exercise category list
- **Explore** — Grid of 10 activity categories (Yoga, Running, Weightlifting, etc.) with descriptions and difficulty levels
- **Profile** — User stats (exercises completed, points, streak), bio, and photo upload
- **Edit Profile** — Update name, bio, photo (Firebase Storage), and email with verification
- **Settings** — Notification toggle, language selector, change password (sends reset email), sign out

---

## Tech Stack

| Layer | Tool |
|---|---|
| Framework | Flutter 3.x / Dart 3.x |
| Auth | Firebase Authentication |
| Database | Cloud Firestore |
| File Storage | Firebase Storage |
| Animations | Lottie, Confetti, flutter_staggered_animations |
| Navigation | curved_navigation_bar |
| Local Storage | shared_preferences |
| Image Picker | image_picker |
| Font | Rubik |

---

## Getting Started

### Prerequisites

- Flutter SDK `>=3.4.3`
- Dart SDK `>=3.4.3`
- Android Studio or VS Code with Flutter extension
- A Firebase project

### 1. Clone the repo

```bash
git clone https://github.com/your-username/exercise.git
cd exercise
```

### 2. Set up Firebase

1. Go to the [Firebase Console](https://console.firebase.google.com/) and create a project
2. Enable **Email/Password** sign-in under Authentication → Sign-in method
3. Create a **Firestore** database (start in test mode for development)
4. Enable **Firebase Storage**
5. Download `google-services.json` and place it in `android/app/`
6. Download `GoogleService-Info.plist` and place it in `ios/Runner/`
7. Replace `lib/firebase_options.dart` with your generated config (via `flutterfire configure`)

### 3. Install dependencies

```bash
flutter pub get
```

### 4. Run the app

```bash
flutter run
```

---

## Project Structure

```
lib/
├── main.dart                  # App entry, theme, routes
├── pages/
│   ├── home_page.dart         # Main dashboard + navigation shell
│   ├── explore_page.dart      # Activity category grid
│   ├── profile_page.dart      # User profile and stats
│   ├── edit_profile.dart      # Edit name, bio, photo, email
│   ├── settings_page.dart     # App preferences and account options
│   ├── login_page.dart        # Sign-in screen
│   └── register_page.dart     # Registration screen
└── util/
    ├── auth_page.dart         # Firebase auth stream router
    ├── splash_screen.dart     # Lottie splash screen
    ├── emoticon_face.dart     # Mood selector widget
    ├── exercise_tile.dart     # Exercise category list tile
    ├── search_bar.dart        # Reusable search input
    └── square_tile.dart       # OAuth provider button (Google/Apple)
```

---

## Firestore Data Model

### `users/{uid}`

| Field | Type | Description |
|---|---|---|
| `name` | String | Display name |
| `email` | String | Email address |
| `photoUrl` | String? | Profile photo URL (Firebase Storage) |
| `bio` | String | Short bio |
| `exercisesCompleted` | Number | Total exercises done |
| `points` | Number | Earned points |
| `streak` | Number | Current day streak |

---

## Android Build Requirements

| Tool | Minimum Version |
|---|---|
| Gradle | 8.11.1 |
| Android Gradle Plugin | 8.9.1 |
| Kotlin | 2.1.0 |
| Min SDK | 21 |

---

## License

MIT
