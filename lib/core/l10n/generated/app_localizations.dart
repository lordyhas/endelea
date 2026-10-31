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
