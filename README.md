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
  duration for each set, mark sets as done or as warm-ups, reorder exercises
  and add notes. Each exercise shows what you did last time. Warm-up sets do
  not count in volume and records.
- **Routines**: reusable workout templates, created from scratch, saved from
  a past workout or duplicated from another routine. Drag exercises to reorder
  them.
- **Rest timer**: starts automatically when a set is completed, with +15s and
  skip, and keeps running when leaving the workout screen.
- **History**: all-time totals and finished workouts grouped by week, with a detail page per workout to repeat it, save it as a routine or
  delete it.
- **Today**: weekly goal, weekly activity, training streak, weekly volume and
  recent workouts.
- **Settings**: light, dark or system theme, weekly goal, weights in kg or lb,
  default rest duration and erase all data.
- **Saved on the device**: workouts, the workout in progress, routines, custom
  exercises and settings are kept as JSON files in the app documents folder.
  The first launch starts with demo data.

## Tips

- Tap a set number to turn it into a warm-up set.
- A workout keeps running in the background, resume it from Today.

## Project structure

```
lib/
  app/        theme and the scopes exposing the stores
  data/       stores, saving and loading, exercise catalog, stats, progress,
              demo data
    storage/  json files on the device
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

- Rest timer per exercise
- Body weight tracking
