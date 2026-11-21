# Endelea — Plan de conception complet

> *Endelea* (swahili) : « continue, avance sans abandonner ».
> App mobile de suivi d'entraînement en salle, inspirée du suivi de séances de Hexfit, **sans volet coach**.

Ce document est la référence pour l'implémentation. Il est destiné à Claude Code : chaque phase (§14) est découpée en tâches avec critères d'acceptation. En cas de doute, ce document fait foi ; s'il est incomplet, poser la question plutôt que d'inventer.

---

## 1. Vision et périmètre

### 1.1 Objectif
Permettre à une personne de :
1. créer ses **programmes** d'entraînement (jours, exercices, cibles) ;
2. faire ses **séances guidées** (auto-play : exercice par exercice, série par série, minuteur de repos automatique) ;
3. consulter ses **progrès** (records, volume, courbes par exercice, poids corporel).

### 1.2 Principes
- **Offline-first** : 100 % fonctionnel sans réseau. La base locale fait foi.
- **Aucune infrastructure serveur** à moi : la synchro passe par le cloud de l'utilisateur (Google Drive d'abord, OneDrive ensuite).
- **Utilisable en salle** : grosses zones tactiles, saisie minimale, lisible d'un coup d'œil, mode sombre par défaut.
- **Bilingue** FR/EN dès le départ (FR par défaut).

### 1.3 Dans le périmètre V1
- Bibliothèque d'exercices (intégrés + personnalisés)
- Programmes → jours → exercices planifiés avec cibles
- Séance guidée depuis un jour de programme, ou séance libre
- Minuteur de repos (survit à la mise en arrière-plan, notification + vibration)
- Historique des séances
- Progrès : records personnels, 1RM estimé, volume, courbes, poids corporel
- Réglages : unités (kg/lb), repos par défaut, thème, langue
- Synchro Google Drive (`appDataFolder`) + Android Auto Backup
- Export/import JSON manuel (filet de sécurité)

### 1.4 Hors périmètre V1
- Coach / client, messagerie, partage social
- Nutrition, recettes
- Montres connectées, Health Connect (piste V2)
- OneDrive, iCloud (V1.1+ via la même interface)
- Version web

---

## 2. Stack technique

| Domaine | Choix | Notes |
|---|---|---|
| Framework | Flutter (stable le plus récent) | Android d'abord, iOS prévu |
| Langage | Dart 3, null-safety | |
| État | `flutter_bloc` + `bloc` | `Cubit` par défaut ; `Bloc` (événements) pour la séance guidée |
| États immuables | `equatable` + `sealed class` | Pas de freezed |
| Navigation | `go_router` | `StatefulShellRoute` pour la barre du bas |
| Base locale | `drift` + `drift_flutter` (SQLite) | Schéma : `lib/data/database.dart` |
| IDs | `uuid` (v4) | |
| Icônes | `phosphor_flutter` | Règles §6.4 |
| Police | `google_fonts` **avec polices embarquées** | `allowRuntimeFetching = false` (offline) |
| Graphiques | `fl_chart` | |
| i18n | `flutter_localizations` + `intl` + `gen-l10n` (ARB) | |
| Notifications | `flutter_local_notifications` | Fin du repos |
| Écran allumé | `wakelock_plus` | Pendant une séance (réglable) |
| Préférences simples | `shared_preferences` | Réglages UI uniquement |
| Auth Google | `google_sign_in` + `extension_google_sign_in_as_googleapis_auth` | |
| API Drive | `googleapis` (`drive/v3`) | Scope `drive.appdata` uniquement |
| Compression | `archive` (gzip) | Fichiers de synchro |
| Lint | `very_good_analysis` (ou `flutter_lints` strict) | |
| Tests | `flutter_test`, `bloc_test`, `mocktail`, base Drift en mémoire | |
| Codegen | `build_runner`, `drift_dev` | |

Utiliser les dernières versions stables compatibles au moment de l'implémentation. Ne pas ajouter de dépendance hors de cette liste sans le signaler.

---

## 3. Architecture

### 3.1 Couches (feature-first)

```
presentation (widgets, écrans)  →  application (Cubits / Blocs, états)
        →  domain (modèles purs, calculs : 1RM, volume, PR)  →  data (Drift, repositories, sync)
```

- Les **widgets** ne parlent jamais à Drift ni aux repositories : uniquement via des Cubits/Blocs (`BlocBuilder`, `BlocListener`, `BlocSelector`, `context.read<…>()`).
- **Cubit par défaut** (méthodes → `emit`). **Bloc** (événements → états) seulement là où la traçabilité compte : la séance guidée (`SessionBloc`) et la synchro (`SyncBloc`).
- États : `sealed class` + `Equatable` (ex. `ProgramsLoading`, `ProgramsLoaded`, `ProgramsError`). Pas d'état mutable.
- Les flux Drift (`watch()`) sont écoutés dans les Cubits via `emit.forEach` (Bloc) ou une `StreamSubscription` annulée dans `close()` (Cubit).
- Les **repositories** sont les seuls à écrire en base. Ils mettent **toujours** à jour `updatedAt` (et `lastModifiedBy`).
- La logique pure (calculs de progrès, machine à états de séance) est en Dart pur, testable sans Flutter.

### 3.2 Arborescence

```
lib/
  main.dart
  app.dart                       # MaterialApp.router, thème, l10n
  core/
    theme/                       # app_colors.dart, app_theme.dart, app_typography.dart, app_spacing.dart
    router/                      # app_router.dart
    l10n/                        # *.arb
    utils/                       # units.dart (kg↔lb), date_utils.dart, clock.dart
    widgets/                     # composants partagés (§7)
  data/
    database.dart                # schéma Drift
    database.g.dart
    seed/                        # exercises_seed.dart
    repositories/                # exercise_repository.dart, program_repository.dart, session_repository.dart, body_repository.dart
  domain/
    models/                      # value objects si besoin
    progress/                    # one_rep_max.dart, volume.dart, personal_records.dart
    session/                     # session_state_machine.dart
  sync/
    cloud_sync_provider.dart     # interface
    google_drive_provider.dart
    sync_engine.dart             # push/pull/merge
    sync_codec.dart              # (dé)sérialisation JSON + gzip
  features/
    home/                        # chaque feature : bloc/ (cubit/bloc + state) et view/ (écrans, widgets)
    programs/                    # liste, éditeur programme, éditeur jour
    exercises/                   # bibliothèque, détail, création
    session/                     # SessionBloc, séance guidée, résumé
    history/
    progress/
    body/
    settings/                    # SettingsCubit (thème, langue, unités…)
test/                            # miroir de lib/
```

### 3.3 Injection de dépendances
- Pas de `get_it` : tout passe par l'arbre de widgets.
- `main.dart` crée `AppDatabase`, `Clock` et les repositories, puis les fournit via `MultiRepositoryProvider` au-dessus de `MaterialApp.router`.
- Les Cubits/Blocs globaux (`SettingsCubit`, `SyncBloc`, `ActiveSessionCubit` pour le mini-lecteur) sont fournis par un `MultiBlocProvider` sous les repositories.
  *Implémentation :* `SessionBloc` est global (et non créé dans la route) : le repos continue de tourner et de vibrer hors de l'écran de séance, et le mini-lecteur lit directement son état ; `ActiveSessionCubit` n'est donc pas nécessaire.
- Les Cubits d'écran sont créés dans la route (`BlocProvider(create: (context) => ProgramsCubit(context.read<ProgramRepository>()))`) et fermés automatiquement.
- `Clock` (abstraction de `DateTime.now()`) est injecté dans les repositories et les Blocs pour des tests déterministes.

---

## 4. Modèle de données

Le schéma de base est dans `lib/data/database.dart` (fourni). Tables :

| Table | Rôle |
|---|---|
| `Exercises` | Catalogue (intégrés + personnalisés) |
| `Programs` | Programme (ex. « Push / Pull / Legs ») |
| `ProgramDays` | Jour d'un programme (ex. « Jour A — Push ») |
| `ProgramExercises` | Exercice planifié + cibles (séries, reps min/max, charge, repos) |
| `WorkoutSessions` | Séance réalisée (`endedAt = null` → en cours) |
| `SessionExercises` | Exercice réalisé dans une séance (lien vers le plan) |
| `SetEntries` | Série : reps, charge, durée, distance, RPE, échauffement |
| `BodyMeasurements` | Poids corporel, % gras |

### 4.1 Ajouts à faire au schéma fourni (phase 1)
1. **Colonne `lastModifiedBy` (text)** dans le mixin `SyncColumns` : `deviceId` de l'appareil qui a écrit en dernier (départage des conflits).
2. **`Exercises.builtInKey` (text, nullable, unique)** : clé stable des exercices intégrés (ex. `bench_press`). Le nom affiché vient alors de l'ARB (`exercise_bench_press`) ; les exercices personnalisés utilisent `name`.
3. **Table locale `SyncMeta`** (NON synchronisée, PK `key` text) : `deviceId`, `lastPushAt`, `lastPullCursor` (JSON : dernier fichier lu par appareil distant), `provider`, `accountEmail`.
4. **`WorkoutSessions.bodyWeightKg` (real, nullable)** : facultatif, pour les exercices au poids du corps.
5. Index sur `updated_at` de chaque table synchronisée (requêtes de push).
6. **État de séance persistant** (ajouté à l'implémentation) : `WorkoutSessions.restEndsAt`, `pausedAt`, `pausedSeconds`, pour que le repos et la pause survivent à un redémarrage (§5.1).
7. **Cibles copiées dans la séance** (ajouté à l'implémentation) : `SessionExercises.targetRepsMin`, `targetRepsMax`, `restSeconds` (§4.2 : modifier le programme ne change pas l'historique).
8. **Horodatages normalisés** : Drift stocke les dates en texte ISO-8601 (`store_date_time_values_as_text`) et les compare comme des chaînes ; toutes les dates écrites sont donc en UTC, à la milliseconde. Conversion `toLocal()` à l'affichage.
9. **IDs des exercices intégrés** : UUID v5 dérivé de `builtInKey` et horodatage fixe (2000-01-01) : chaque appareil crée les mêmes lignes, toute modification de l'utilisateur gagne à la synchro.

### 4.2 Règles
- PK = UUID v4 texte. Aucune suppression physique : `deleted = true`.
- Toutes les requêtes de lecture filtrent `deleted = 0`.
- Poids stockés **en kg** (double). Conversion à l'affichage seulement.
- `orderIndex` : entiers espacés (10, 20, 30…) pour réordonner sans tout renuméroter.
- Démarrer une séance **copie** le plan (nom du jour, exercices, cibles) dans la séance : modifier le programme ensuite ne change pas l'historique.

### 4.3 Données initiales
`exercises_seed.dart` : ~60 exercices courants avec `builtInKey`, `muscleGroup`, `equipment`, `trackingType`. Insérés au premier lancement (et à chaque montée de version si nouvelles clés). Groupes : `chest`, `back`, `shoulders`, `biceps`, `triceps`, `legs`, `glutes`, `core`, `cardio`, `full_body`. Équipements : `barbell`, `dumbbell`, `machine`, `cable`, `bodyweight`, `kettlebell`, `band`, `other`.

---

## 5. Logique métier

### 5.1 Séance guidée — `SessionBloc` (`features/session/bloc/`)

États (`sealed class SessionState`) : `SessionIdle` → `SessionActive(exerciseIndex, setIndex)` ⇄ `SessionResting(endsAt)` → `SessionPaused` → `SessionFinished`.
Les transitions ci-dessous sont des **événements** (`sealed class SessionEvent`) : `SessionStarted`, `SetCompleted`, `RestSkipped`, `RestExtended`, `ExerciseSkipped`, `ExerciseSelected`, `ExerciseAdded`, `ExercisesReordered`, `SetAdded`, `SetRemoved`, `SessionPaused`, `SessionResumed`, `SessionFinishRequested`, `SessionDiscarded`, plus un événement interne `RestTicked` (émis par un `Stream.periodic` d'une seconde pendant le repos, calculé à partir de `endsAt`).
Les règles de transition pures (quel est le prochain exercice/série, fin de séance) vivent dans `domain/session/session_rules.dart`, testables sans Flutter.

Transitions :
- `start(programDayId?)` : crée la séance, copie le plan, pré-remplit chaque série avec la cible ; passe à `active(0, 0)`.
- `completeSet(reps, weightKg, …)` : enregistre `completedAt`, puis :
  - s'il reste des séries ou des exercices → `resting(endsAt = now + restSeconds)` ;
  - sinon → propose « Terminer la séance ».
- `skipRest()`, `extendRest(+15 s / −15 s)`.
- `skipExercise()`, `goToExercise(i)`, `addExercise(exerciseId)`, `reorderExercises()`, `addSet()`, `removeSet()`.
- `pause()` / `resume()` : le chrono de séance s'arrête.
- `finish()` : `endedAt = now` → écran de résumé. `discard()` : séance marquée `deleted` (avec confirmation).

Exigences :
- **Le repos est stocké comme horodatage de fin (`endsAt`)**, jamais comme un compte à rebours en mémoire : il reste juste après une mise en arrière-plan ou un redémarrage.
- À l'entrée en repos : programmer une **notification locale** à `endsAt` (son + vibration), l'annuler si le repos est sauté.
- À la fin du repos au premier plan : vibration (`HapticFeedback.heavyImpact`) + passage visuel à la série suivante.
- **Reprise** : au lancement, s'il existe une séance avec `endedAt = null`, proposer « Reprendre la séance » sur l'accueil.
- Une seule séance en cours à la fois.

### 5.2 Calculs de progrès (`domain/progress/`)
- **1RM estimé** (Epley) : `weight × (1 + reps / 30)`, seulement pour 1 ≤ reps ≤ 12 ; sinon non calculé.
- **Volume** d'une série : `weight × reps` (séries d'échauffement exclues).
- **Records personnels** par exercice : charge max, 1RM estimé max, reps max à une charge donnée, volume max sur une séance. Détectés à `completeSet` → badge « Record » immédiat, et listés dans le résumé de séance.
- **Valeur « Précédent »** : pour chaque série n, la série n de la dernière séance terminée contenant cet exercice.
- **Suggestion de progression** (simple, V1) : si toutes les séries de la dernière séance ont atteint `targetRepsMax`, pré-remplir la charge +2,5 kg (barre) ou +1 kg (haltères/machines) ; sinon la même charge. Désactivable dans les réglages.

### 5.3 Unités
- `units.dart` : `kgToDisplay`, `displayToKg`, arrondi à 0,5 (kg) ou 1 (lb) à l'affichage.
- Pas d'incrément des boutons +/− : 2,5 kg ou 5 lb (réglable).

---

## 6. Design system

### 6.1 Palette « Savane » (mode sombre par défaut)

| Rôle | Sombre | Clair | Usage |
|---|---|---|---|
| `background` | `#141210` | `#FAF7F4` | Fond d'écran |
| `surface` | `#1C1815` | `#FFFFFF` | Cartes, feuilles |
| `surfaceHigh` | `#221D19` | `#F3EEE9` | Lignes de série, champs |
| `surfaceHighest` | `#2D2621` | `#E9E2DB` | Champs actifs, puces |
| `outline` | `#3A332E` | `#D8CFC6` | Bordures, séparateurs |
| `onSurface` | `#F3EEE8` | `#1F1A16` | Texte principal |
| `onSurfaceVariant` | `#A89E94` | `#6B6158` | Texte secondaire |
| `primary` (terre cuite) | `#E2683C` | `#C4532A` | Action principale, élément actif |
| `onPrimary` | `#1A0D06` | `#FFFFFF` | Texte sur primary |
| `secondary` (ocre) | `#E8A33D` | `#B9791A` | Repos, minuteurs |
| `success` | `#6FBF73` | `#3E8E43` | Série validée, record |
| `error` | `#E5534B` | `#C23A33` | Suppression, erreurs |

- Construire `ColorScheme.fromSeed(seedColor: Color(0xFFE2683C), brightness: …)` puis **surcharger** avec les valeurs ci-dessus via `.copyWith(...)`.
- `success` n'existe pas dans `ColorScheme` : l'exposer via une `ThemeExtension<AppColors>`.
- **Une couleur = un rôle.** Pas de couleur décorative.
- Contraste : texte ≥ 4.5:1 ; vérifier `onPrimary` sur `primary` dans les deux modes.

### 6.2 Typographie
- Police : **Inter** (embarquée dans `assets/fonts/`, déclarée dans `pubspec.yaml`).
- **Chiffres tabulaires partout où un nombre change** (charges, reps, minuteurs) : `fontFeatures: [FontFeature.tabularFigures()]`.
- Échelle : `displayLarge` 48 (minuteur de repos plein écran), `headlineSmall` 24 (nom de l'exercice en cours), `titleMedium` 16/500, `bodyMedium` 14, `labelSmall` 11 (en-têtes de colonnes).
- Graisses : 400 et 600 seulement.

### 6.3 Espacements, formes, tailles
- Grille de 4 : `xs 4`, `sm 8`, `md 12`, `lg 16`, `xl 24`, `xxl 32`.
- Rayons : champs/lignes 10, cartes 16, bouton principal 14, feuilles du bas 24 (haut).
- **Cible tactile min. 48 dp ; 56 dp pour toute action de séance** (valider, +/−, cocher).
- Marges d'écran horizontales : 16.

### 6.4 Icônes — Phosphor (`phosphor_flutter`)
- **Regular** par défaut ; **Fill** uniquement pour l'onglet actif de la barre de navigation ; **Duotone** pour les états vides.
- Tailles : 24 (standard), 20 (lignes denses), 48–64 (états vides).
- Correspondances :

| Usage | Icône |
|---|---|
| Accueil | `house` |
| Programmes | `listChecks` |
| Séance | `barbell` |
| Historique | `clockCounterClockwise` |
| Progrès | `chartLineUp` |
| Repos / minuteur | `timer` / `hourglassMedium` |
| Record | `trophy` |
| Valider | `check` |
| Ajouter | `plus` |
| Réordonner | `dotsSixVertical` |
| Supprimer | `trash` |
| Réglages | `gearSix` |
| Synchro | `cloudArrowUp` / `cloudCheck` / `cloudSlash` |
| Poids corporel | `scales` |

### 6.5 Mouvement et retour haptique
- Durées : 150 ms (micro), 250 ms (transitions). Courbe `Curves.easeOutCubic`.
- Haptique : `selectionClick` sur +/−, `mediumImpact` à la validation d'une série, `heavyImpact` à la fin du repos.

### 6.6 Ton des textes (FR)
- Tutoiement, phrases courtes, verbe d'abord : « Valider la série », « Démarrer la séance ».
- Pas de « s'il vous plaît », pas de points d'exclamation système.
- États vides = invitation : « Crée ton premier programme ».

---

## 7. Composants partagés (`core/widgets/`)

| Composant | Description |
|---|---|
| `PrimaryActionButton` | Bouton plein `primary`, hauteur 56, pleine largeur. **Un seul par écran.** |
| `SecondaryButton` | Tonal (`surfaceHighest`) ou contour |
| `WeightStepper` | Valeur centrale + boutons −/+ (56 dp) ; appui long = répétition ; tap sur la valeur = clavier numérique |
| `RepsStepper` | Idem, pas de 1 |
| `SetRow` | Ligne Série / Précédent / kg / Reps / ✓ ; états : à faire (atténué), en cours (bordure `primary`), validée (fond vert sombre + coche), échauffement (étiquette « É ») |
| `RestTimerBar` | Barre compacte (icône ocre, progression, temps restant, −15 / +15 / Passer) |
| `RestTimerFullScreen` | Variante plein écran (gros chiffres `displayLarge`) |
| `ExerciseTile` | Ligne de liste : icône du groupe musculaire, nom, équipement |
| `ProgramCard` | Carte : nom, nb de jours, dernière séance, bouton « Démarrer » |
| `StatTile` | Petit indicateur : libellé + chiffre (records, volume semaine) |
| `PrBadge` | Pastille `success` + icône trophée |
| `EmptyState` | Icône duotone + titre + phrase + action |
| `ConfirmSheet` | Feuille du bas de confirmation (actions destructives en `error`) |
| `SyncStatusChip` | État de la synchro (à jour / en cours / erreur / désactivée) |

Chaque composant a un test widget et un exemple dans une page cachée `/_gallery` (debug uniquement).

---

## 8. Écrans

Navigation : `StatefulShellRoute` à 5 onglets — **Accueil · Programmes · Séance · Historique · Progrès**. Réglages accessibles depuis l'icône `gearSix` de l'accueil.

### 8.1 Accueil `/`
- En-tête : salutation + `SyncStatusChip` + réglages.
- Carte « Reprendre la séance » si une séance est en cours (prioritaire, en haut).
- Carte « Prochaine séance » : prochain jour du programme actif (rotation : jour suivant le dernier fait) + bouton principal « Démarrer ».
- Ligne de `StatTile` : séances cette semaine, volume de la semaine, série de semaines actives.
- Derniers records (3 max).
- État vide (aucun programme) : « Crée ton premier programme » + action secondaire « Séance libre ».

### 8.2 Programmes `/programs`
- Liste de `ProgramCard` ; le programme actif est marqué. Menu : renommer, dupliquer, activer, supprimer.
- FAB / bouton « Nouveau programme ».

### 8.3 Éditeur de programme `/programs/:id`
- Nom, description, liste des jours (réordonnables par glisser).
- Tap sur un jour → éditeur de jour.

### 8.4 Éditeur de jour `/programs/:id/days/:dayId`
- Liste réordonnable des exercices planifiés : nom, `4 × 8–10 · 60 kg · repos 1:30`.
- Tap → feuille d'édition des cibles (séries, reps min/max, charge, durée selon `trackingType`, repos, notes).
- « Ajouter un exercice » → sélecteur (bibliothèque, multi-sélection).

### 8.5 Bibliothèque d'exercices `/exercises`
- Recherche + filtres par groupe musculaire et équipement (puces).
- « Créer un exercice » : nom, groupe, équipement, type de suivi.
- Détail `/exercises/:id` : records, courbe 1RM estimé, historique des séances de cet exercice.

### 8.6 Séance guidée `/session` ← **écran le plus important**
Disposition de haut en bas :
1. Barre : réduire (`caretDown`), nom du jour, chrono de séance, menu (pause, terminer, abandonner).
2. Nom de l'exercice (`headlineSmall`) + « Exercice 2 sur 6 · cible 4 × 8–10 » ; balayage horizontal ou flèches pour changer d'exercice.
3. Tableau de `SetRow` (en-têtes : Série · Précédent · kg · Reps · ✓). La série en cours est mise en évidence ; ses valeurs sont éditables par `WeightStepper` / `RepsStepper` dans une zone dédiée sous le tableau.
4. « + Ajouter une série ».
5. `RestTimerBar` (visible pendant le repos).
6. `PrimaryActionButton` contextuel : « Valider la série » → « Passer le repos » pendant le repos → « Exercice suivant » → « Terminer la séance ».

Comportements :
- Valider avec les valeurs pré-remplies doit prendre **un seul tap**.
- Wakelock actif pendant la séance (réglable).
- Mini-lecteur persistant au-dessus de la barre de navigation si on quitte l'écran pendant une séance (nom de l'exercice + repos restant) ; tap → retour à la séance.
- Notes rapides par exercice (icône `notePencil`).

### 8.7 Résumé de séance `/session/:id/summary`
- Durée, volume total, nombre de séries, records battus (avec `PrBadge`), comparaison avec la séance précédente du même jour.
- Note libre, puis « Terminer ».

### 8.8 Historique `/history`
- Liste groupée par semaine/date : nom, durée, volume, nombre de records.
- Détail `/history/:sessionId` : exercices et séries ; édition a posteriori (corriger une charge), suppression.

### 8.9 Progrès `/progress`
- Sélecteur de période (4 sem. / 3 mois / 1 an / tout).
- `StatTile` : séances, volume total, records.
- Graphique de volume hebdomadaire (barres).
- Liste des exercices les plus faits → détail avec courbe (charge max / 1RM estimé / volume, au choix).
- Section poids corporel → `/body` (saisie + courbe).

### 8.10 Réglages `/settings`
- Unités (kg/lb), pas d'incrément, repos par défaut, suggestion de progression on/off.
- Thème (système / sombre / clair), langue (FR/EN).
- Écran allumé pendant la séance, son et vibration de fin de repos.
- **Synchronisation** : connecter Google Drive, état, « Synchroniser maintenant », dernière synchro, déconnecter.
- Export JSON / import JSON.
- À propos, licences, politique de confidentialité.

---

## 9. Synchronisation sur le cloud de l'utilisateur

### 9.1 Interface

```dart
abstract class CloudSyncProvider {
  String get id; // 'google_drive', 'onedrive'
  Future<CloudAccount?> currentAccount();
  Future<CloudAccount> signIn();
  Future<void> signOut();
  Future<List<CloudFile>> listFiles({String? prefix});
  Future<List<int>> download(String fileId);
  Future<CloudFile> upload(String name, List<int> bytes, {String? existingFileId});
  Future<void> delete(String fileId);
}
```

### 9.2 Format sur le cloud (dans l'`appDataFolder`)

```
endelea/
  manifest.json                         # { formatVersion: 1, schemaVersion, createdAt }
  changes/<deviceId>/<epochMillis>.json.gz   # lot de changements d'un appareil (append-only)
  snapshot/<epochMillis>.json.gz        # instantané compacté (optionnel, §9.5)
```

Un lot de changements :

```json
{
  "formatVersion": 1,
  "deviceId": "…",
  "createdAt": "2026-11-19T18:00:00Z",
  "tables": {
    "exercises": [ { "id": "…", "updatedAt": "…", "deleted": false, "…": "…" } ],
    "set_entries": [ … ]
  }
}
```

### 9.3 Algorithme (`sync_engine.dart`)
1. **Push** : sélectionner toutes les lignes de toutes les tables synchronisées avec `updatedAt > lastPushAt` ; si non vide, écrire un lot dans `changes/<monDeviceId>/` ; mettre à jour `lastPushAt` (horodatage pris **avant** la sélection).
2. **Pull** : lister `changes/*/` ; pour chaque appareil distant, lire les fichiers plus récents que le curseur `lastPullCursor[deviceId]` ; appliquer dans une transaction.
3. **Fusion (last-write-wins par ligne)** : la ligne entrante remplace la locale si `incoming.updatedAt > local.updatedAt`, ou à égalité si `incoming.lastModifiedBy > local.lastModifiedBy` (ordre lexical, déterministe). Les suppressions (`deleted = true`) suivent la même règle.
4. Ordre d'application des tables : `exercises → programs → program_days → program_exercises → workout_sessions → session_exercises → set_entries → body_measurements`. Clés étrangères désactivées pendant l'application (`PRAGMA defer_foreign_keys = ON`).
5. Les écritures faites par la synchro **ne modifient pas** `updatedAt` (pas de ping-pong).

### 9.4 Déclenchement
- Au démarrage de l'app (pull puis push), à la fin d'une séance, au retour au premier plan si la dernière synchro date de plus de 15 min, et manuellement.
- **Jamais pendant une séance active** (sauf demande manuelle).
- Pas de travail en arrière-plan en V1.
- Erreurs réseau : silencieuses, état « erreur » dans `SyncStatusChip`, nouvel essai au prochain déclencheur.

### 9.5 Compaction (V1.1)
Quand `changes/` dépasse ~200 fichiers : un appareil écrit un `snapshot` complet, puis supprime **ses propres** lots antérieurs au snapshot. Un nouvel appareil lit d'abord le snapshot le plus récent, puis les lots postérieurs.

### 9.6 Google Drive
- Scope **`https://www.googleapis.com/auth/drive.appdata` uniquement**.
- `google_sign_in` → client authentifié `googleapis` → `DriveApi`, `spaces: 'appDataFolder'`.
- Projet Google Cloud + écran de consentement OAuth (à faire par le développeur, voir §13).

### 9.7 Android Auto Backup
- `android:allowBackup="true"` + `android:fullBackupContent` / `dataExtractionRules` incluant la base SQLite et excluant le cache.
- Filet de sécurité gratuit, indépendant de la synchro.

### 9.8 Export / import JSON
- Export : toutes les tables (non supprimées) → fichier `endelea-export-<date>.json`, partagé via la feuille de partage système.
- Import : fusion selon la même règle LWW (§9.3).

---

## 10. Internationalisation
- `l10n.yaml`, fichiers `app_fr.arb` (modèle) et `app_en.arb`.
- **Aucune chaîne en dur dans les widgets.**
- Noms des exercices intégrés : clés `exercise_<builtInKey>`.
- Formats : `NumberFormat.decimalPattern(locale)` (virgule en FR), dates via `DateFormat`.

---

## 11. Accessibilité
- Contraste ≥ 4.5:1, cibles ≥ 48 dp, `Semantics` sur les steppers (« Charge, 62,5 kilos, augmenter »).
- Supporter un agrandissement du texte jusqu'à 130 % sans débordement sur l'écran de séance.
- Ne jamais transmettre une information par la couleur seule (coche + couleur pour une série validée).

---

## 12. Qualité et tests
- **Unitaires** : calculs de progrès, règles de séance, conversion d'unités, `sync_engine` (fusion LWW, tie-break, suppressions, ordre des tables) avec un faux `CloudSyncProvider` en mémoire.
- **Blocs/Cubits** : `bloc_test` pour chaque Cubit/Bloc (repositories mockés avec `mocktail`). `SessionBloc` couvert scénario par scénario (valider → repos → série suivante → exercice suivant → fin, pause/reprise, repos sauté/prolongé).
- **Base** : tests de repositories sur Drift en mémoire (`NativeDatabase.memory()`), y compris la mise à jour d'`updatedAt`.
- **Widgets** : composants §7, écran de séance (valider une série, repos, passage à l'exercice suivant).
- **Golden tests** (optionnel) : `SetRow` dans ses 4 états, en sombre et en clair.
- Seuil : la logique `domain/` et `sync/` couverte à ≥ 80 %.
- `flutter analyze` sans avertissement ; `dart format` appliqué.

---

## 13. CI/CD et prérequis
- **Release Android** : utiliser le skill `android-release` existant (déclenchement sur merge vers `production`, signature locale + CI, GitHub Release).
- CI sur chaque PR : `flutter analyze`, `flutter test`, `dart run build_runner build --delete-conflicting-outputs` (vérifier qu'il ne change rien).
- Identifiant d'application : `com.kdynamics.endelea` (à confirmer).
- **Tâches manuelles du développeur** (Claude Code ne peut pas les faire) :
  1. Créer le projet Google Cloud, activer l'API Drive, configurer l'écran de consentement (scope `drive.appdata`), créer les identifiants OAuth Android (SHA-1 debug + release).
  2. Politique de confidentialité hébergée (requise par Google) — domaine à réserver (ex. `endelea.app`).
  3. Recherche de marque à l'OPIC pour « Endelea ».

---

## 14. Phases d'implémentation

Chaque phase se termine par : `flutter analyze` propre, tests verts, commit. Ne pas commencer une phase avant que la précédente soit acceptée.

### Phase 0 — Squelette
- [x] `flutter create` (org `com.kdynamics`, nom `endelea`), Android + iOS.
- [x] Dépendances §2, lint strict, `l10n.yaml`, polices embarquées.
- [x] Arborescence §3.2 vide avec fichiers stubs.
- [x] `app.dart` : `MaterialApp.router`, thème Savane sombre/clair, FR/EN.
- [x] Shell de navigation à 5 onglets (écrans « placeholder »).
- **Acceptation** : l'app démarre en FR, mode sombre, 5 onglets avec icônes Phosphor (Fill sur l'onglet actif).

### Phase 1 — Données
- [x] Intégrer `database.dart` + ajouts §4.1 ; migration v1.
- [x] Repositories (CRUD, soft delete, `updatedAt` / `lastModifiedBy` automatiques).
- [x] `deviceId` généré au premier lancement (`SyncMeta`).
- [x] Seed des exercices + clés ARB.
- **Acceptation** : tests de repositories verts ; seed idempotent.

### Phase 2 — Design system
- [x] `AppColors` (ThemeExtension), `app_theme.dart`, typographie, espacements.
- [x] Composants §7 + galerie `/_gallery`.
- **Acceptation** : galerie affichant chaque composant dans ses états, en sombre et en clair ; tests widget.

### Phase 3 — Exercices et programmes
- [x] Bibliothèque (recherche, filtres, création).
- [x] Programmes : liste, éditeur, jours, exercices planifiés (réordonnancement, cibles).
- [x] Activation d'un programme.
- **Acceptation** : créer « PPL » avec 3 jours et 5 exercices chacun, entièrement au doigt, données persistées après redémarrage.

### Phase 4 — Séance guidée ★
- [x] `SessionBloc` (§5.1) + règles pures + tests `bloc_test`.
- [x] Écran de séance (§8.6), steppers, `SetRow`, valeurs « Précédent », pré-remplissage.
- [x] Minuteur de repos par horodatage + notification locale + haptique.
- [x] Wakelock, mini-lecteur persistant, reprise de séance au démarrage.
- [x] Séance libre (sans programme).
- [x] Résumé de séance + détection des records.
- **Acceptation** : faire une séance complète de 5 exercices × 4 séries sans clavier ; tuer l'app pendant un repos, la rouvrir → séance et repos restants intacts ; notification reçue écran verrouillé.

### Phase 5 — Historique et progrès
- [x] Historique groupé, détail, édition a posteriori.
- [x] Calculs §5.2 + tests.
- [x] Écran Progrès, détail exercice (courbes `fl_chart`), poids corporel.
- [x] Accueil complet (§8.1).
- **Acceptation** : avec 10 séances de test, les courbes et les records sont corrects (comparés à un calcul manuel dans les tests).

### Phase 6 — Réglages et export
- [x] Réglages §8.10 (hors synchro).
- [x] Export / import JSON. *(Partage et sélection de fichier par un canal natif `endelea/files` — Android et iOS — pour ne pas ajouter `share_plus` / `file_picker`, absents du §2.)*
- [x] Android Auto Backup configuré.
- **Acceptation** : bascule kg ↔ lb sans perte de précision ; export puis import sur une base vide → données identiques.

### Phase 7 — Synchro Google Drive
- [x] Interface `CloudSyncProvider`, `SyncCodec`, `SyncEngine` + tests avec faux provider.
- [x] `SyncBloc` (événements : `SyncRequested`, `SyncSignInRequested`, `SyncSignOutRequested` ; états : désactivée / à jour / en cours / erreur).
- [x] `GoogleDriveProvider` (`drive.appdata`). *(Code prêt ; test réel en attente des identifiants OAuth, voir §13. L'identifiant client Web se passe par `--dart-define=GOOGLE_SERVER_CLIENT_ID=…`.)*
- [x] Déclencheurs §9.4, `SyncStatusChip`, écran Réglages > Synchronisation.
- **Acceptation** : deux appareils (ou émulateurs) sur le même compte : une séance faite sur A apparaît sur B ; une suppression sur B disparaît de A ; modification concurrente → la plus récente gagne.

### Phase 8 — Finition et release
- [x] Accessibilité §11, texte à 130 %.
- [x] Icône d'app et écran de démarrage (terre cuite sur fond `#141210`).
- [x] Revue des chaînes FR/EN.
- [x] Pipeline `android-release`.
- **Acceptation** : build release signé, installé, parcours complet sans erreur.

### Après V1
OneDrive (`Files.ReadWrite.AppFolder`), iCloud sur iOS, compaction (§9.5), Health Connect, widget Android « Prochaine séance », minuteur sur montre.

---

## 15. Questions ouvertes
1. Identifiant d'application définitif (`com.kdynamics.endelea` ?).
2. Liste exacte des ~60 exercices du seed (proposition générée en phase 1, à valider).
3. Rotation des jours du programme : séquentielle (A → B → C → A) ou par jour de la semaine ? (V1 : séquentielle.)
4. Faut-il un mode « superset » (deux exercices alternés) en V1 ou V2 ?
