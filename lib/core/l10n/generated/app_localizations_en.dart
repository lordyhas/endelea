// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Endelea';

  @override
  String get navHome => 'Home';

  @override
  String get navPrograms => 'Programs';

  @override
  String get navSession => 'Workout';

  @override
  String get navHistory => 'History';

  @override
  String get navProgress => 'Progress';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get delete => 'Delete';

  @override
  String get save => 'Save';

  @override
  String get ok => 'OK';

  @override
  String get setColumnSet => 'Set';

  @override
  String get setColumnPrevious => 'Previous';

  @override
  String get setColumnReps => 'Reps';

  @override
  String get setColumnTime => 'Time';

  @override
  String get setColumnDistance => 'km';

  @override
  String get unitKg => 'kg';

  @override
  String get unitLb => 'lb';

  @override
  String get warmupShort => 'W';

  @override
  String get warmupLabel => 'Warm-up';

  @override
  String get setDone => 'Done';

  @override
  String get setPending => 'To do';

  @override
  String get setCurrent => 'Current';

  @override
  String get restTitle => 'Rest';

  @override
  String get restSkip => 'Skip';

  @override
  String get restMinus15 => '−15 s';

  @override
  String get restPlus15 => '+15 s';

  @override
  String restRemaining(String time) {
    return 'Rest, $time left';
  }

  @override
  String get personalRecord => 'Record';

  @override
  String get syncUpToDate => 'Up to date';

  @override
  String get syncInProgress => 'Syncing…';

  @override
  String get syncError => 'Sync error';

  @override
  String get syncDisabled => 'Sync off';

  @override
  String get weightLabel => 'Weight';

  @override
  String get repsLabel => 'Reps';

  @override
  String get durationLabel => 'Duration';

  @override
  String get distanceLabel => 'Distance';

  @override
  String stepperSemantics(String label, String value, String unit) {
    return '$label, $value $unit';
  }

  @override
  String get stepperIncrease => 'Increase';

  @override
  String get stepperDecrease => 'Decrease';

  @override
  String get unitKilos => 'kilos';

  @override
  String get unitPounds => 'pounds';

  @override
  String get unitRepetitions => 'reps';

  @override
  String get unitSeconds => 'seconds';

  @override
  String get unitMinutesShort => 'min';

  @override
  String get enterValue => 'Enter a value';

  @override
  String programDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
      zero: 'No days',
    );
    return '$_temp0';
  }

  @override
  String programLastSession(String date) {
    return 'Last workout: $date';
  }

  @override
  String get programNeverStarted => 'Not started yet';

  @override
  String get programActive => 'Active';

  @override
  String get start => 'Start';

  @override
  String get muscleChest => 'Chest';

  @override
  String get muscleBack => 'Back';

  @override
  String get muscleShoulders => 'Shoulders';

  @override
  String get muscleBiceps => 'Biceps';

  @override
  String get muscleTriceps => 'Triceps';

  @override
  String get muscleLegs => 'Legs';

  @override
  String get muscleGlutes => 'Glutes';

  @override
  String get muscleCore => 'Core';

  @override
  String get muscleCardio => 'Cardio';

  @override
  String get muscleFullBody => 'Full body';

  @override
  String get equipmentBarbell => 'Barbell';

  @override
  String get equipmentDumbbell => 'Dumbbell';

  @override
  String get equipmentMachine => 'Machine';

  @override
  String get equipmentCable => 'Cable';

  @override
  String get equipmentBodyweight => 'Bodyweight';

  @override
  String get equipmentKettlebell => 'Kettlebell';

  @override
  String get equipmentBand => 'Band';

  @override
  String get equipmentOther => 'Other';

  @override
  String get trackingWeightReps => 'Weight and reps';

  @override
  String get trackingRepsOnly => 'Reps only';

  @override
  String get trackingDuration => 'Duration';

  @override
  String get trackingDistance => 'Distance and time';

  @override
  String get exerciseCustom => 'Custom';

  @override
  String get galleryTitle => 'Gallery';

  @override
  String get galleryToggleTheme => 'Toggle theme';

  @override
  String get emptyGalleryTitle => 'Nothing here';

  @override
  String get emptyGalleryMessage => 'Empty state example.';

  @override
  String get programsEmptyTitle => 'Create your first program';

  @override
  String get programsEmptyMessage =>
      'A program groups your training days and their exercises.';

  @override
  String get programNew => 'New program';

  @override
  String get programName => 'Program name';

  @override
  String get programDescription => 'Description';

  @override
  String get programRename => 'Rename';

  @override
  String get programDuplicate => 'Duplicate';

  @override
  String get programActivate => 'Set as active';

  @override
  String get programDelete => 'Delete program';

  @override
  String programDeleteMessage(String name) {
    return '“$name” and its days will be deleted. Your workout history is kept.';
  }

  @override
  String programCopyName(String name) {
    return '$name (copy)';
  }

  @override
  String get programMenu => 'Program options';

  @override
  String get programEdit => 'Edit program';

  @override
  String get programDaysTitle => 'Days';

  @override
  String get dayAdd => 'Add a day';

  @override
  String get dayName => 'Day name';

  @override
  String dayDefaultName(String letter) {
    return 'Day $letter';
  }

  @override
  String get dayRename => 'Rename day';

  @override
  String get dayDelete => 'Delete day';

  @override
  String dayDeleteMessage(String name) {
    return '“$name” and its exercises will be deleted.';
  }

  @override
  String dayExercises(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count exercises',
      one: '1 exercise',
      zero: 'No exercises',
    );
    return '$_temp0';
  }

  @override
  String get daysEmptyTitle => 'Add a first day';

  @override
  String get daysEmptyMessage => 'For example “Push”, “Pull” and “Legs”.';

  @override
  String get dayEmptyTitle => 'No exercises yet';

  @override
  String get dayEmptyMessage => 'Add the exercises of this day.';

  @override
  String get reorder => 'Reorder';

  @override
  String get exerciseAdd => 'Add an exercise';

  @override
  String exerciseAddCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Add ($count)',
      zero: 'Add',
    );
    return '$_temp0';
  }

  @override
  String get targetsTitle => 'Targets';

  @override
  String get targetSets => 'Sets';

  @override
  String get targetRepsMin => 'Min reps';

  @override
  String get targetRepsMax => 'Max reps';

  @override
  String get targetNoWeight => 'No weight';

  @override
  String get notes => 'Notes';

  @override
  String setsTimesReps(int sets, String reps) {
    return '$sets × $reps';
  }

  @override
  String restShort(String time) {
    return 'rest $time';
  }

  @override
  String get removeFromDay => 'Remove from day';

  @override
  String get exercisesTitle => 'Exercises';

  @override
  String get exerciseSearch => 'Search exercises';

  @override
  String get exerciseCreate => 'Create an exercise';

  @override
  String get exerciseEdit => 'Edit exercise';

  @override
  String get exerciseNameLabel => 'Exercise name';

  @override
  String get exerciseMuscleGroup => 'Muscle group';

  @override
  String get exerciseEquipment => 'Equipment';

  @override
  String get exerciseTracking => 'Tracking';

  @override
  String get exercisesNoResultTitle => 'No exercise found';

  @override
  String get exercisesNoResultMessage =>
      'Try another word, or create this exercise.';

  @override
  String get exerciseDelete => 'Delete exercise';

  @override
  String exerciseDeleteMessage(String name) {
    return '“$name” will be removed from the library. Past workouts are kept.';
  }

  @override
  String get clearFilters => 'Clear filters';

  @override
  String get nameRequired => 'Enter a name';

  @override
  String get create => 'Create';

  @override
  String get edit => 'Edit';

  @override
  String get more => 'More options';

  @override
  String get errorGeneric => 'Something went wrong.';

  @override
  String get notFound => 'Not found';

  @override
  String get sessionFree => 'Free workout';

  @override
  String get sessionNextTitle => 'Next workout';

  @override
  String get sessionChooseDay => 'Or pick a day';

  @override
  String get sessionNoProgramTitle => 'No active program';

  @override
  String get sessionNoProgramMessage =>
      'Create a program, or start a free workout.';

  @override
  String get sessionStartFree => 'Start a free workout';

  @override
  String sessionStartDay(String day) {
    return 'Start $day';
  }

  @override
  String sessionExerciseOf(int index, int count) {
    return 'Exercise $index of $count';
  }

  @override
  String sessionTarget(String target) {
    return 'target $target';
  }

  @override
  String get setValidate => 'Complete set';

  @override
  String get restSkipAction => 'Skip rest';

  @override
  String get nextExercise => 'Next exercise';

  @override
  String get previousExercise => 'Previous exercise';

  @override
  String get finishSession => 'Finish workout';

  @override
  String get addSet => 'Add a set';

  @override
  String get removeSet => 'Delete set';

  @override
  String get markWarmup => 'Warm-up';

  @override
  String get sessionPause => 'Pause';

  @override
  String get sessionResume => 'Resume';

  @override
  String get sessionPaused => 'Paused';

  @override
  String get sessionDiscard => 'Discard workout';

  @override
  String get sessionDiscardMessage =>
      'The workout and its sets will be deleted.';

  @override
  String get sessionDiscardConfirm => 'Discard';

  @override
  String get sessionFinishMessage => 'Sets not completed will not be saved.';

  @override
  String get sessionMinimize => 'Minimize';

  @override
  String get sessionMenu => 'Workout options';

  @override
  String get sessionExercises => 'Workout exercises';

  @override
  String get sessionEmptyTitle => 'Empty workout';

  @override
  String get sessionEmptyMessage => 'Add an exercise to begin.';

  @override
  String get exerciseNotes => 'Exercise notes';

  @override
  String get resumeSession => 'Resume workout';

  @override
  String get sessionInProgress => 'Workout in progress';

  @override
  String nextSetLabel(int index, String exercise) {
    return 'Set $index · $exercise';
  }

  @override
  String get exerciseDone => 'Exercise done';

  @override
  String get sessionComplete => 'Every set is done.';

  @override
  String get restOverTitle => 'Rest is over';

  @override
  String get restOverBody => 'Time for your next set.';

  @override
  String get restChannelName => 'End of rest';

  @override
  String get restChannelDescription => 'Rings at the end of each rest.';

  @override
  String get summaryTitle => 'Workout summary';

  @override
  String get summaryDuration => 'Duration';

  @override
  String get summaryVolume => 'Volume';

  @override
  String get summarySets => 'Sets';

  @override
  String get summaryRecords => 'Records';

  @override
  String get summaryNoRecords => 'No record this time. Keep going.';

  @override
  String get summaryVsPrevious => 'Compared with last time';

  @override
  String summaryVolumeDelta(String delta) {
    return '$delta volume';
  }

  @override
  String summaryDurationDelta(String delta) {
    return '$delta duration';
  }

  @override
  String get summaryFirstTime => 'First time for this workout.';

  @override
  String get summaryNote => 'Workout note';

  @override
  String get summaryDone => 'Done';

  @override
  String get recordMaxWeight => 'Heaviest weight';

  @override
  String get recordOneRepMax => 'Estimated 1RM';

  @override
  String get recordRepsAtWeight => 'Reps at this weight';

  @override
  String get recordSessionVolume => 'Workout volume';

  @override
  String durationMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours h $minutes min';
  }

  @override
  String get exercise_bench_press => 'Bench press';

  @override
  String get exercise_incline_bench_press => 'Incline bench press';

  @override
  String get exercise_decline_bench_press => 'Decline bench press';

  @override
  String get exercise_dumbbell_bench_press => 'Dumbbell bench press';

  @override
  String get exercise_incline_dumbbell_press => 'Incline dumbbell press';

  @override
  String get exercise_dumbbell_fly => 'Dumbbell fly';

  @override
  String get exercise_cable_crossover => 'Cable crossover';

  @override
  String get exercise_chest_press_machine => 'Machine chest press';

  @override
  String get exercise_pec_deck => 'Pec deck';

  @override
  String get exercise_push_up => 'Push-up';

  @override
  String get exercise_chest_dip => 'Chest dip';

  @override
  String get exercise_deadlift => 'Deadlift';

  @override
  String get exercise_barbell_row => 'Barbell row';

  @override
  String get exercise_t_bar_row => 'T-bar row';

  @override
  String get exercise_dumbbell_row => 'One-arm dumbbell row';

  @override
  String get exercise_pull_up => 'Pull-up';

  @override
  String get exercise_chin_up => 'Chin-up';

  @override
  String get exercise_lat_pulldown => 'Lat pulldown';

  @override
  String get exercise_seated_cable_row => 'Seated cable row';

  @override
  String get exercise_face_pull => 'Face pull';

  @override
  String get exercise_back_extension => 'Back extension';

  @override
  String get exercise_overhead_press => 'Overhead press';

  @override
  String get exercise_dumbbell_shoulder_press => 'Dumbbell shoulder press';

  @override
  String get exercise_arnold_press => 'Arnold press';

  @override
  String get exercise_shoulder_press_machine => 'Machine shoulder press';

  @override
  String get exercise_lateral_raise => 'Lateral raise';

  @override
  String get exercise_cable_lateral_raise => 'Cable lateral raise';

  @override
  String get exercise_front_raise => 'Front raise';

  @override
  String get exercise_rear_delt_fly => 'Rear delt fly';

  @override
  String get exercise_upright_row => 'Upright row';

  @override
  String get exercise_shrug => 'Shrug';

  @override
  String get exercise_band_pull_apart => 'Band pull-apart';

  @override
  String get exercise_barbell_curl => 'Barbell curl';

  @override
  String get exercise_dumbbell_curl => 'Dumbbell curl';

  @override
  String get exercise_hammer_curl => 'Hammer curl';

  @override
  String get exercise_incline_dumbbell_curl => 'Incline dumbbell curl';

  @override
  String get exercise_preacher_curl => 'Preacher curl';

  @override
  String get exercise_cable_curl => 'Cable curl';

  @override
  String get exercise_close_grip_bench_press => 'Close-grip bench press';

  @override
  String get exercise_skull_crusher => 'Skull crusher';

  @override
  String get exercise_triceps_pushdown => 'Triceps pushdown';

  @override
  String get exercise_overhead_triceps_extension =>
      'Overhead triceps extension';

  @override
  String get exercise_triceps_dip => 'Triceps dip';

  @override
  String get exercise_back_squat => 'Back squat';

  @override
  String get exercise_front_squat => 'Front squat';

  @override
  String get exercise_hack_squat => 'Hack squat';

  @override
  String get exercise_leg_press => 'Leg press';

  @override
  String get exercise_goblet_squat => 'Goblet squat';

  @override
  String get exercise_romanian_deadlift => 'Romanian deadlift';

  @override
  String get exercise_bulgarian_split_squat => 'Bulgarian split squat';

  @override
  String get exercise_walking_lunge => 'Walking lunge';

  @override
  String get exercise_leg_extension => 'Leg extension';

  @override
  String get exercise_leg_curl => 'Leg curl';

  @override
  String get exercise_calf_raise => 'Calf raise';

  @override
  String get exercise_hip_thrust => 'Hip thrust';

  @override
  String get exercise_glute_bridge => 'Glute bridge';

  @override
  String get exercise_cable_kickback => 'Cable kickback';

  @override
  String get exercise_hip_abduction => 'Hip abduction';

  @override
  String get exercise_plank => 'Plank';

  @override
  String get exercise_side_plank => 'Side plank';

  @override
  String get exercise_crunch => 'Crunch';

  @override
  String get exercise_cable_crunch => 'Cable crunch';

  @override
  String get exercise_hanging_leg_raise => 'Hanging leg raise';

  @override
  String get exercise_russian_twist => 'Russian twist';

  @override
  String get exercise_ab_wheel_rollout => 'Ab wheel rollout';

  @override
  String get exercise_treadmill_run => 'Treadmill run';

  @override
  String get exercise_rowing_machine => 'Rowing machine';

  @override
  String get exercise_stationary_bike => 'Stationary bike';

  @override
  String get exercise_elliptical => 'Elliptical';

  @override
  String get exercise_jump_rope => 'Jump rope';

  @override
  String get exercise_kettlebell_swing => 'Kettlebell swing';

  @override
  String get exercise_power_clean => 'Power clean';

  @override
  String get exercise_thruster => 'Thruster';

  @override
  String get exercise_burpee => 'Burpee';

  @override
  String get exercise_farmers_walk => 'Farmer\'s walk';
}
