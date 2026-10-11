# Endelea

*Endelea* means "keep going" in Swahili.

Endelea is a simple mockup of a workout tracker for the gym or home. Nothing
is saved: the app starts with a few demo workouts each time and everything
lives in memory.

## Screens

- **Today**: workouts this week against a goal of 3, streak, weekly volume
  and the last workouts.
- **Exercises**: the built-in exercise list, filtered by place, muscle group
  or name.
- **History**: finished workouts grouped by week, with a detail page to
  repeat or delete a workout.
- **Workout**: start a gym or home workout, add exercises, log weight, reps
  or duration for each set and finish it.

## Reading the code

Start with `lib/main.dart`, then follow these files:

1. `models/`: `Exercise` and `Workout`, plain Dart classes.
2. `data/workout_store.dart`: the only state of the app, the active workout
   and the history. `app/store_scope.dart` makes it available to screens with
   `StoreScope.of(context)`.
3. `data/exercise_catalog.dart` and `data/demo_data.dart`: the fixed data.
4. `screens/home_shell.dart`: the bottom navigation, then each screen.

```
lib/
  app/        theme, app name and the store scope
  data/       workout store, exercise catalog, demo data, weekly stats
  models/     exercise and workout
  screens/    app screens
  utils/      formatting helpers
  widgets/    small reusable widgets
test/         a few unit and widget tests
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
