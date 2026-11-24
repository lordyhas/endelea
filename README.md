# Endelea

[![CI](https://github.com/lordyhas/endelea/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/lordyhas/endelea/actions/workflows/ci.yml)
[![Latest release](https://img.shields.io/github/v/release/lordyhas/endelea)](https://github.com/lordyhas/endelea/releases/latest)
[![License: AGPL-3.0](https://img.shields.io/github/license/lordyhas/endelea)](LICENSE)
![Android 7.0+](https://img.shields.io/badge/Android-7.0%2B%20(API%2024)-3DDC84)

*Endelea* : "keep going, move forward without giving up".

A gym workout tracker for Android and iOS: plan your programs, follow your sessions set
by set with a rest timer, and watch your progress, even without a connection.

- **Programs**: days, exercises and targets (sets, rep range, weight, rest).
- **Exercise library**: 76 built-in exercises by muscle group and equipment,
  plus your own.
- **Guided sessions**: exercise by exercise, set by set, one tap to complete a
  set, automatic rest timer that survives the app going to the background or
  being closed, with a notification at the end. An interrupted session can be
  resumed from the home screen.
- **History**: every finished session with its sets.
- **Progress**: personal records, estimated 1RM, weekly volume, curves per
  exercise, body weight.
- **Offline-first**: everything lives in a local SQLite database. Optional sync
  through the user's own Google Drive (hidden app folder), JSON export and
  import, Android Auto Backup.
- French and English, dark theme by default.

The design plan is in [`docs/PLAN.md`](docs/PLAN.md).

## Download

Get the latest APK from the
[Releases page](https://github.com/lordyhas/endelea/releases/latest) and
install it on an Android 7.0 (API 24) or newer device. You may need to allow
installing apps from your browser or file manager.

## Build

Requirements: Flutter 3.47 (stable), Android SDK with API 37. The commands are
the same on Linux, macOS and Windows.

```sh
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # Drift code
flutter gen-l10n                                            # strings
flutter analyze
flutter test
flutter run
```

Generated files (`*.g.dart`, `lib/core/l10n/generated/`) are committed; CI
checks that they are up to date.

### Google Drive sync

Sync is set up for Android only for now. It needs a Google Cloud project (see [`docs/PLAN.md`](docs/PLAN.md) §13):

1. Enable the Google Drive API.
2. Configure the OAuth consent screen with the `drive.appdata` scope only.
3. Create an **Android** OAuth client for `com.kdynamics.endelea` with the
   SHA-1 of the debug and release keys
   (`keytool -list -v -keystore <keystore>`).
4. Create a **Web** OAuth client and pass its id at build time:

```sh
flutter run --dart-define=GOOGLE_SERVER_CLIENT_ID=<web-client-id>
```

For release builds, set it as the repository variable `GOOGLE_SERVER_CLIENT_ID`
(read by the release workflow).

## Release

Merging into the `production` branch builds a signed APK and publishes it as a
GitHub Release (`.github/workflows/release.yml`). Bump `version` in
`pubspec.yaml` (and `lib/core/app_info.dart`) first: a release fails on purpose
if its version already exists.

Local release builds read `keystore.properties` at the project root (never
committed):

```properties
storeFile=/path/to/endelea-release.jks
storePassword=…
keyAlias=release
keyPassword=…
```

## Project layout

```
endelea/
├── lib/
│   ├── main.dart                   # Entry point: database, sync, notifications
│   ├── app.dart                    # Root widget: theme, router, languages
│   ├── core/
│   │   ├── l10n/                   # French and English strings (ARB files)
│   │   ├── router/                 # Navigation (go_router)
│   │   ├── theme/                  # Colors, typography, spacing
│   │   ├── utils/                  # Clock, dates, units (kg / lb)
│   │   └── widgets/                # Shared widgets: buttons, cards, rest timer
│   ├── data/
│   │   ├── database.dart           # Drift (SQLite) schema
│   │   ├── repositories/           # The only writers: programs, sessions...
│   │   └── seed/                   # The 76 built-in exercises
│   ├── domain/
│   │   ├── models/                 # Programs, sessions, exercise types
│   │   ├── progress/               # Estimated 1RM, records, volume, stats
│   │   └── session/                # Session rules and planning
│   ├── sync/                       # Google Drive sync engine
│   └── features/                   # One folder per screen area (bloc/ + view/)
│       ├── home/                   # Home, resume an interrupted session
│       ├── programs/               # Program and day editors, targets
│       ├── exercises/              # Exercise library and details
│       ├── session/                # Guided session, rest timer, summary
│       ├── history/                # Past sessions
│       ├── progress/               # Charts and personal records
│       ├── body/                   # Body weight
│       └── settings/               # Settings, sync, export / import
├── test/                           # Unit, bloc and widget tests (mirrors lib/)
├── android/  ios/                  # Platform projects
├── assets/fonts/                   # Inter font
├── third_party/phosphor_flutter/   # Icons, patched for the current Flutter
├── tool/make_icons.py              # Launcher icon and splash generator
├── app_logo/                       # Source app icons
├── docs/                           # Design plan, store assets
└── website/                        # Website and privacy policy (Cloudflare)
```

## License

Endelea is licensed under the [GNU Affero General Public License v3.0](LICENSE).
You can use, change and share it, but any version you distribute or run as a
network service must be released under the same license, with its source code.

Third-party assets keep their own licenses. Fonts: Inter (SIL Open Font License, `assets/fonts/OFL.txt`). Icons: Phosphor
(MIT, `third_party/phosphor_flutter/LICENSE`).
