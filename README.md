# Endelea

*Endelea* means "keep going" in Swahili.

Endelea is a workout tracker for training at the gym or at home. This is an
early prototype: data lives in memory and the app starts with a few demo
workouts.

## Features

- **Exercise library**: built-in gym and home exercises, filter by place and
  muscle group, search by name, and create your own exercises.
- **Progress**: personal records, estimated one rep max and a progress chart
  on each exercise.
- **Workouts**: start a gym or home workout, add exercises, log weight, reps or
  duration for each set, mark sets as done and add notes. Each exercise shows
  what you did last time.
- **Routines**: reusable workout templates, created from scratch or saved from
  a past workout.
- **Rest timer**: starts automatically when a set is completed, with +15s and
  skip, and keeps running when leaving the workout screen.
- **History**: finished workouts grouped by week, with a detail page per
  workout.
- **Today**: weekly activity, training streak, weekly volume and recent
  workouts.
- **Settings**: light, dark or system theme, weights in kg or lb and default
  rest duration.

## Project structure

```
lib/
  app/        theme and the scopes exposing the stores
  data/       stores, exercise catalog, stats, progress, demo data
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

Run the tests with:

```sh
flutter test
```

## Roadmap

- Save workouts on the device
- Backup and sync
