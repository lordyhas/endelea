# Endelea

*Endelea* means "keep going" in Swahili.

Endelea is a workout tracker for training at the gym or at home. This is an
early prototype: data lives in memory and the app starts with a few demo
workouts.

## Features

- **Exercise library**: built-in gym and home exercises, filter by place and
  muscle group, search by name, and create your own exercises.
- **Progress**: personal records, estimated one rep max and a progress chart
  on each exercise. Finishing a workout tells you about new records.
- **Workouts**: start a gym or home workout, add exercises, log weight, reps or
  duration for each set, mark sets as done and add notes. Each exercise shows
  what you did last time.
- **Routines**: reusable workout templates, created from scratch, saved from
  a past workout or duplicated from another routine.
- **Rest timer**: starts automatically when a set is completed, with +15s and
  skip, and keeps running when leaving the workout screen.
- **History**: all-time totals and finished workouts grouped by week, with a
  detail page per workout to repeat it, save it as a routine or delete it.
- **Today**: weekly goal, weekly activity, training streak, weekly volume and
  recent workouts.
- **Settings**: light, dark or system theme, weekly goal, weights in kg or lb,
  default rest duration, copy or restore all data as JSON and erase all data.
- **Backup**: back up to the hidden app folder of Google Drive and restore on
  another device.
- **Saved on the device**: workouts, the workout in progress, routines, custom
  exercises and settings are kept as JSON files in the app documents folder.
  The first launch starts with demo data.

## Project structure

```
lib/
  app/        theme and the scopes exposing the stores
  data/       stores, saving and loading, exercise catalog, stats, progress,
              demo data
    storage/  json files on the device
    sync/     cloud backup and the Google Drive provider
  models/     exercise, workout, template and settings models
  screens/    app screens
  utils/      formatting helpers
  widgets/    reusable widgets
test/         unit and widget tests
```

## Getting started

```sh
flutter pub get
flutter run
```

### Google Drive backup

Backup needs an OAuth client in a Google Cloud project with the Drive API
enabled. The app only asks for the `drive.appdata` scope, so it can only see
its own backup file.

- Android: add an Android OAuth client with the package name and the SHA-1 of
  your signing key.
- iOS: add an iOS OAuth client and its reversed client id as a URL scheme in
  `ios/Runner/Info.plist`.

Without this setup the app works as usual and only the backup fails.

Run the tests with:

```sh
flutter test
```

## Roadmap

- Automatic backup
