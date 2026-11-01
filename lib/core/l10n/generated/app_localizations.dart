import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In fr, this message translates to:
  /// **'Endelea'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get navHome;

  /// No description provided for @navPrograms.
  ///
  /// In fr, this message translates to:
  /// **'Programmes'**
  String get navPrograms;

  /// No description provided for @navSession.
  ///
  /// In fr, this message translates to:
  /// **'Séance'**
  String get navSession;

  /// No description provided for @navHistory.
  ///
  /// In fr, this message translates to:
  /// **'Historique'**
  String get navHistory;

  /// No description provided for @navProgress.
  ///
  /// In fr, this message translates to:
  /// **'Progrès'**
  String get navProgress;

  /// No description provided for @comingSoon.
  ///
  /// In fr, this message translates to:
  /// **'Bientôt ici'**
  String get comingSoon;

  /// No description provided for @cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer'**
  String get confirm;

  /// No description provided for @delete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get delete;

  /// No description provided for @save.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get save;

  /// No description provided for @ok.
  ///
  /// In fr, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @setColumnSet.
  ///
  /// In fr, this message translates to:
  /// **'Série'**
  String get setColumnSet;

  /// No description provided for @setColumnPrevious.
  ///
  /// In fr, this message translates to:
  /// **'Précédent'**
  String get setColumnPrevious;

  /// No description provided for @setColumnReps.
  ///
  /// In fr, this message translates to:
  /// **'Reps'**
  String get setColumnReps;

  /// No description provided for @setColumnTime.
  ///
  /// In fr, this message translates to:
  /// **'Durée'**
  String get setColumnTime;

  /// No description provided for @setColumnDistance.
  ///
  /// In fr, this message translates to:
  /// **'km'**
  String get setColumnDistance;

  /// No description provided for @unitKg.
  ///
  /// In fr, this message translates to:
  /// **'kg'**
  String get unitKg;

  /// No description provided for @unitLb.
  ///
  /// In fr, this message translates to:
  /// **'lb'**
  String get unitLb;

  /// No description provided for @warmupShort.
  ///
  /// In fr, this message translates to:
  /// **'É'**
  String get warmupShort;

  /// No description provided for @warmupLabel.
  ///
  /// In fr, this message translates to:
  /// **'Échauffement'**
  String get warmupLabel;

  /// No description provided for @setDone.
  ///
  /// In fr, this message translates to:
  /// **'Validée'**
  String get setDone;

  /// No description provided for @setPending.
  ///
  /// In fr, this message translates to:
  /// **'À faire'**
  String get setPending;

  /// No description provided for @setCurrent.
  ///
  /// In fr, this message translates to:
  /// **'En cours'**
  String get setCurrent;

  /// No description provided for @restTitle.
  ///
  /// In fr, this message translates to:
  /// **'Repos'**
  String get restTitle;

  /// No description provided for @restSkip.
  ///
  /// In fr, this message translates to:
  /// **'Passer'**
  String get restSkip;

  /// No description provided for @restMinus15.
  ///
  /// In fr, this message translates to:
  /// **'−15 s'**
  String get restMinus15;

  /// No description provided for @restPlus15.
  ///
  /// In fr, this message translates to:
  /// **'+15 s'**
  String get restPlus15;

  /// No description provided for @restRemaining.
  ///
  /// In fr, this message translates to:
  /// **'Repos, {time} restant'**
  String restRemaining(String time);

  /// No description provided for @personalRecord.
  ///
  /// In fr, this message translates to:
  /// **'Record'**
  String get personalRecord;

  /// No description provided for @syncUpToDate.
  ///
  /// In fr, this message translates to:
  /// **'À jour'**
  String get syncUpToDate;

  /// No description provided for @syncInProgress.
  ///
  /// In fr, this message translates to:
  /// **'Synchro…'**
  String get syncInProgress;

  /// No description provided for @syncError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur de synchro'**
  String get syncError;

  /// No description provided for @syncDisabled.
  ///
  /// In fr, this message translates to:
  /// **'Synchro désactivée'**
  String get syncDisabled;

  /// No description provided for @weightLabel.
  ///
  /// In fr, this message translates to:
  /// **'Charge'**
  String get weightLabel;

  /// No description provided for @repsLabel.
  ///
  /// In fr, this message translates to:
  /// **'Répétitions'**
  String get repsLabel;

  /// No description provided for @durationLabel.
  ///
  /// In fr, this message translates to:
  /// **'Durée'**
  String get durationLabel;

  /// No description provided for @distanceLabel.
  ///
  /// In fr, this message translates to:
  /// **'Distance'**
  String get distanceLabel;

  /// No description provided for @stepperSemantics.
  ///
  /// In fr, this message translates to:
  /// **'{label}, {value} {unit}'**
  String stepperSemantics(String label, String value, String unit);

  /// No description provided for @stepperIncrease.
  ///
  /// In fr, this message translates to:
  /// **'Augmenter'**
  String get stepperIncrease;

  /// No description provided for @stepperDecrease.
  ///
  /// In fr, this message translates to:
  /// **'Diminuer'**
  String get stepperDecrease;

  /// No description provided for @unitKilos.
  ///
  /// In fr, this message translates to:
  /// **'kilos'**
  String get unitKilos;

  /// No description provided for @unitPounds.
  ///
  /// In fr, this message translates to:
  /// **'livres'**
  String get unitPounds;

  /// No description provided for @unitRepetitions.
  ///
  /// In fr, this message translates to:
  /// **'répétitions'**
  String get unitRepetitions;

  /// No description provided for @unitSeconds.
  ///
  /// In fr, this message translates to:
  /// **'secondes'**
  String get unitSeconds;

  /// No description provided for @unitMinutesShort.
  ///
  /// In fr, this message translates to:
  /// **'min'**
  String get unitMinutesShort;

  /// No description provided for @enterValue.
  ///
  /// In fr, this message translates to:
  /// **'Saisir une valeur'**
  String get enterValue;

  /// No description provided for @programDays.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun jour} =1{1 jour} other{{count} jours}}'**
  String programDays(int count);

  /// No description provided for @programLastSession.
  ///
  /// In fr, this message translates to:
  /// **'Dernière séance : {date}'**
  String programLastSession(String date);

  /// No description provided for @programNeverStarted.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore commencé'**
  String get programNeverStarted;

  /// No description provided for @programActive.
  ///
  /// In fr, this message translates to:
  /// **'Actif'**
  String get programActive;

  /// No description provided for @start.
  ///
  /// In fr, this message translates to:
  /// **'Démarrer'**
  String get start;

  /// No description provided for @muscleChest.
  ///
  /// In fr, this message translates to:
  /// **'Pectoraux'**
  String get muscleChest;

  /// No description provided for @muscleBack.
  ///
  /// In fr, this message translates to:
  /// **'Dos'**
  String get muscleBack;

  /// No description provided for @muscleShoulders.
  ///
  /// In fr, this message translates to:
  /// **'Épaules'**
  String get muscleShoulders;

  /// No description provided for @muscleBiceps.
  ///
  /// In fr, this message translates to:
  /// **'Biceps'**
  String get muscleBiceps;

  /// No description provided for @muscleTriceps.
  ///
  /// In fr, this message translates to:
  /// **'Triceps'**
  String get muscleTriceps;

  /// No description provided for @muscleLegs.
  ///
  /// In fr, this message translates to:
  /// **'Jambes'**
  String get muscleLegs;

  /// No description provided for @muscleGlutes.
  ///
  /// In fr, this message translates to:
  /// **'Fessiers'**
  String get muscleGlutes;

  /// No description provided for @muscleCore.
  ///
  /// In fr, this message translates to:
  /// **'Abdos'**
  String get muscleCore;

  /// No description provided for @muscleCardio.
  ///
  /// In fr, this message translates to:
  /// **'Cardio'**
  String get muscleCardio;

  /// No description provided for @muscleFullBody.
  ///
  /// In fr, this message translates to:
  /// **'Corps entier'**
  String get muscleFullBody;

  /// No description provided for @equipmentBarbell.
  ///
  /// In fr, this message translates to:
  /// **'Barre'**
  String get equipmentBarbell;

  /// No description provided for @equipmentDumbbell.
  ///
  /// In fr, this message translates to:
  /// **'Haltères'**
  String get equipmentDumbbell;

  /// No description provided for @equipmentMachine.
  ///
  /// In fr, this message translates to:
  /// **'Machine'**
  String get equipmentMachine;

  /// No description provided for @equipmentCable.
  ///
  /// In fr, this message translates to:
  /// **'Poulie'**
  String get equipmentCable;

  /// No description provided for @equipmentBodyweight.
  ///
  /// In fr, this message translates to:
  /// **'Poids du corps'**
  String get equipmentBodyweight;

  /// No description provided for @equipmentKettlebell.
  ///
  /// In fr, this message translates to:
  /// **'Kettlebell'**
  String get equipmentKettlebell;

  /// No description provided for @equipmentBand.
  ///
  /// In fr, this message translates to:
  /// **'Élastique'**
  String get equipmentBand;

  /// No description provided for @equipmentOther.
  ///
  /// In fr, this message translates to:
  /// **'Autre'**
  String get equipmentOther;

  /// No description provided for @trackingWeightReps.
  ///
  /// In fr, this message translates to:
  /// **'Charge et reps'**
  String get trackingWeightReps;

  /// No description provided for @trackingRepsOnly.
  ///
  /// In fr, this message translates to:
  /// **'Reps seulement'**
  String get trackingRepsOnly;

  /// No description provided for @trackingDuration.
  ///
  /// In fr, this message translates to:
  /// **'Durée'**
  String get trackingDuration;

  /// No description provided for @trackingDistance.
  ///
  /// In fr, this message translates to:
  /// **'Distance et durée'**
  String get trackingDistance;

  /// No description provided for @exerciseCustom.
  ///
  /// In fr, this message translates to:
  /// **'Personnalisé'**
  String get exerciseCustom;

  /// No description provided for @galleryTitle.
  ///
  /// In fr, this message translates to:
  /// **'Galerie'**
  String get galleryTitle;

  /// No description provided for @galleryToggleTheme.
  ///
  /// In fr, this message translates to:
  /// **'Changer de thème'**
  String get galleryToggleTheme;

  /// No description provided for @emptyGalleryTitle.
  ///
  /// In fr, this message translates to:
  /// **'Rien ici'**
  String get emptyGalleryTitle;

  /// No description provided for @emptyGalleryMessage.
  ///
  /// In fr, this message translates to:
  /// **'Exemple d’état vide.'**
  String get emptyGalleryMessage;

  /// No description provided for @exercise_bench_press.
  ///
  /// In fr, this message translates to:
  /// **'Développé couché'**
  String get exercise_bench_press;

  /// No description provided for @exercise_incline_bench_press.
  ///
  /// In fr, this message translates to:
  /// **'Développé incliné'**
  String get exercise_incline_bench_press;

  /// No description provided for @exercise_decline_bench_press.
  ///
  /// In fr, this message translates to:
  /// **'Développé décliné'**
  String get exercise_decline_bench_press;

  /// No description provided for @exercise_dumbbell_bench_press.
  ///
  /// In fr, this message translates to:
  /// **'Développé couché haltères'**
  String get exercise_dumbbell_bench_press;

  /// No description provided for @exercise_incline_dumbbell_press.
  ///
  /// In fr, this message translates to:
  /// **'Développé incliné haltères'**
  String get exercise_incline_dumbbell_press;

  /// No description provided for @exercise_dumbbell_fly.
  ///
  /// In fr, this message translates to:
  /// **'Écarté haltères'**
  String get exercise_dumbbell_fly;

  /// No description provided for @exercise_cable_crossover.
  ///
  /// In fr, this message translates to:
  /// **'Écarté à la poulie'**
  String get exercise_cable_crossover;

  /// No description provided for @exercise_chest_press_machine.
  ///
  /// In fr, this message translates to:
  /// **'Presse pectorale'**
  String get exercise_chest_press_machine;

  /// No description provided for @exercise_pec_deck.
  ///
  /// In fr, this message translates to:
  /// **'Pec deck'**
  String get exercise_pec_deck;

  /// No description provided for @exercise_push_up.
  ///
  /// In fr, this message translates to:
  /// **'Pompes'**
  String get exercise_push_up;

  /// No description provided for @exercise_chest_dip.
  ///
  /// In fr, this message translates to:
  /// **'Dips pectoraux'**
  String get exercise_chest_dip;

  /// No description provided for @exercise_deadlift.
  ///
  /// In fr, this message translates to:
  /// **'Soulevé de terre'**
  String get exercise_deadlift;

  /// No description provided for @exercise_barbell_row.
  ///
  /// In fr, this message translates to:
  /// **'Rowing barre'**
  String get exercise_barbell_row;

  /// No description provided for @exercise_t_bar_row.
  ///
  /// In fr, this message translates to:
  /// **'Rowing T-bar'**
  String get exercise_t_bar_row;

  /// No description provided for @exercise_dumbbell_row.
  ///
  /// In fr, this message translates to:
  /// **'Rowing haltère un bras'**
  String get exercise_dumbbell_row;

  /// No description provided for @exercise_pull_up.
  ///
  /// In fr, this message translates to:
  /// **'Tractions pronation'**
  String get exercise_pull_up;

  /// No description provided for @exercise_chin_up.
  ///
  /// In fr, this message translates to:
  /// **'Tractions supination'**
  String get exercise_chin_up;

  /// No description provided for @exercise_lat_pulldown.
  ///
  /// In fr, this message translates to:
  /// **'Tirage vertical'**
  String get exercise_lat_pulldown;

  /// No description provided for @exercise_seated_cable_row.
  ///
  /// In fr, this message translates to:
  /// **'Tirage horizontal'**
  String get exercise_seated_cable_row;

  /// No description provided for @exercise_face_pull.
  ///
  /// In fr, this message translates to:
  /// **'Face pull'**
  String get exercise_face_pull;

  /// No description provided for @exercise_back_extension.
  ///
  /// In fr, this message translates to:
  /// **'Extension lombaire'**
  String get exercise_back_extension;

  /// No description provided for @exercise_overhead_press.
  ///
  /// In fr, this message translates to:
  /// **'Développé militaire'**
  String get exercise_overhead_press;

  /// No description provided for @exercise_dumbbell_shoulder_press.
  ///
  /// In fr, this message translates to:
  /// **'Développé épaules haltères'**
  String get exercise_dumbbell_shoulder_press;

  /// No description provided for @exercise_arnold_press.
  ///
  /// In fr, this message translates to:
  /// **'Développé Arnold'**
  String get exercise_arnold_press;

  /// No description provided for @exercise_shoulder_press_machine.
  ///
  /// In fr, this message translates to:
  /// **'Presse épaules'**
  String get exercise_shoulder_press_machine;

  /// No description provided for @exercise_lateral_raise.
  ///
  /// In fr, this message translates to:
  /// **'Élévations latérales'**
  String get exercise_lateral_raise;

  /// No description provided for @exercise_cable_lateral_raise.
  ///
  /// In fr, this message translates to:
  /// **'Élévation latérale à la poulie'**
  String get exercise_cable_lateral_raise;

  /// No description provided for @exercise_front_raise.
  ///
  /// In fr, this message translates to:
  /// **'Élévations frontales'**
  String get exercise_front_raise;

  /// No description provided for @exercise_rear_delt_fly.
  ///
  /// In fr, this message translates to:
  /// **'Oiseau'**
  String get exercise_rear_delt_fly;

  /// No description provided for @exercise_upright_row.
  ///
  /// In fr, this message translates to:
  /// **'Rowing menton'**
  String get exercise_upright_row;

  /// No description provided for @exercise_shrug.
  ///
  /// In fr, this message translates to:
  /// **'Haussements d\'épaules'**
  String get exercise_shrug;

  /// No description provided for @exercise_band_pull_apart.
  ///
  /// In fr, this message translates to:
  /// **'Écarté avec élastique'**
  String get exercise_band_pull_apart;

  /// No description provided for @exercise_barbell_curl.
  ///
  /// In fr, this message translates to:
  /// **'Curl barre'**
  String get exercise_barbell_curl;

  /// No description provided for @exercise_dumbbell_curl.
  ///
  /// In fr, this message translates to:
  /// **'Curl haltères'**
  String get exercise_dumbbell_curl;

  /// No description provided for @exercise_hammer_curl.
  ///
  /// In fr, this message translates to:
  /// **'Curl marteau'**
  String get exercise_hammer_curl;

  /// No description provided for @exercise_incline_dumbbell_curl.
  ///
  /// In fr, this message translates to:
  /// **'Curl incliné haltères'**
  String get exercise_incline_dumbbell_curl;

  /// No description provided for @exercise_preacher_curl.
  ///
  /// In fr, this message translates to:
  /// **'Curl pupitre'**
  String get exercise_preacher_curl;

  /// No description provided for @exercise_cable_curl.
  ///
  /// In fr, this message translates to:
  /// **'Curl à la poulie'**
  String get exercise_cable_curl;

  /// No description provided for @exercise_close_grip_bench_press.
  ///
  /// In fr, this message translates to:
  /// **'Développé couché prise serrée'**
  String get exercise_close_grip_bench_press;

  /// No description provided for @exercise_skull_crusher.
  ///
  /// In fr, this message translates to:
  /// **'Barre au front'**
  String get exercise_skull_crusher;

  /// No description provided for @exercise_triceps_pushdown.
  ///
  /// In fr, this message translates to:
  /// **'Extension triceps à la poulie'**
  String get exercise_triceps_pushdown;

  /// No description provided for @exercise_overhead_triceps_extension.
  ///
  /// In fr, this message translates to:
  /// **'Extension triceps au-dessus de la tête'**
  String get exercise_overhead_triceps_extension;

  /// No description provided for @exercise_triceps_dip.
  ///
  /// In fr, this message translates to:
  /// **'Dips triceps'**
  String get exercise_triceps_dip;

  /// No description provided for @exercise_back_squat.
  ///
  /// In fr, this message translates to:
  /// **'Squat'**
  String get exercise_back_squat;

  /// No description provided for @exercise_front_squat.
  ///
  /// In fr, this message translates to:
  /// **'Squat avant'**
  String get exercise_front_squat;

  /// No description provided for @exercise_hack_squat.
  ///
  /// In fr, this message translates to:
  /// **'Hack squat'**
  String get exercise_hack_squat;

  /// No description provided for @exercise_leg_press.
  ///
  /// In fr, this message translates to:
  /// **'Presse à cuisses'**
  String get exercise_leg_press;

  /// No description provided for @exercise_goblet_squat.
  ///
  /// In fr, this message translates to:
  /// **'Squat gobelet'**
  String get exercise_goblet_squat;

  /// No description provided for @exercise_romanian_deadlift.
  ///
  /// In fr, this message translates to:
  /// **'Soulevé de terre roumain'**
  String get exercise_romanian_deadlift;

  /// No description provided for @exercise_bulgarian_split_squat.
  ///
  /// In fr, this message translates to:
  /// **'Squat bulgare'**
  String get exercise_bulgarian_split_squat;

  /// No description provided for @exercise_walking_lunge.
  ///
  /// In fr, this message translates to:
  /// **'Fentes marchées'**
  String get exercise_walking_lunge;

  /// No description provided for @exercise_leg_extension.
  ///
  /// In fr, this message translates to:
  /// **'Leg extension'**
  String get exercise_leg_extension;

  /// No description provided for @exercise_leg_curl.
  ///
  /// In fr, this message translates to:
  /// **'Leg curl'**
  String get exercise_leg_curl;

  /// No description provided for @exercise_calf_raise.
  ///
  /// In fr, this message translates to:
  /// **'Mollets debout'**
  String get exercise_calf_raise;

  /// No description provided for @exercise_hip_thrust.
  ///
  /// In fr, this message translates to:
  /// **'Hip thrust'**
  String get exercise_hip_thrust;

  /// No description provided for @exercise_glute_bridge.
  ///
  /// In fr, this message translates to:
  /// **'Pont fessier'**
  String get exercise_glute_bridge;

  /// No description provided for @exercise_cable_kickback.
  ///
  /// In fr, this message translates to:
  /// **'Kickback à la poulie'**
  String get exercise_cable_kickback;

  /// No description provided for @exercise_hip_abduction.
  ///
  /// In fr, this message translates to:
  /// **'Abduction de hanche'**
  String get exercise_hip_abduction;

  /// No description provided for @exercise_plank.
  ///
  /// In fr, this message translates to:
  /// **'Gainage'**
  String get exercise_plank;

  /// No description provided for @exercise_side_plank.
  ///
  /// In fr, this message translates to:
  /// **'Gainage latéral'**
  String get exercise_side_plank;

  /// No description provided for @exercise_crunch.
  ///
  /// In fr, this message translates to:
  /// **'Crunch'**
  String get exercise_crunch;

  /// No description provided for @exercise_cable_crunch.
  ///
  /// In fr, this message translates to:
  /// **'Crunch à la poulie'**
  String get exercise_cable_crunch;

  /// No description provided for @exercise_hanging_leg_raise.
  ///
  /// In fr, this message translates to:
  /// **'Relevé de jambes suspendu'**
  String get exercise_hanging_leg_raise;

  /// No description provided for @exercise_russian_twist.
  ///
  /// In fr, this message translates to:
  /// **'Rotation russe'**
  String get exercise_russian_twist;

  /// No description provided for @exercise_ab_wheel_rollout.
  ///
  /// In fr, this message translates to:
  /// **'Roue abdominale'**
  String get exercise_ab_wheel_rollout;

  /// No description provided for @exercise_treadmill_run.
  ///
  /// In fr, this message translates to:
  /// **'Course sur tapis'**
  String get exercise_treadmill_run;

  /// No description provided for @exercise_rowing_machine.
  ///
  /// In fr, this message translates to:
  /// **'Rameur'**
  String get exercise_rowing_machine;

  /// No description provided for @exercise_stationary_bike.
  ///
  /// In fr, this message translates to:
  /// **'Vélo d\'appartement'**
  String get exercise_stationary_bike;

  /// No description provided for @exercise_elliptical.
  ///
  /// In fr, this message translates to:
  /// **'Vélo elliptique'**
  String get exercise_elliptical;

  /// No description provided for @exercise_jump_rope.
  ///
  /// In fr, this message translates to:
  /// **'Corde à sauter'**
  String get exercise_jump_rope;

  /// No description provided for @exercise_kettlebell_swing.
  ///
  /// In fr, this message translates to:
  /// **'Swing kettlebell'**
  String get exercise_kettlebell_swing;

  /// No description provided for @exercise_power_clean.
  ///
  /// In fr, this message translates to:
  /// **'Épaulé'**
  String get exercise_power_clean;

  /// No description provided for @exercise_thruster.
  ///
  /// In fr, this message translates to:
  /// **'Thruster'**
  String get exercise_thruster;

  /// No description provided for @exercise_burpee.
  ///
  /// In fr, this message translates to:
  /// **'Burpee'**
  String get exercise_burpee;

  /// No description provided for @exercise_farmers_walk.
  ///
  /// In fr, this message translates to:
  /// **'Marche du fermier'**
  String get exercise_farmers_walk;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
