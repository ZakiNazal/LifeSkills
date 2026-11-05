# LifeSkills — Exercise & Wellness App

A Flutter mobile app for tracking exercises, exploring activities, and building healthy habits. Built with Firebase for auth and data persistence.

---

## Features

- Email and password auth through Firebase Auth
- Today tab with a live daily goal card, week-at-a-glance streak dots, mood check-in and colour-blocked skill categories
- Guided sessions with a step timer, pause, restart and skip, plus a completion summary
- Streak, points, session count and daily goal all persisted to Firestore and updated in a transaction
- Explore tab with ten activities, search and difficulty filters
- Profile with live stats and bio, editable including photo upload
- Settings for daily goal, notifications, language, password reset and sign out

### How a session works

Tapping a category or activity opens a sheet listing the actual steps and their durations. Starting one pushes a full screen player tinted in that item's colour, running each step on a countdown. Finishing writes to Firestore in a single transaction that increments the session count and points, rolls the streak forward (or resets it if a day was missed), bumps today's session count against the daily goal, and appends today to a rolling 21 day activity history. The home screen reads that document as a stream, so the goal card and stat tiles update the moment a session ends.

Skill categories have hand written steps. Activities generate a warm up, main set and cool down from their length, and anything under fifteen minutes runs as a single block.

## Stack

| Layer | Tool |
|---|---|
| Framework | Flutter 3.x / Dart 3.x |
| Auth | Firebase Authentication |
| Database | Cloud Firestore |
| Local storage | shared_preferences |
| Avatars | base64 in Firestore, no Cloud Storage |
| Images | image_picker |
| Font | Rubik (bundled, 300/400/500/600/700) |

## Getting started

```bash
flutter pub get
flutter run
```

Firebase setup: create a project, enable Email/Password sign-in and create a Firestore database, then drop `google-services.json` into `android/app/` and `GoogleService-Info.plist` into `ios/Runner/`. Regenerate `lib/firebase_options.dart` with `flutterfire configure`.

Cloud Storage is deliberately not used. As of September 2024 it requires the Blaze billing plan and returns 402 on Spark projects, so profile photos are downscaled to 512px, JPEG encoded at quality 70 and stored as base64 on the user document instead. That lands around 40KB against Firestore's 1MiB per document limit, and keeps the app runnable on the free plan.

## Structure

```
lib/
├── main.dart                   app entry, routes, splash handoff
├── theme/
│   ├── palette.dart            colours
│   ├── app_text.dart           type scale
│   └── app_theme.dart          ThemeData
├── widgets/                    shared UI primitives
│   ├── app_button.dart         filled / outlined / quiet
│   ├── app_text_field.dart     labelled field + search field
│   ├── app_nav_bar.dart        flat bottom nav
│   ├── list_row.dart           ListRow + RowGroup with hairline dividers
│   ├── color_card.dart         colour-blocked category / activity card
│   ├── goal_card.dart          daily goal hero with progress and week dots
│   ├── stat_tile.dart          tinted stat tile
│   ├── choice_pill.dart        mood and filter pills
│   ├── detail_sheet.dart       session sheet, lists steps and launches the player
│   ├── section_label.dart      uppercase section heading
│   ├── social_button.dart      Google / Apple buttons
│   └── app_snack.dart          snackbar + confirm dialog
├── data/
│   ├── catalog.dart            skill categories and activities
│   ├── session.dart            SessionStep, SessionPlan, activity step builder
│   └── stats_service.dart      Firestore reads and the completeSession transaction
├── pages/                      home, explore, profile, session, edit profile, settings, login, register
└── util/                       auth router, splash, exercise provider
```

## Firestore

`users/{uid}`

| Field | Type | Notes |
|---|---|---|
| `name` | String | |
| `email` | String | |
| `photoUrl` | String? | legacy, only read as a fallback |
| `photoData` | String? | base64 JPEG avatar, max 700KB encoded |
| `bio` | String | |
| `exercisesCompleted` | Number | total sessions finished |
| `points` | Number | 2 per minute of session, minimum 5 |
| `streak` | Number | consecutive days with at least one session |
| `lastActiveDate` | String | `yyyy-MM-dd`, drives the streak rollover |
| `sessionsToday` | Number | only meaningful when `lastActiveDate` is today |
| `dailyGoal` | Number | sessions per day, default 3 |
| `activeDays` | Array\<String\> | last 21 active dates, feeds the week dots |

## Android build

Gradle 8.11.1, AGP 8.9.1, Kotlin 2.1.0, min SDK 21.

## License

MIT
