// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Endelea';

  @override
  String get navHome => 'Accueil';

  @override
  String get navPrograms => 'Programmes';

  @override
  String get navSession => 'Séance';

  @override
  String get navHistory => 'Historique';

  @override
  String get navProgress => 'Progrès';

  @override
  String get comingSoon => 'Bientôt ici';

  @override
  String get cancel => 'Annuler';

  @override
  String get confirm => 'Confirmer';

  @override
  String get delete => 'Supprimer';

  @override
  String get save => 'Enregistrer';

  @override
  String get ok => 'OK';

  @override
  String get setColumnSet => 'Série';

  @override
  String get setColumnPrevious => 'Précédent';

  @override
  String get setColumnReps => 'Reps';

  @override
  String get setColumnTime => 'Durée';

  @override
  String get setColumnDistance => 'km';

  @override
  String get unitKg => 'kg';

  @override
  String get unitLb => 'lb';

  @override
  String get warmupShort => 'É';

  @override
  String get warmupLabel => 'Échauffement';

  @override
  String get setDone => 'Validée';

  @override
  String get setPending => 'À faire';

  @override
  String get setCurrent => 'En cours';

  @override
  String get restTitle => 'Repos';

  @override
  String get restSkip => 'Passer';

  @override
  String get restMinus15 => '−15 s';

  @override
  String get restPlus15 => '+15 s';

  @override
  String restRemaining(String time) {
    return 'Repos, $time restant';
  }

  @override
  String get personalRecord => 'Record';

  @override
  String get syncUpToDate => 'À jour';

  @override
  String get syncInProgress => 'Synchro…';

  @override
  String get syncError => 'Erreur de synchro';

  @override
  String get syncDisabled => 'Synchro désactivée';

  @override
  String get weightLabel => 'Charge';

  @override
  String get repsLabel => 'Répétitions';

  @override
  String get durationLabel => 'Durée';

  @override
  String get distanceLabel => 'Distance';

  @override
  String stepperSemantics(String label, String value, String unit) {
    return '$label, $value $unit';
  }

  @override
  String get stepperIncrease => 'Augmenter';

  @override
  String get stepperDecrease => 'Diminuer';

  @override
  String get unitKilos => 'kilos';

  @override
  String get unitPounds => 'livres';

  @override
  String get unitRepetitions => 'répétitions';

  @override
  String get unitSeconds => 'secondes';

  @override
  String get unitMinutesShort => 'min';

  @override
  String get enterValue => 'Saisir une valeur';

  @override
  String programDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jours',
      one: '1 jour',
      zero: 'Aucun jour',
    );
    return '$_temp0';
  }

  @override
  String programLastSession(String date) {
    return 'Dernière séance : $date';
  }

  @override
  String get programNeverStarted => 'Pas encore commencé';

  @override
  String get programActive => 'Actif';

  @override
  String get start => 'Démarrer';

  @override
  String get muscleChest => 'Pectoraux';

  @override
  String get muscleBack => 'Dos';

  @override
  String get muscleShoulders => 'Épaules';

  @override
  String get muscleBiceps => 'Biceps';

  @override
  String get muscleTriceps => 'Triceps';

  @override
  String get muscleLegs => 'Jambes';

  @override
  String get muscleGlutes => 'Fessiers';

  @override
  String get muscleCore => 'Abdos';

  @override
  String get muscleCardio => 'Cardio';

  @override
  String get muscleFullBody => 'Corps entier';

  @override
  String get equipmentBarbell => 'Barre';

  @override
  String get equipmentDumbbell => 'Haltères';

  @override
  String get equipmentMachine => 'Machine';

  @override
  String get equipmentCable => 'Poulie';

  @override
  String get equipmentBodyweight => 'Poids du corps';

  @override
  String get equipmentKettlebell => 'Kettlebell';

  @override
  String get equipmentBand => 'Élastique';

  @override
  String get equipmentOther => 'Autre';

  @override
  String get trackingWeightReps => 'Charge et reps';

  @override
  String get trackingRepsOnly => 'Reps seulement';

  @override
  String get trackingDuration => 'Durée';

  @override
  String get trackingDistance => 'Distance et durée';

  @override
  String get exerciseCustom => 'Personnalisé';

  @override
  String get galleryTitle => 'Galerie';

  @override
  String get galleryToggleTheme => 'Changer de thème';

  @override
  String get emptyGalleryTitle => 'Rien ici';

  @override
  String get emptyGalleryMessage => 'Exemple d’état vide.';

  @override
  String get programsEmptyTitle => 'Crée ton premier programme';

  @override
  String get programsEmptyMessage =>
      'Un programme regroupe tes jours d’entraînement et leurs exercices.';

  @override
  String get programNew => 'Nouveau programme';

  @override
  String get programName => 'Nom du programme';

  @override
  String get programDescription => 'Description';

  @override
  String get programRename => 'Renommer';

  @override
  String get programDuplicate => 'Dupliquer';

  @override
  String get programActivate => 'Activer';

  @override
  String get programDelete => 'Supprimer le programme';

  @override
  String programDeleteMessage(String name) {
    return '« $name » et ses jours seront supprimés. L’historique des séances est conservé.';
  }

  @override
  String programCopyName(String name) {
    return '$name (copie)';
  }

  @override
  String get programMenu => 'Options du programme';

  @override
  String get programEdit => 'Modifier le programme';

  @override
  String get programDaysTitle => 'Jours';

  @override
  String get dayAdd => 'Ajouter un jour';

  @override
  String get dayName => 'Nom du jour';

  @override
  String dayDefaultName(String letter) {
    return 'Jour $letter';
  }

  @override
  String get dayRename => 'Renommer le jour';

  @override
  String get dayDelete => 'Supprimer le jour';

  @override
  String dayDeleteMessage(String name) {
    return '« $name » et ses exercices seront supprimés.';
  }

  @override
  String dayExercises(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count exercices',
      one: '1 exercice',
      zero: 'Aucun exercice',
    );
    return '$_temp0';
  }

  @override
  String get daysEmptyTitle => 'Ajoute un premier jour';

  @override
  String get daysEmptyMessage => 'Par exemple « Push », « Pull » et « Legs ».';

  @override
  String get dayEmptyTitle => 'Aucun exercice';

  @override
  String get dayEmptyMessage => 'Ajoute les exercices de ce jour.';

  @override
  String get reorder => 'Réordonner';

  @override
  String get exerciseAdd => 'Ajouter un exercice';

  @override
  String exerciseAddCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ajouter ($count)',
      zero: 'Ajouter',
    );
    return '$_temp0';
  }

  @override
  String get targetsTitle => 'Cibles';

  @override
  String get targetSets => 'Séries';

  @override
  String get targetRepsMin => 'Reps min';

  @override
  String get targetRepsMax => 'Reps max';

  @override
  String get targetNoWeight => 'Sans charge';

  @override
  String get notes => 'Notes';

  @override
  String setsTimesReps(int sets, String reps) {
    return '$sets × $reps';
  }

  @override
  String restShort(String time) {
    return 'repos $time';
  }

  @override
  String get removeFromDay => 'Retirer du jour';

  @override
  String get exercisesTitle => 'Exercices';

  @override
  String get exerciseSearch => 'Rechercher un exercice';

  @override
  String get exerciseCreate => 'Créer un exercice';

  @override
  String get exerciseEdit => 'Modifier l’exercice';

  @override
  String get exerciseNameLabel => 'Nom de l’exercice';

  @override
  String get exerciseMuscleGroup => 'Groupe musculaire';

  @override
  String get exerciseEquipment => 'Équipement';

  @override
  String get exerciseTracking => 'Type de suivi';

  @override
  String get exercisesNoResultTitle => 'Aucun exercice trouvé';

  @override
  String get exercisesNoResultMessage =>
      'Essaie un autre mot, ou crée cet exercice.';

  @override
  String get exerciseDelete => 'Supprimer l’exercice';

  @override
  String exerciseDeleteMessage(String name) {
    return '« $name » disparaîtra de la bibliothèque. Les séances passées sont conservées.';
  }

  @override
  String get clearFilters => 'Effacer les filtres';

  @override
  String get nameRequired => 'Saisis un nom';

  @override
  String get create => 'Créer';

  @override
  String get edit => 'Modifier';

  @override
  String get more => 'Plus d’options';

  @override
  String get errorGeneric => 'Une erreur est survenue.';

  @override
  String get notFound => 'Introuvable';

  @override
  String get exercise_bench_press => 'Développé couché';

  @override
  String get exercise_incline_bench_press => 'Développé incliné';

  @override
  String get exercise_decline_bench_press => 'Développé décliné';

  @override
  String get exercise_dumbbell_bench_press => 'Développé couché haltères';

  @override
  String get exercise_incline_dumbbell_press => 'Développé incliné haltères';

  @override
  String get exercise_dumbbell_fly => 'Écarté haltères';

  @override
  String get exercise_cable_crossover => 'Écarté à la poulie';

  @override
  String get exercise_chest_press_machine => 'Presse pectorale';

  @override
  String get exercise_pec_deck => 'Pec deck';

  @override
  String get exercise_push_up => 'Pompes';

  @override
  String get exercise_chest_dip => 'Dips pectoraux';

  @override
  String get exercise_deadlift => 'Soulevé de terre';

  @override
  String get exercise_barbell_row => 'Rowing barre';

  @override
  String get exercise_t_bar_row => 'Rowing T-bar';

  @override
  String get exercise_dumbbell_row => 'Rowing haltère un bras';

  @override
  String get exercise_pull_up => 'Tractions pronation';

  @override
  String get exercise_chin_up => 'Tractions supination';

  @override
  String get exercise_lat_pulldown => 'Tirage vertical';

  @override
  String get exercise_seated_cable_row => 'Tirage horizontal';

  @override
  String get exercise_face_pull => 'Face pull';

  @override
  String get exercise_back_extension => 'Extension lombaire';

  @override
  String get exercise_overhead_press => 'Développé militaire';

  @override
  String get exercise_dumbbell_shoulder_press => 'Développé épaules haltères';

  @override
  String get exercise_arnold_press => 'Développé Arnold';

  @override
  String get exercise_shoulder_press_machine => 'Presse épaules';

  @override
  String get exercise_lateral_raise => 'Élévations latérales';

  @override
  String get exercise_cable_lateral_raise => 'Élévation latérale à la poulie';

  @override
  String get exercise_front_raise => 'Élévations frontales';

  @override
  String get exercise_rear_delt_fly => 'Oiseau';

  @override
  String get exercise_upright_row => 'Rowing menton';

  @override
  String get exercise_shrug => 'Haussements d\'épaules';

  @override
  String get exercise_band_pull_apart => 'Écarté avec élastique';

  @override
  String get exercise_barbell_curl => 'Curl barre';

  @override
  String get exercise_dumbbell_curl => 'Curl haltères';

  @override
  String get exercise_hammer_curl => 'Curl marteau';

  @override
  String get exercise_incline_dumbbell_curl => 'Curl incliné haltères';

  @override
  String get exercise_preacher_curl => 'Curl pupitre';

  @override
  String get exercise_cable_curl => 'Curl à la poulie';

  @override
  String get exercise_close_grip_bench_press => 'Développé couché prise serrée';

  @override
  String get exercise_skull_crusher => 'Barre au front';

  @override
  String get exercise_triceps_pushdown => 'Extension triceps à la poulie';

  @override
  String get exercise_overhead_triceps_extension =>
      'Extension triceps au-dessus de la tête';

  @override
  String get exercise_triceps_dip => 'Dips triceps';

  @override
  String get exercise_back_squat => 'Squat';

  @override
  String get exercise_front_squat => 'Squat avant';

  @override
  String get exercise_hack_squat => 'Hack squat';

  @override
  String get exercise_leg_press => 'Presse à cuisses';

  @override
  String get exercise_goblet_squat => 'Squat gobelet';

  @override
  String get exercise_romanian_deadlift => 'Soulevé de terre roumain';

  @override
  String get exercise_bulgarian_split_squat => 'Squat bulgare';

  @override
  String get exercise_walking_lunge => 'Fentes marchées';

  @override
  String get exercise_leg_extension => 'Leg extension';

  @override
  String get exercise_leg_curl => 'Leg curl';

  @override
  String get exercise_calf_raise => 'Mollets debout';

  @override
  String get exercise_hip_thrust => 'Hip thrust';

  @override
  String get exercise_glute_bridge => 'Pont fessier';

  @override
  String get exercise_cable_kickback => 'Kickback à la poulie';

  @override
  String get exercise_hip_abduction => 'Abduction de hanche';

  @override
  String get exercise_plank => 'Gainage';

  @override
  String get exercise_side_plank => 'Gainage latéral';

  @override
  String get exercise_crunch => 'Crunch';

  @override
  String get exercise_cable_crunch => 'Crunch à la poulie';

  @override
  String get exercise_hanging_leg_raise => 'Relevé de jambes suspendu';

  @override
  String get exercise_russian_twist => 'Rotation russe';

  @override
  String get exercise_ab_wheel_rollout => 'Roue abdominale';

  @override
  String get exercise_treadmill_run => 'Course sur tapis';

  @override
  String get exercise_rowing_machine => 'Rameur';

  @override
  String get exercise_stationary_bike => 'Vélo d\'appartement';

  @override
  String get exercise_elliptical => 'Vélo elliptique';

  @override
  String get exercise_jump_rope => 'Corde à sauter';

  @override
  String get exercise_kettlebell_swing => 'Swing kettlebell';

  @override
  String get exercise_power_clean => 'Épaulé';

  @override
  String get exercise_thruster => 'Thruster';

  @override
  String get exercise_burpee => 'Burpee';

  @override
  String get exercise_farmers_walk => 'Marche du fermier';
}
