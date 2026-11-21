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

  /// No description provided for @programsEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Crée ton premier programme'**
  String get programsEmptyTitle;

  /// No description provided for @programsEmptyMessage.
  ///
  /// In fr, this message translates to:
  /// **'Un programme regroupe tes jours d’entraînement et leurs exercices.'**
  String get programsEmptyMessage;

  /// No description provided for @programNew.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau programme'**
  String get programNew;

  /// No description provided for @programName.
  ///
  /// In fr, this message translates to:
  /// **'Nom du programme'**
  String get programName;

  /// No description provided for @programDescription.
  ///
  /// In fr, this message translates to:
  /// **'Description'**
  String get programDescription;

  /// No description provided for @programRename.
  ///
  /// In fr, this message translates to:
  /// **'Renommer'**
  String get programRename;

  /// No description provided for @programDuplicate.
  ///
  /// In fr, this message translates to:
  /// **'Dupliquer'**
  String get programDuplicate;

  /// No description provided for @programActivate.
  ///
  /// In fr, this message translates to:
  /// **'Activer'**
  String get programActivate;

  /// No description provided for @programDelete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le programme'**
  String get programDelete;

  /// No description provided for @programDeleteMessage.
  ///
  /// In fr, this message translates to:
  /// **'« {name} » et ses jours seront supprimés. L’historique des séances est conservé.'**
  String programDeleteMessage(String name);

  /// No description provided for @programCopyName.
  ///
  /// In fr, this message translates to:
  /// **'{name} (copie)'**
  String programCopyName(String name);

  /// No description provided for @programMenu.
  ///
  /// In fr, this message translates to:
  /// **'Options du programme'**
  String get programMenu;

  /// No description provided for @programEdit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le programme'**
  String get programEdit;

  /// No description provided for @programDaysTitle.
  ///
  /// In fr, this message translates to:
  /// **'Jours'**
  String get programDaysTitle;

  /// No description provided for @dayAdd.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un jour'**
  String get dayAdd;

  /// No description provided for @dayName.
  ///
  /// In fr, this message translates to:
  /// **'Nom du jour'**
  String get dayName;

  /// No description provided for @dayDefaultName.
  ///
  /// In fr, this message translates to:
  /// **'Jour {letter}'**
  String dayDefaultName(String letter);

  /// No description provided for @dayRename.
  ///
  /// In fr, this message translates to:
  /// **'Renommer le jour'**
  String get dayRename;

  /// No description provided for @dayDelete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le jour'**
  String get dayDelete;

  /// No description provided for @dayDeleteMessage.
  ///
  /// In fr, this message translates to:
  /// **'« {name} » et ses exercices seront supprimés.'**
  String dayDeleteMessage(String name);

  /// No description provided for @dayExercises.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun exercice} =1{1 exercice} other{{count} exercices}}'**
  String dayExercises(int count);

  /// No description provided for @daysEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ajoute un premier jour'**
  String get daysEmptyTitle;

  /// No description provided for @daysEmptyMessage.
  ///
  /// In fr, this message translates to:
  /// **'Par exemple « Push », « Pull » et « Legs ».'**
  String get daysEmptyMessage;

  /// No description provided for @dayEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucun exercice'**
  String get dayEmptyTitle;

  /// No description provided for @dayEmptyMessage.
  ///
  /// In fr, this message translates to:
  /// **'Ajoute les exercices de ce jour.'**
  String get dayEmptyMessage;

  /// No description provided for @reorder.
  ///
  /// In fr, this message translates to:
  /// **'Réordonner'**
  String get reorder;

  /// No description provided for @exerciseAdd.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un exercice'**
  String get exerciseAdd;

  /// No description provided for @exerciseAddCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Ajouter} other{Ajouter ({count})}}'**
  String exerciseAddCount(int count);

  /// No description provided for @targetsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Cibles'**
  String get targetsTitle;

  /// No description provided for @targetSets.
  ///
  /// In fr, this message translates to:
  /// **'Séries'**
  String get targetSets;

  /// No description provided for @targetRepsMin.
  ///
  /// In fr, this message translates to:
  /// **'Reps min'**
  String get targetRepsMin;

  /// No description provided for @targetRepsMax.
  ///
  /// In fr, this message translates to:
  /// **'Reps max'**
  String get targetRepsMax;

  /// No description provided for @targetNoWeight.
  ///
  /// In fr, this message translates to:
  /// **'Sans charge'**
  String get targetNoWeight;

  /// No description provided for @notes.
  ///
  /// In fr, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @setsTimesReps.
  ///
  /// In fr, this message translates to:
  /// **'{sets} × {reps}'**
  String setsTimesReps(int sets, String reps);

  /// No description provided for @restShort.
  ///
  /// In fr, this message translates to:
  /// **'repos {time}'**
  String restShort(String time);

  /// No description provided for @removeFromDay.
  ///
  /// In fr, this message translates to:
  /// **'Retirer du jour'**
  String get removeFromDay;

  /// No description provided for @exercisesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Exercices'**
  String get exercisesTitle;

  /// No description provided for @exerciseSearch.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un exercice'**
  String get exerciseSearch;

  /// No description provided for @exerciseCreate.
  ///
  /// In fr, this message translates to:
  /// **'Créer un exercice'**
  String get exerciseCreate;

  /// No description provided for @exerciseEdit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier l’exercice'**
  String get exerciseEdit;

  /// No description provided for @exerciseNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom de l’exercice'**
  String get exerciseNameLabel;

  /// No description provided for @exerciseMuscleGroup.
  ///
  /// In fr, this message translates to:
  /// **'Groupe musculaire'**
  String get exerciseMuscleGroup;

  /// No description provided for @exerciseEquipment.
  ///
  /// In fr, this message translates to:
  /// **'Équipement'**
  String get exerciseEquipment;

  /// No description provided for @exerciseTracking.
  ///
  /// In fr, this message translates to:
  /// **'Type de suivi'**
  String get exerciseTracking;

  /// No description provided for @exercisesNoResultTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucun exercice trouvé'**
  String get exercisesNoResultTitle;

  /// No description provided for @exercisesNoResultMessage.
  ///
  /// In fr, this message translates to:
  /// **'Essaie un autre mot, ou crée cet exercice.'**
  String get exercisesNoResultMessage;

  /// No description provided for @exerciseDelete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer l’exercice'**
  String get exerciseDelete;

  /// No description provided for @exerciseDeleteMessage.
  ///
  /// In fr, this message translates to:
  /// **'« {name} » disparaîtra de la bibliothèque. Les séances passées sont conservées.'**
  String exerciseDeleteMessage(String name);

  /// No description provided for @clearFilters.
  ///
  /// In fr, this message translates to:
  /// **'Effacer les filtres'**
  String get clearFilters;

  /// No description provided for @nameRequired.
  ///
  /// In fr, this message translates to:
  /// **'Saisis un nom'**
  String get nameRequired;

  /// No description provided for @create.
  ///
  /// In fr, this message translates to:
  /// **'Créer'**
  String get create;

  /// No description provided for @edit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get edit;

  /// No description provided for @more.
  ///
  /// In fr, this message translates to:
  /// **'Plus d’options'**
  String get more;

  /// No description provided for @errorGeneric.
  ///
  /// In fr, this message translates to:
  /// **'Une erreur est survenue.'**
  String get errorGeneric;

  /// No description provided for @notFound.
  ///
  /// In fr, this message translates to:
  /// **'Introuvable'**
  String get notFound;

  /// No description provided for @sessionFree.
  ///
  /// In fr, this message translates to:
  /// **'Séance libre'**
  String get sessionFree;

  /// No description provided for @sessionNextTitle.
  ///
  /// In fr, this message translates to:
  /// **'Prochaine séance'**
  String get sessionNextTitle;

  /// No description provided for @sessionChooseDay.
  ///
  /// In fr, this message translates to:
  /// **'Ou choisis un jour'**
  String get sessionChooseDay;

  /// No description provided for @sessionNoProgramTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucun programme actif'**
  String get sessionNoProgramTitle;

  /// No description provided for @sessionNoProgramMessage.
  ///
  /// In fr, this message translates to:
  /// **'Crée un programme, ou lance une séance libre.'**
  String get sessionNoProgramMessage;

  /// No description provided for @sessionStartFree.
  ///
  /// In fr, this message translates to:
  /// **'Démarrer une séance libre'**
  String get sessionStartFree;

  /// No description provided for @sessionStartDay.
  ///
  /// In fr, this message translates to:
  /// **'Démarrer {day}'**
  String sessionStartDay(String day);

  /// No description provided for @sessionExerciseOf.
  ///
  /// In fr, this message translates to:
  /// **'Exercice {index} sur {count}'**
  String sessionExerciseOf(int index, int count);

  /// No description provided for @sessionTarget.
  ///
  /// In fr, this message translates to:
  /// **'cible {target}'**
  String sessionTarget(String target);

  /// No description provided for @setValidate.
  ///
  /// In fr, this message translates to:
  /// **'Valider la série'**
  String get setValidate;

  /// No description provided for @restSkipAction.
  ///
  /// In fr, this message translates to:
  /// **'Passer le repos'**
  String get restSkipAction;

  /// No description provided for @nextExercise.
  ///
  /// In fr, this message translates to:
  /// **'Exercice suivant'**
  String get nextExercise;

  /// No description provided for @previousExercise.
  ///
  /// In fr, this message translates to:
  /// **'Exercice précédent'**
  String get previousExercise;

  /// No description provided for @finishSession.
  ///
  /// In fr, this message translates to:
  /// **'Terminer la séance'**
  String get finishSession;

  /// No description provided for @addSet.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une série'**
  String get addSet;

  /// No description provided for @removeSet.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer la série'**
  String get removeSet;

  /// No description provided for @markWarmup.
  ///
  /// In fr, this message translates to:
  /// **'Échauffement'**
  String get markWarmup;

  /// No description provided for @sessionPause.
  ///
  /// In fr, this message translates to:
  /// **'Mettre en pause'**
  String get sessionPause;

  /// No description provided for @sessionResume.
  ///
  /// In fr, this message translates to:
  /// **'Reprendre'**
  String get sessionResume;

  /// No description provided for @sessionPaused.
  ///
  /// In fr, this message translates to:
  /// **'En pause'**
  String get sessionPaused;

  /// No description provided for @sessionDiscard.
  ///
  /// In fr, this message translates to:
  /// **'Abandonner la séance'**
  String get sessionDiscard;

  /// No description provided for @sessionDiscardMessage.
  ///
  /// In fr, this message translates to:
  /// **'La séance et ses séries seront supprimées.'**
  String get sessionDiscardMessage;

  /// No description provided for @sessionDiscardConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Abandonner'**
  String get sessionDiscardConfirm;

  /// No description provided for @sessionFinishMessage.
  ///
  /// In fr, this message translates to:
  /// **'Les séries non validées ne seront pas enregistrées.'**
  String get sessionFinishMessage;

  /// No description provided for @sessionMinimize.
  ///
  /// In fr, this message translates to:
  /// **'Réduire'**
  String get sessionMinimize;

  /// No description provided for @sessionMenu.
  ///
  /// In fr, this message translates to:
  /// **'Options de la séance'**
  String get sessionMenu;

  /// No description provided for @sessionExercises.
  ///
  /// In fr, this message translates to:
  /// **'Exercices de la séance'**
  String get sessionExercises;

  /// No description provided for @sessionEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Séance vide'**
  String get sessionEmptyTitle;

  /// No description provided for @sessionEmptyMessage.
  ///
  /// In fr, this message translates to:
  /// **'Ajoute un exercice pour commencer.'**
  String get sessionEmptyMessage;

  /// No description provided for @exerciseNotes.
  ///
  /// In fr, this message translates to:
  /// **'Notes de l’exercice'**
  String get exerciseNotes;

  /// No description provided for @resumeSession.
  ///
  /// In fr, this message translates to:
  /// **'Reprendre la séance'**
  String get resumeSession;

  /// No description provided for @sessionInProgress.
  ///
  /// In fr, this message translates to:
  /// **'Séance en cours'**
  String get sessionInProgress;

  /// No description provided for @nextSetLabel.
  ///
  /// In fr, this message translates to:
  /// **'Série {index} · {exercise}'**
  String nextSetLabel(int index, String exercise);

  /// No description provided for @exerciseDone.
  ///
  /// In fr, this message translates to:
  /// **'Exercice terminé'**
  String get exerciseDone;

  /// No description provided for @sessionComplete.
  ///
  /// In fr, this message translates to:
  /// **'Toutes les séries sont faites.'**
  String get sessionComplete;

  /// No description provided for @restOverTitle.
  ///
  /// In fr, this message translates to:
  /// **'Repos terminé'**
  String get restOverTitle;

  /// No description provided for @restOverBody.
  ///
  /// In fr, this message translates to:
  /// **'C’est reparti pour la série suivante.'**
  String get restOverBody;

  /// No description provided for @restChannelName.
  ///
  /// In fr, this message translates to:
  /// **'Fin du repos'**
  String get restChannelName;

  /// No description provided for @restChannelDescription.
  ///
  /// In fr, this message translates to:
  /// **'Sonne à la fin de chaque repos.'**
  String get restChannelDescription;

  /// No description provided for @summaryTitle.
  ///
  /// In fr, this message translates to:
  /// **'Résumé de la séance'**
  String get summaryTitle;

  /// No description provided for @summaryDuration.
  ///
  /// In fr, this message translates to:
  /// **'Durée'**
  String get summaryDuration;

  /// No description provided for @summaryVolume.
  ///
  /// In fr, this message translates to:
  /// **'Volume'**
  String get summaryVolume;

  /// No description provided for @summarySets.
  ///
  /// In fr, this message translates to:
  /// **'Séries'**
  String get summarySets;

  /// No description provided for @summaryRecords.
  ///
  /// In fr, this message translates to:
  /// **'Records battus'**
  String get summaryRecords;

  /// No description provided for @summaryNoRecords.
  ///
  /// In fr, this message translates to:
  /// **'Pas de record cette fois. Continue.'**
  String get summaryNoRecords;

  /// No description provided for @summaryVsPrevious.
  ///
  /// In fr, this message translates to:
  /// **'Par rapport à la dernière fois'**
  String get summaryVsPrevious;

  /// No description provided for @summaryVolumeDelta.
  ///
  /// In fr, this message translates to:
  /// **'{delta} de volume'**
  String summaryVolumeDelta(String delta);

  /// No description provided for @summaryDurationDelta.
  ///
  /// In fr, this message translates to:
  /// **'{delta} de durée'**
  String summaryDurationDelta(String delta);

  /// No description provided for @summaryFirstTime.
  ///
  /// In fr, this message translates to:
  /// **'Première fois pour cette séance.'**
  String get summaryFirstTime;

  /// No description provided for @summaryNote.
  ///
  /// In fr, this message translates to:
  /// **'Note sur la séance'**
  String get summaryNote;

  /// No description provided for @summaryDone.
  ///
  /// In fr, this message translates to:
  /// **'Terminer'**
  String get summaryDone;

  /// No description provided for @recordMaxWeight.
  ///
  /// In fr, this message translates to:
  /// **'Charge max'**
  String get recordMaxWeight;

  /// No description provided for @recordOneRepMax.
  ///
  /// In fr, this message translates to:
  /// **'1RM estimé'**
  String get recordOneRepMax;

  /// No description provided for @recordRepsAtWeight.
  ///
  /// In fr, this message translates to:
  /// **'Reps à cette charge'**
  String get recordRepsAtWeight;

  /// No description provided for @recordSessionVolume.
  ///
  /// In fr, this message translates to:
  /// **'Volume de la séance'**
  String get recordSessionVolume;

  /// No description provided for @durationMinutes.
  ///
  /// In fr, this message translates to:
  /// **'{minutes} min'**
  String durationMinutes(int minutes);

  /// No description provided for @durationHoursMinutes.
  ///
  /// In fr, this message translates to:
  /// **'{hours} h {minutes} min'**
  String durationHoursMinutes(int hours, int minutes);

  /// No description provided for @historyEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucune séance pour l’instant'**
  String get historyEmptyTitle;

  /// No description provided for @historyEmptyMessage.
  ///
  /// In fr, this message translates to:
  /// **'Tes séances terminées apparaîtront ici.'**
  String get historyEmptyMessage;

  /// No description provided for @historyThisWeek.
  ///
  /// In fr, this message translates to:
  /// **'Cette semaine'**
  String get historyThisWeek;

  /// No description provided for @historyWeekOf.
  ///
  /// In fr, this message translates to:
  /// **'Semaine du {date}'**
  String historyWeekOf(String date);

  /// No description provided for @recordsCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun record} =1{1 record} other{{count} records}}'**
  String recordsCount(int count);

  /// No description provided for @setsCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 série} other{{count} séries}}'**
  String setsCount(int count);

  /// No description provided for @sessionsCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucune séance} =1{1 séance} other{{count} séances}}'**
  String sessionsCount(int count);

  /// No description provided for @sessionDelete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer la séance'**
  String get sessionDelete;

  /// No description provided for @sessionDeleteMessage.
  ///
  /// In fr, this message translates to:
  /// **'Cette séance sera supprimée de l’historique.'**
  String get sessionDeleteMessage;

  /// No description provided for @editSet.
  ///
  /// In fr, this message translates to:
  /// **'Modifier la série'**
  String get editSet;

  /// No description provided for @periodWeeks4.
  ///
  /// In fr, this message translates to:
  /// **'4 sem.'**
  String get periodWeeks4;

  /// No description provided for @periodMonths3.
  ///
  /// In fr, this message translates to:
  /// **'3 mois'**
  String get periodMonths3;

  /// No description provided for @periodYear.
  ///
  /// In fr, this message translates to:
  /// **'1 an'**
  String get periodYear;

  /// No description provided for @periodAll.
  ///
  /// In fr, this message translates to:
  /// **'Tout'**
  String get periodAll;

  /// No description provided for @statSessions.
  ///
  /// In fr, this message translates to:
  /// **'Séances'**
  String get statSessions;

  /// No description provided for @statTotalVolume.
  ///
  /// In fr, this message translates to:
  /// **'Volume total'**
  String get statTotalVolume;

  /// No description provided for @statRecords.
  ///
  /// In fr, this message translates to:
  /// **'Records'**
  String get statRecords;

  /// No description provided for @weeklyVolumeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Volume par semaine'**
  String get weeklyVolumeTitle;

  /// No description provided for @topExercisesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Exercices les plus faits'**
  String get topExercisesTitle;

  /// No description provided for @progressEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore de progrès'**
  String get progressEmptyTitle;

  /// No description provided for @progressEmptyMessage.
  ///
  /// In fr, this message translates to:
  /// **'Termine une séance pour voir tes courbes.'**
  String get progressEmptyMessage;

  /// No description provided for @bodyWeightTitle.
  ///
  /// In fr, this message translates to:
  /// **'Poids corporel'**
  String get bodyWeightTitle;

  /// No description provided for @bodyWeightLatest.
  ///
  /// In fr, this message translates to:
  /// **'Dernière mesure : {weight}'**
  String bodyWeightLatest(String weight);

  /// No description provided for @bodyEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucune mesure'**
  String get bodyEmptyTitle;

  /// No description provided for @bodyEmptyMessage.
  ///
  /// In fr, this message translates to:
  /// **'Ajoute ta première pesée pour suivre ta courbe.'**
  String get bodyEmptyMessage;

  /// No description provided for @bodyAdd.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une mesure'**
  String get bodyAdd;

  /// No description provided for @bodyFat.
  ///
  /// In fr, this message translates to:
  /// **'Masse grasse'**
  String get bodyFat;

  /// No description provided for @bodyFatShort.
  ///
  /// In fr, this message translates to:
  /// **'{value} % de gras'**
  String bodyFatShort(String value);

  /// No description provided for @bodyMeasurementDelete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer la mesure'**
  String get bodyMeasurementDelete;

  /// No description provided for @chartMaxWeight.
  ///
  /// In fr, this message translates to:
  /// **'Charge max'**
  String get chartMaxWeight;

  /// No description provided for @chartOneRepMax.
  ///
  /// In fr, this message translates to:
  /// **'1RM estimé'**
  String get chartOneRepMax;

  /// No description provided for @chartVolume.
  ///
  /// In fr, this message translates to:
  /// **'Volume'**
  String get chartVolume;

  /// No description provided for @chartReps.
  ///
  /// In fr, this message translates to:
  /// **'Reps max'**
  String get chartReps;

  /// No description provided for @exerciseRecords.
  ///
  /// In fr, this message translates to:
  /// **'Records'**
  String get exerciseRecords;

  /// No description provided for @exerciseHistory.
  ///
  /// In fr, this message translates to:
  /// **'Historique'**
  String get exerciseHistory;

  /// No description provided for @exerciseNoHistoryTitle.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore fait'**
  String get exerciseNoHistoryTitle;

  /// No description provided for @exerciseNoHistoryMessage.
  ///
  /// In fr, this message translates to:
  /// **'Ses records et sa courbe apparaîtront après ta première séance.'**
  String get exerciseNoHistoryMessage;

  /// No description provided for @recordMaxReps.
  ///
  /// In fr, this message translates to:
  /// **'Reps max'**
  String get recordMaxReps;

  /// No description provided for @greetingMorning.
  ///
  /// In fr, this message translates to:
  /// **'Bonjour'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In fr, this message translates to:
  /// **'Bon après-midi'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In fr, this message translates to:
  /// **'Bonsoir'**
  String get greetingEvening;

  /// No description provided for @settingsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Réglages'**
  String get settingsTitle;

  /// No description provided for @statSessionsWeek.
  ///
  /// In fr, this message translates to:
  /// **'Séances cette semaine'**
  String get statSessionsWeek;

  /// No description provided for @statVolumeWeek.
  ///
  /// In fr, this message translates to:
  /// **'Volume de la semaine'**
  String get statVolumeWeek;

  /// No description provided for @statStreak.
  ///
  /// In fr, this message translates to:
  /// **'Semaines actives d’affilée'**
  String get statStreak;

  /// No description provided for @homeLastRecords.
  ///
  /// In fr, this message translates to:
  /// **'Derniers records'**
  String get homeLastRecords;

  /// No description provided for @homeEmptyMessage.
  ///
  /// In fr, this message translates to:
  /// **'Ou lance une séance libre tout de suite.'**
  String get homeEmptyMessage;

  /// No description provided for @homeCreateProgram.
  ///
  /// In fr, this message translates to:
  /// **'Créer un programme'**
  String get homeCreateProgram;

  /// No description provided for @settingsUnits.
  ///
  /// In fr, this message translates to:
  /// **'Unités'**
  String get settingsUnits;

  /// No description provided for @settingsWeightUnit.
  ///
  /// In fr, this message translates to:
  /// **'Unité de poids'**
  String get settingsWeightUnit;

  /// No description provided for @settingsWeightStep.
  ///
  /// In fr, this message translates to:
  /// **'Pas des boutons +/−'**
  String get settingsWeightStep;

  /// No description provided for @settingsDefaultRest.
  ///
  /// In fr, this message translates to:
  /// **'Repos par défaut'**
  String get settingsDefaultRest;

  /// No description provided for @settingsProgression.
  ///
  /// In fr, this message translates to:
  /// **'Suggestion de progression'**
  String get settingsProgression;

  /// No description provided for @settingsProgressionHint.
  ///
  /// In fr, this message translates to:
  /// **'Ajoute du poids quand toutes les séries ont atteint le haut de la fourchette.'**
  String get settingsProgressionHint;

  /// No description provided for @settingsAppearance.
  ///
  /// In fr, this message translates to:
  /// **'Apparence'**
  String get settingsAppearance;

  /// No description provided for @settingsTheme.
  ///
  /// In fr, this message translates to:
  /// **'Thème'**
  String get settingsTheme;

  /// No description provided for @themeSystem.
  ///
  /// In fr, this message translates to:
  /// **'Système'**
  String get themeSystem;

  /// No description provided for @themeDark.
  ///
  /// In fr, this message translates to:
  /// **'Sombre'**
  String get themeDark;

  /// No description provided for @themeLight.
  ///
  /// In fr, this message translates to:
  /// **'Clair'**
  String get themeLight;

  /// No description provided for @settingsLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get settingsLanguage;

  /// No description provided for @languageFrench.
  ///
  /// In fr, this message translates to:
  /// **'Français'**
  String get languageFrench;

  /// No description provided for @languageEnglish.
  ///
  /// In fr, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @settingsWorkout.
  ///
  /// In fr, this message translates to:
  /// **'Séance'**
  String get settingsWorkout;

  /// No description provided for @settingsKeepScreenOn.
  ///
  /// In fr, this message translates to:
  /// **'Garder l’écran allumé'**
  String get settingsKeepScreenOn;

  /// No description provided for @settingsRestSound.
  ///
  /// In fr, this message translates to:
  /// **'Son de fin de repos'**
  String get settingsRestSound;

  /// No description provided for @settingsRestVibration.
  ///
  /// In fr, this message translates to:
  /// **'Vibration de fin de repos'**
  String get settingsRestVibration;

  /// No description provided for @settingsSync.
  ///
  /// In fr, this message translates to:
  /// **'Synchronisation'**
  String get settingsSync;

  /// No description provided for @settingsData.
  ///
  /// In fr, this message translates to:
  /// **'Données'**
  String get settingsData;

  /// No description provided for @exportJson.
  ///
  /// In fr, this message translates to:
  /// **'Exporter en JSON'**
  String get exportJson;

  /// No description provided for @exportJsonHint.
  ///
  /// In fr, this message translates to:
  /// **'Une copie de toutes tes données, à garder où tu veux.'**
  String get exportJsonHint;

  /// No description provided for @importJson.
  ///
  /// In fr, this message translates to:
  /// **'Importer un JSON'**
  String get importJson;

  /// No description provided for @importJsonHint.
  ///
  /// In fr, this message translates to:
  /// **'Fusionne une exportation : la version la plus récente de chaque élément gagne.'**
  String get importJsonHint;

  /// No description provided for @exportShareTitle.
  ///
  /// In fr, this message translates to:
  /// **'Exporter les données Endelea'**
  String get exportShareTitle;

  /// No description provided for @exportDone.
  ///
  /// In fr, this message translates to:
  /// **'Exportation prête.'**
  String get exportDone;

  /// No description provided for @importDone.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Rien de nouveau à importer.} =1{1 élément importé.} other{{count} éléments importés.}}'**
  String importDone(int count);

  /// No description provided for @importInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Ce fichier n’est pas une exportation Endelea.'**
  String get importInvalid;

  /// No description provided for @transferFailed.
  ///
  /// In fr, this message translates to:
  /// **'Échec. Réessaie.'**
  String get transferFailed;

  /// No description provided for @settingsAbout.
  ///
  /// In fr, this message translates to:
  /// **'À propos'**
  String get settingsAbout;

  /// No description provided for @aboutVersion.
  ///
  /// In fr, this message translates to:
  /// **'Version {version}'**
  String aboutVersion(String version);

  /// No description provided for @licenses.
  ///
  /// In fr, this message translates to:
  /// **'Licences'**
  String get licenses;

  /// No description provided for @privacyPolicy.
  ///
  /// In fr, this message translates to:
  /// **'Politique de confidentialité'**
  String get privacyPolicy;

  /// No description provided for @privacyBody.
  ///
  /// In fr, this message translates to:
  /// **'Endelea enregistre tes données uniquement sur ton téléphone. Il n’y a ni compte, ni serveur, ni publicité, ni suivi.\n\nSi tu actives la synchronisation, tes données sont copiées dans un dossier caché de ton propre Google Drive (« appDataFolder »), auquel seule l’application a accès. Endelea ne demande aucun autre accès à ton Drive et tu peux te déconnecter à tout moment.\n\nL’exportation JSON crée un fichier que tu partages toi-même.\n\nPour supprimer tes données : désinstalle l’application ; pour la copie Drive, retire l’accès d’Endelea dans les réglages de ton compte Google.'**
  String get privacyBody;

  /// No description provided for @appTagline.
  ///
  /// In fr, this message translates to:
  /// **'Continue, avance sans abandonner.'**
  String get appTagline;

  /// No description provided for @secondsShort.
  ///
  /// In fr, this message translates to:
  /// **'{seconds} s'**
  String secondsShort(int seconds);

  /// No description provided for @googleDrive.
  ///
  /// In fr, this message translates to:
  /// **'Google Drive'**
  String get googleDrive;

  /// No description provided for @syncConnect.
  ///
  /// In fr, this message translates to:
  /// **'Connecter Google Drive'**
  String get syncConnect;

  /// No description provided for @syncConnectHint.
  ///
  /// In fr, this message translates to:
  /// **'Tes séances se synchronisent entre tes appareils, dans un dossier caché de ton Drive.'**
  String get syncConnectHint;

  /// No description provided for @syncNow.
  ///
  /// In fr, this message translates to:
  /// **'Synchroniser maintenant'**
  String get syncNow;

  /// No description provided for @syncDisconnect.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get syncDisconnect;

  /// No description provided for @syncDisconnectMessage.
  ///
  /// In fr, this message translates to:
  /// **'Les données restent sur ce téléphone et dans ton Drive. La synchronisation s’arrête.'**
  String get syncDisconnectMessage;

  /// No description provided for @syncLastSync.
  ///
  /// In fr, this message translates to:
  /// **'Dernière synchro : {date}'**
  String syncLastSync(String date);

  /// No description provided for @syncNever.
  ///
  /// In fr, this message translates to:
  /// **'Jamais synchronisé'**
  String get syncNever;

  /// No description provided for @syncSignInFailed.
  ///
  /// In fr, this message translates to:
  /// **'Connexion impossible. Vérifie ta connexion et réessaie.'**
  String get syncSignInFailed;

  /// No description provided for @syncAccount.
  ///
  /// In fr, this message translates to:
  /// **'Compte'**
  String get syncAccount;

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
