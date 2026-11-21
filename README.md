# Endelea

*Endelea* (Swahili): "keep going, move forward without giving up".

A gym workout tracker for Android and iOS, built with Flutter:

- **Programs**: days, exercises and targets (sets, rep range, weight, rest).
- **Guided sessions**: exercise by exercise, set by set, one tap to complete a
  set, automatic rest timer that survives the app going to the background or
  being closed, with a notification at the end.
- **Progress**: personal records, estimated 1RM, weekly volume, curves per
  exercise, body weight.
- **Offline-first**: everything lives in a local SQLite database. Optional sync
  through the user's own Google Drive (hidden app folder), JSON export and
  import, Android Auto Backup.
- French and English, dark theme by default.

The design plan is in [`docs/PLAN.md`](docs/PLAN.md).

## Build

Requirements: Flutter 3.47 (stable), Android SDK with API 37.

```bash
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

Sync needs a Google Cloud project (see [`docs/PLAN.md`](docs/PLAN.md) §13):

1. Enable the Google Drive API.
2. Configure the OAuth consent screen with the `drive.appdata` scope only.
3. Create an **Android** OAuth client for `com.kdynamics.endelea` with the
   SHA-1 of the debug and release keys
   (`keytool -list -v -keystore <keystore>`).
4. Create a **Web** OAuth client and pass its id at build time:

```bash
flutter run --dart-define=GOOGLE_SERVER_CLIENT_ID=<web-client-id>
```

In CI, set it as the repository variable `GOOGLE_SERVER_CLIENT_ID`.

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
lib/
  core/       theme, router, l10n, shared widgets, utils
  data/       Drift schema, repositories (the only writers), seed
  domain/     pure logic: session rules, progress calculations
  sync/       cloud provider, codec, sync engine
  features/   one folder per screen area (bloc/ + view/)
third_party/  phosphor_flutter, patched for the current Flutter
tool/         icon generator
```

## License

Fonts: Inter (SIL Open Font License, `assets/fonts/OFL.txt`). Icons: Phosphor
(MIT, `third_party/phosphor_flutter/LICENSE`).
