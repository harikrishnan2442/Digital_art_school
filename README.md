# Digital Art School — Student App

A Flutter mobile application for **Digital Art School**, a platform that connects students with teachers across traditional and classical Indian art forms — Classical Dance, Vocal Music, Instrumental Music, Visual Arts, Theatre, and Martial Arts. Students register with their art interests, skill level, and availability; a rule-based matching engine surfaces the best-fit teachers; students send requests and, once accepted, get access to a personal schedule, orientation courses, progress tracking, and an AI learning assistant.

This app is a full native rebuild of an earlier PHP/MySQL/Moodle web version of the same platform, re-architected as a Flutter app with a thin PHP REST API bridge to the original MySQL database.

---

## Table of Contents

- [Features](#features)
- [Tech Stack](#tech-stack)
- [Screens](#screens)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Environment Configuration](#environment-configuration)
- [Connecting to the Backend](#connecting-to-the-backend)
- [Device Permissions](#device-permissions)
- [Design System](#design-system)
- [State Management](#state-management)
- [Demo Mode vs. Live Mode](#demo-mode-vs-live-mode)
- [Known Limitations](#known-limitations)
- [Contributing](#contributing)

---

## Features

### Core flow
- **Splash screen** — minimal, logo-centred brand intro that also restores any remembered session in the background.
- **Authentication** — sign in, or a 4-step guided registration wizard (basic info → art & interests → experience & background → learning goals & schedule).
- **Remember me** — sessions persist across app restarts via `shared_preferences`; closing and reopening the app keeps the student signed in.
- **Rule-based teacher matching** — a scoring engine ranks teachers against a student's art category, discipline, skill level, learning purpose, preferred schedule, and location, with fully-booked teachers filtered out entirely.
- **Teacher requests** — browse matched teachers, view their bio/rating/languages/availability, and send a request with an optional message.

### Dashboard
- Animated, time-of-day-aware welcome hero built with a real **Liquid Glass** effect (blur, specular highlight, edge lighting, colour vibrancy) over a gradient/doodle backdrop.
- Practice-activity streak heatmap.
- Mini calendar.
- Quick-access grid to every other screen and the AI assistant.

### Learning
- **Courses** — a free orientation/foundation track (available before a teacher is assigned), a resource library, and an enrolled-courses view that unlocks once a teacher accepts a request.
- **Progress** — a step-by-step learning journey timeline, a profile-completion score, and earned badges.
- **Schedule** — weekly view of upcoming sessions, with a locked/empty state before a teacher is assigned.

### Profile & Account
- Full profile view covering every field collected at registration (art interests, experience, learning goals, health/accessibility notes, account history — member since / last login).
- Pull-to-refresh to re-sync the profile from the live database.
- Change password.
- **Settings** — light/dark theme, notification preferences, privacy toggles, class/session settings (once enrolled), language & region, data export, and account deletion/log out.

### AI Learning Assistant
- Real chat assistant powered by the **Groq API** (OpenAI-compatible chat completions), aware of the student's current profile context (art category, discipline, skill level, teacher status).
- Reachable from a **floating assistant bar** that sits above the bottom navigation on every main screen, plus a Quick Access tile on the dashboard.
- Runs entirely without a key too — it just explains what's missing instead of crashing, so the app is always usable out of the box.

### Look & feel
- Full **light/dark mode** with an animated theme transition, toggle in the header.
- Custom **Liquid Glass** UI components (`cupertino_liquid_glass`) for a modern, translucent aesthetic.
- Central icon system (Lucide icon set) and a swappable app logo / background artwork via simple asset drops.
- Design language and colour palette translated 1:1 from the original web platform's brand guidelines.

### Location
- "Use my current location" button on registration, using device GPS + reverse geocoding to pre-fill the student's city.

---

## Tech Stack

| Layer | Technology |
|---|---|
| App framework | [Flutter](https://flutter.dev) (Dart) |
| State management | [`provider`](https://pub.dev/packages/provider) (`ChangeNotifier`) |
| HTTP client | [`http`](https://pub.dev/packages/http) |
| Local persistence | [`shared_preferences`](https://pub.dev/packages/shared_preferences) |
| Environment config | [`flutter_dotenv`](https://pub.dev/packages/flutter_dotenv) |
| Location | [`geolocator`](https://pub.dev/packages/geolocator) + [`geocoding`](https://pub.dev/packages/geocoding) |
| Typography | [`google_fonts`](https://pub.dev/packages/google_fonts) (Poppins) |
| Icons | [`lucide_icons`](https://pub.dev/packages/lucide_icons) |
| Glass UI | [`cupertino_liquid_glass`](https://pub.dev/packages/cupertino_liquid_glass) |
| Animations | [`flutter_animate`](https://pub.dev/packages/flutter_animate) |
| AI assistant | [Groq API](https://console.groq.com/) (chat completions) |
| Backend / database | PHP (mysqli, prepared statements) + MySQL/MariaDB |

---

## Screens

| Screen | Path |
|---|---|
| Splash | `lib/screens/splash/splash_screen.dart` |
| Login | `lib/screens/auth/login_screen.dart` |
| Register (4-step) | `lib/screens/auth/register_screen.dart` |
| App shell (header, nav, floating AI bar) | `lib/screens/shell/main_shell.dart` |
| Dashboard | `lib/screens/dashboard/dashboard_screen.dart` |
| Schedule | `lib/screens/schedule/schedule_screen.dart` |
| Courses | `lib/screens/courses/courses_screen.dart` |
| Progress | `lib/screens/progress/progress_screen.dart` |
| Profile | `lib/screens/profile/profile_screen.dart` |
| Settings | `lib/screens/settings/settings_screen.dart` |

Navigation is a single `MainShell` widget holding an `IndexedStack` of the six main screens (Dashboard, Schedule, Courses, Progress, Profile, Settings). Profile is reached from the header (next to the notification bell), not the bottom bar — the bottom bar covers Dashboard, Schedule, Courses, Progress, and Settings.

---

## Project Structure

```
lib/
├── main.dart                    # Entry point — loads .env, boots the app
├── app.dart                     # MaterialApp, theming, state provider
│
├── core/
│   ├── theme/
│   │   ├── app_colors.dart      # Brand colour palette & gradients
│   │   ├── app_palette.dart     # Light/dark semantic tokens (ThemeExtension)
│   │   ├── app_theme.dart       # Light & dark ThemeData
│   │   └── app_icons.dart       # Central icon map (Lucide) — every icon
│   │                            #   reference in the app goes through here
│   └── widgets/
│       ├── glass_card.dart          # Standard elevated card
│       ├── liquid_glass_card.dart   # Real "Liquid Glass" surface
│       ├── gradient_button.dart     # Primary CTA button
│       ├── app_logo.dart            # Logo widget w/ graceful fallback
│       ├── background_doodle.dart   # Background artwork w/ graceful fallback
│       ├── theme_toggle_button.dart # Animated light/dark toggle
│       ├── section_label.dart       # Section headers & status pills
│       └── glow_orb.dart            # Decorative blurred colour orb
│
├── models/
│   ├── student.dart              # Student profile (mirrors `students` table)
│   ├── teacher.dart               # Teacher profile (mirrors `teachers` table)
│   ├── course_module.dart         # Orientation modules & resources
│   └── schedule_event.dart        # Journey steps, badges, schedule events
│
├── data/
│   ├── mock_data.dart             # Static seed data (orientation content, badges)
│   └── teacher_repository.dart    # Loads the bundled teacher dataset
│
├── services/
│   ├── api_client.dart            # Thin HTTP wrapper for the PHP API
│   ├── student_api_service.dart   # login/register/profile/teacher-request calls
│   ├── groq_service.dart          # AI Learning Assistant (Groq chat completions)
│   ├── location_service.dart      # geolocator + geocoding wrapper
│   └── teacher_matching_service.dart  # Rule-based teacher scoring/ranking
│
├── state/
│   └── app_state.dart             # Single ChangeNotifier — session, theme,
│                                   #   teacher requests, settings toggles
│
└── screens/
    ├── splash/
    ├── auth/          (login, register)
    ├── shell/          (header, bottom nav, floating AI bar, shared chat sheet)
    ├── dashboard/
    ├── courses/
    ├── progress/
    ├── schedule/
    ├── profile/
    └── settings/

assets/
├── images/            # logo.png, background_doodle.png (drop your own in)
└── data/
    └── teachers.json  # Bundled teacher catalogue (26 teachers)
```

Every screen reads app-wide data through `AppState` (via `context.watch<AppState>()` / `context.read<AppState>()`) — no screen talks to `mock_data.dart`, the API, or `shared_preferences` directly. This means swapping how data is sourced only ever requires editing `lib/state/app_state.dart`.

---

## Prerequisites

- Flutter SDK `>=3.3.0 <4.0.0`
- Dart SDK (bundled with Flutter)
- A configured Android/iOS toolchain (Android Studio / Xcode) for building to a device or emulator
- (Optional, for live data) PHP 8+ and MySQL/MariaDB, plus the companion API layer described in [Connecting to the Backend](#connecting-to-the-backend)
- (Optional) A free [Groq API key](https://console.groq.com/keys) for the AI assistant

---

## Getting Started

This repository ships as `lib/` + `pubspec.yaml` + `assets/` — platform folders (`android/`, `ios/`, etc.) are generated locally rather than committed.

```bash
# 1. Clone the repo
git clone <this-repo-url>
cd <repo-folder>

# 2. Generate platform folders (safe to run even if they already exist —
#    it won't touch lib/ or your pubspec dependencies)
flutter create .

# 3. Install dependencies
flutter pub get

# 4. Copy the example environment file and fill in what you need
cp .env.example .env    # or create .env manually — see below

# 5. Run
flutter run
```

The app runs immediately with **no configuration at all** — leaving `.env` blank drops it into demo mode (see [Demo Mode vs. Live Mode](#demo-mode-vs-live-mode)).

---

## Environment Configuration

Configuration lives in a single `.env` file at the project root, loaded at startup via `flutter_dotenv`. It is git-ignored — never commit real credentials.

```dotenv
# AI Learning Assistant — get a free key at https://console.groq.com/keys
GROQ_API_KEY=

# PHP API base URL — leave blank to run in demo mode with no server.
#   Android emulator -> host machine:  http://10.0.2.2/digital-art-school/api
#   iOS simulator:                     http://127.0.0.1/digital-art-school/api
#   Physical device on the same Wi-Fi: http://<your-LAN-IP>/digital-art-school/api
API_BASE_URL=
```

| Variable | Required | Purpose |
|---|---|---|
| `GROQ_API_KEY` | No | Powers the AI Learning Assistant. Without it, the chat still opens and explains that a key is needed instead of failing silently. |
| `API_BASE_URL` | No | Points the app at a real PHP + MySQL backend. Without it, the app runs fully in local demo mode. |

---

## Connecting to the Backend

Flutter apps cannot (and should not) connect directly to a MySQL database — credentials would have to live inside the compiled app. The standard pattern, used here, is:

```
Flutter app  →  HTTP (JSON)  →  PHP API layer  →  MySQL
```

The PHP API layer is a small, separate set of endpoint files (`api/bootstrap.php`, `register.php`, `login.php`, `profile.php`, `teacher_request.php`) that sit alongside the original PHP project's existing `includes/config.php` and reuse its connection/hashing/sanitisation helpers as-is.

| Endpoint | Method | Purpose |
|---|---|---|
| `api/register.php` | POST | Create a student account |
| `api/login.php` | POST | Verify credentials, update `last_login` |
| `api/profile.php` | GET | Fetch a student's full profile |
| `api/profile.php` | POST | Update profile fields and/or change password |
| `api/teacher_request.php` | POST | Create a teacher request |

Field-name and enum-value translation (e.g. the database's `skill_level` snake_case values vs. the Dart enum's camelCase names) happens entirely at this API boundary, so neither the database schema nor the Flutter models need to change to talk to each other.

To go live:
1. Copy the API layer into the PHP project root, next to `includes/` and `pages/`.
2. Set `API_BASE_URL` in `.env` to point at it.
3. (Optional) Run the provided migration + seed script to load the full teacher catalogue into MySQL, if you want teacher requests to work live for every teacher rather than just the ones already seeded in the database.

---

## Device Permissions

The "use my current location" button on registration needs platform permission entries, added after running `flutter create .`:

**`android/app/src/main/AndroidManifest.xml`** — inside `<manifest>`, above `<application>`:
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

**`ios/Runner/Info.plist`** — inside the outer `<dict>`:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Digital Art School uses your location to pre-fill your city on registration.</string>
```

---

## Design System

| Token | Value | Usage |
|---|---|---|
| Blue | `#0366B0` | Primary brand colour |
| Teal | `#02B393` | Secondary / success states |
| Lime | `#A3CE47` | Accent |
| Gold | `#F3C73B` | Accent / highlights |
| Slate | `#606060` | Secondary text |
| Deep Navy | `#0D1F35` | Dark surfaces, headers |
| Coconut | `#F4FAFF` | Light page background |

- **Typography:** Poppins (via `google_fonts`), weights 300–700.
- **Icons:** Lucide icon set, referenced exclusively through `lib/core/theme/app_icons.dart` — a single file to edit if an icon name ever needs to change.
- **Dark mode:** driven by `AppState.themeMode`, animated via `MaterialApp.themeAnimationDuration`, with light/dark semantic tokens defined in `lib/core/theme/app_palette.dart` (`ThemeExtension<AppPalette>`). Currently fully themed on Splash, Login/Register, the shared shell (header/nav/floating bar), and the Dashboard; Courses/Progress/Schedule/Settings currently remain light-only.
- **Glassmorphism:** `LiquidGlassCard` (`lib/core/widgets/liquid_glass_card.dart`) wraps `cupertino_liquid_glass` with an additional translucent brand-colour wash and diagonal sheen, so real background hues (gradients, doodle artwork) show through rather than a flat grey blur.

---

## State Management

A single `AppState` (`ChangeNotifier`, provided via `provider`) is the whole app's source of truth:

- Current student session (`Student?`)
- Theme mode (light/dark), persisted
- In-flight and accepted teacher requests
- Settings toggles (notifications, privacy, etc.)
- Whether the app is running in demo mode or against a live API (`isUsingLiveApi`)

Screens never read from `mock_data.dart`, `shared_preferences`, or the API directly — everything is mediated through `AppState`, which keeps the rest of the app decoupled from *where* data actually comes from.

---

## Demo Mode vs. Live Mode

The app is fully explorable with **zero configuration**:

| | Demo mode (`API_BASE_URL` unset) | Live mode (`API_BASE_URL` set) |
|---|---|---|
| Login | Any email + 6+ character password signs in with a pre-filled demo profile | Real credential check against MySQL |
| Register | Stored in memory / local device only | Creates a real row in the `students` table |
| Teachers | Bundled 26-teacher dataset (`assets/data/teachers.json`) | Same dataset, plus live teacher-request creation for teachers that exist in the database |
| Profile edits | Local only | Persisted to MySQL, with pull-to-refresh to re-sync |
| Teacher acceptance | Simulated automatically after a few seconds, for demo purposes | Requires a real accepted row in `teacher_requests` |

---

## Known Limitations

- Dark mode does not yet extend to the Courses, Progress, Schedule, and Settings screens (see [Design System](#design-system)).
- The PHP API layer has no authentication token/session beyond the login check itself — suitable for local development and coursework, not for a public-facing deployment as-is.
- Teacher *acceptance* (a teacher approving a student's request) is not modelled from the student app's side — it's either simulated (demo mode) or requires a direct database update (live mode), since there's no teacher-facing app in this repository.
- The bundled 26-teacher dataset is a static catalogue; only teachers that also exist as rows in the live `teachers` table can receive real requests in live mode.

---

## Contributing

1. Fork the repository and create a feature branch.
2. Keep new widgets/screens consistent with the existing structure — reusable UI goes in `core/widgets/`, screen-specific UI stays local to its screen file.
3. Route any new data source through `AppState` rather than reading it directly from a screen.
4. Run `flutter analyze` and `flutter test` before opening a pull request.
