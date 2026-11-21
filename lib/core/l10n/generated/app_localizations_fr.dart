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
  String get cancel => 'Annuler';

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
  String get sessionFree => 'Séance libre';

  @override
  String get sessionNextTitle => 'Prochaine séance';

  @override
  String get sessionChooseDay => 'Ou choisis un jour';

  @override
  String get sessionNoProgramTitle => 'Aucun programme actif';

  @override
  String get sessionNoProgramMessage =>
      'Crée un programme, ou lance une séance libre.';

  @override
  String get sessionStartFree => 'Démarrer une séance libre';

  @override
  String sessionExerciseOf(int index, int count) {
    return 'Exercice $index sur $count';
  }

  @override
  String sessionTarget(String target) {
    return 'cible $target';
  }

  @override
  String get setValidate => 'Valider la série';

  @override
  String get restSkipAction => 'Passer le repos';

  @override
  String get nextExercise => 'Exercice suivant';

  @override
  String get previousExercise => 'Exercice précédent';

  @override
  String get finishSession => 'Terminer la séance';

  @override
  String get addSet => 'Ajouter une série';

  @override
  String get removeSet => 'Supprimer la série';

  @override
  String get markWarmup => 'Échauffement';

  @override
  String get sessionPause => 'Mettre en pause';

  @override
  String get sessionResume => 'Reprendre';

  @override
  String get sessionPaused => 'En pause';

  @override
  String get sessionDiscard => 'Abandonner la séance';

  @override
  String get sessionDiscardMessage =>
      'La séance et ses séries seront supprimées.';

  @override
  String get sessionDiscardConfirm => 'Abandonner';

  @override
  String get sessionFinishMessage =>
      'Les séries non validées ne seront pas enregistrées.';

  @override
  String get sessionMinimize => 'Réduire';

  @override
  String get sessionMenu => 'Options de la séance';

  @override
  String get sessionExercises => 'Exercices de la séance';

  @override
  String get sessionEmptyTitle => 'Séance vide';

  @override
  String get sessionEmptyMessage => 'Ajoute un exercice pour commencer.';

  @override
  String get exerciseNotes => 'Notes de l’exercice';

  @override
  String get resumeSession => 'Reprendre la séance';

  @override
  String get sessionInProgress => 'Séance en cours';

  @override
  String nextSetLabel(int index, String exercise) {
    return 'Série $index · $exercise';
  }

  @override
  String get exerciseDone => 'Exercice terminé';

  @override
  String get sessionComplete => 'Toutes les séries sont faites.';

  @override
  String get restOverTitle => 'Repos terminé';

  @override
  String get restOverBody => 'C’est reparti pour la série suivante.';

  @override
  String get restChannelName => 'Fin du repos';

  @override
  String get restChannelDescription => 'Sonne à la fin de chaque repos.';

  @override
  String get summaryTitle => 'Résumé de la séance';

  @override
  String get summaryDuration => 'Durée';

  @override
  String get summaryVolume => 'Volume';

  @override
  String get summarySets => 'Séries';

  @override
  String get summaryRecords => 'Records battus';

  @override
  String get summaryNoRecords => 'Pas de record cette fois. Continue.';

  @override
  String get summaryVsPrevious => 'Par rapport à la dernière fois';

  @override
  String summaryVolumeDelta(String delta) {
    return '$delta de volume';
  }

  @override
  String summaryDurationDelta(String delta) {
    return '$delta de durée';
  }

  @override
  String get summaryFirstTime => 'Première fois pour cette séance.';

  @override
  String get summaryNote => 'Note sur la séance';

  @override
  String get summaryDone => 'Terminer';

  @override
  String get recordMaxWeight => 'Charge max';

  @override
  String get recordOneRepMax => '1RM estimé';

  @override
  String get recordRepsAtWeight => 'Reps à cette charge';

  @override
  String get recordSessionVolume => 'Volume de la séance';

  @override
  String durationMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours h $minutes min';
  }

  @override
  String get historyEmptyTitle => 'Aucune séance pour l’instant';

  @override
  String get historyEmptyMessage => 'Tes séances terminées apparaîtront ici.';

  @override
  String get historyThisWeek => 'Cette semaine';

  @override
  String historyWeekOf(String date) {
    return 'Semaine du $date';
  }

  @override
  String recordsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count records',
      one: '1 record',
      zero: 'Aucun record',
    );
    return '$_temp0';
  }

  @override
  String sessionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count séances',
      one: '1 séance',
      zero: 'Aucune séance',
    );
    return '$_temp0';
  }

  @override
  String get sessionDelete => 'Supprimer la séance';

  @override
  String get sessionDeleteMessage =>
      'Cette séance sera supprimée de l’historique.';

  @override
  String get editSet => 'Modifier la série';

  @override
  String get periodWeeks4 => '4 sem.';

  @override
  String get periodMonths3 => '3 mois';

  @override
  String get periodYear => '1 an';

  @override
  String get periodAll => 'Tout';

  @override
  String get statSessions => 'Séances';

  @override
  String get statTotalVolume => 'Volume total';

  @override
  String get statRecords => 'Records';

  @override
  String get weeklyVolumeTitle => 'Volume par semaine';

  @override
  String get topExercisesTitle => 'Exercices les plus faits';

  @override
  String get progressEmptyTitle => 'Pas encore de progrès';

  @override
  String get progressEmptyMessage =>
      'Termine une séance pour voir tes courbes.';

  @override
  String get bodyWeightTitle => 'Poids corporel';

  @override
  String bodyWeightLatest(String weight) {
    return 'Dernière mesure : $weight';
  }

  @override
  String get bodyEmptyTitle => 'Aucune mesure';

  @override
  String get bodyEmptyMessage =>
      'Ajoute ta première pesée pour suivre ta courbe.';

  @override
  String get bodyAdd => 'Ajouter une mesure';

  @override
  String get bodyFat => 'Masse grasse';

  @override
  String bodyFatShort(String value) {
    return '$value % de gras';
  }

  @override
  String get bodyMeasurementDelete => 'Supprimer la mesure';

  @override
  String get chartMaxWeight => 'Charge max';

  @override
  String get chartOneRepMax => '1RM estimé';

  @override
  String get chartVolume => 'Volume';

  @override
  String get chartReps => 'Reps max';

  @override
  String get exerciseRecords => 'Records';

  @override
  String get exerciseHistory => 'Historique';

  @override
  String get exerciseNoHistoryTitle => 'Pas encore fait';

  @override
  String get exerciseNoHistoryMessage =>
      'Ses records et sa courbe apparaîtront après ta première séance.';

  @override
  String get recordMaxReps => 'Reps max';

  @override
  String get greetingMorning => 'Bonjour';

  @override
  String get greetingAfternoon => 'Bon après-midi';

  @override
  String get greetingEvening => 'Bonsoir';

  @override
  String get settingsTitle => 'Réglages';

  @override
  String get statSessionsWeek => 'Séances cette semaine';

  @override
  String get statVolumeWeek => 'Volume de la semaine';

  @override
  String get statStreak => 'Semaines actives d’affilée';

  @override
  String get homeLastRecords => 'Derniers records';

  @override
  String get homeEmptyMessage => 'Ou lance une séance libre tout de suite.';

  @override
  String get homeCreateProgram => 'Créer un programme';

  @override
  String get settingsUnits => 'Unités';

  @override
  String get settingsWeightUnit => 'Unité de poids';

  @override
  String get settingsWeightStep => 'Pas des boutons +/−';

  @override
  String get settingsDefaultRest => 'Repos par défaut';

  @override
  String get settingsProgression => 'Suggestion de progression';

  @override
  String get settingsProgressionHint =>
      'Ajoute du poids quand toutes les séries ont atteint le haut de la fourchette.';

  @override
  String get settingsAppearance => 'Apparence';

  @override
  String get settingsTheme => 'Thème';

  @override
  String get themeSystem => 'Système';

  @override
  String get themeDark => 'Sombre';

  @override
  String get themeLight => 'Clair';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageEnglish => 'English';

  @override
  String get settingsWorkout => 'Séance';

  @override
  String get settingsKeepScreenOn => 'Garder l’écran allumé';

  @override
  String get settingsRestSound => 'Son de fin de repos';

  @override
  String get settingsRestVibration => 'Vibration de fin de repos';

  @override
  String get settingsSync => 'Synchronisation';

  @override
  String get settingsData => 'Données';

  @override
  String get exportJson => 'Exporter en JSON';

  @override
  String get exportJsonHint =>
      'Une copie de toutes tes données, à garder où tu veux.';

  @override
  String get importJson => 'Importer un JSON';

  @override
  String get importJsonHint =>
      'Fusionne une exportation : la version la plus récente de chaque élément gagne.';

  @override
  String get exportShareTitle => 'Exporter les données Endelea';

  @override
  String get exportDone => 'Exportation prête.';

  @override
  String importDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count éléments importés.',
      one: '1 élément importé.',
      zero: 'Rien de nouveau à importer.',
    );
    return '$_temp0';
  }

  @override
  String get importInvalid => 'Ce fichier n’est pas une exportation Endelea.';

  @override
  String get transferFailed => 'Échec. Réessaie.';

  @override
  String get settingsAbout => 'À propos';

  @override
  String aboutVersion(String version) {
    return 'Version $version';
  }

  @override
  String get licenses => 'Licences';

  @override
  String get privacyPolicy => 'Politique de confidentialité';

  @override
  String get privacyBody =>
      'Endelea enregistre tes données uniquement sur ton téléphone. Il n’y a ni compte, ni serveur, ni publicité, ni suivi.\n\nSi tu actives la synchronisation, tes données sont copiées dans un dossier caché de ton propre Google Drive (« appDataFolder »), auquel seule l’application a accès. Endelea ne demande aucun autre accès à ton Drive et tu peux te déconnecter à tout moment.\n\nL’exportation JSON crée un fichier que tu partages toi-même.\n\nPour supprimer tes données : désinstalle l’application ; pour la copie Drive, retire l’accès d’Endelea dans les réglages de ton compte Google.';

  @override
  String get appTagline => 'Continue, avance sans abandonner.';

  @override
  String get googleDrive => 'Google Drive';

  @override
  String get syncConnect => 'Connecter Google Drive';

  @override
  String get syncConnectHint =>
      'Tes séances se synchronisent entre tes appareils, dans un dossier caché de ton Drive.';

  @override
  String get syncNow => 'Synchroniser maintenant';

  @override
  String get syncDisconnect => 'Se déconnecter';

  @override
  String get syncDisconnectMessage =>
      'Les données restent sur ce téléphone et dans ton Drive. La synchronisation s’arrête.';

  @override
  String syncLastSync(String date) {
    return 'Dernière synchro : $date';
  }

  @override
  String get syncNever => 'Jamais synchronisé';

  @override
  String get syncSignInFailed =>
      'Connexion impossible. Vérifie ta connexion et réessaie.';

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
