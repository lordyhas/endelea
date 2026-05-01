# Endelea

*Endelea* means "keep going" in Swahili.

Endelea is a workout tracker for training at the gym or at home. This is an
early prototype: data lives in memory and the app starts with a few demo
workouts.

## Features

- **Exercise library**: built-in gym and home exercises, filter by place and
  search by name or muscle group, with a detail page for each exercise.
- **Workouts**: start a gym or home workout, add exercises, log weight, reps or
  duration for each set and mark sets as done.
- **Rest timer**: starts automatically when a set is completed, with +15s and
  skip.
- **History**: finished workouts with duration, sets and volume, and a detail
  page per workout.
- **Today**: weekly activity, training streak, weekly volume and recent
  workouts.

## Project structure

```
lib/
  app/        theme and the store scope
  data/       exercise catalog, workout store, stats, demo data
  models/     exercise and workout models
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
- Custom exercises
- Workout templates
- Progress charts per exercise
- Settings (kg / lb, rest timer duration)
- Backup and sync
