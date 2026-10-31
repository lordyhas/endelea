# CLAUDE.md — Endelea

Gym workout-tracking app (Flutter). Full design plan: `docs/PLAN.md` — read it before any task; it is the source of truth.

## Working rules
- Implement phase by phase (`docs/PLAN.md` §14). Don't start a phase before the previous one meets its acceptance criteria. Tick the checkboxes in PLAN.md as tasks are done.
- **All code in English**: identifiers, comments, commit messages. User-facing strings go in ARB files (French is the template locale, English second). No hard-coded UI strings.
- Don't add dependencies outside PLAN.md §2 without asking.
- If the plan is ambiguous or seems wrong, stop and ask instead of guessing.

## Architecture invariants
- Local Drift database is the source of truth; the app must work fully offline.
- State management: `flutter_bloc`. Use `Cubit` by default; use `Bloc` (events) only for `SessionBloc` and `SyncBloc`. States are `sealed class` + `Equatable`, never mutable.
- Widgets never touch Drift or repositories directly — only Cubits/Blocs. Repositories are provided via `MultiRepositoryProvider`; screen-level Cubits are created in their route with `BlocProvider`. No `get_it`.
- Repositories are the only writers. Every write sets `updatedAt` and `lastModifiedBy`. Never hard-delete synced rows: set `deleted = true`. Every read filters `deleted = 0`.
- Sync writes must NOT bump `updatedAt`.
- Weights are stored in kg; convert only for display.
- Rest timers are stored as an end timestamp (`endsAt`), never as an in-memory countdown.
- Use the injected `Clock` instead of `DateTime.now()` in logic that needs testing.
- Every Cubit/Bloc has `bloc_test` tests.

## UI invariants
- Theme tokens only (`Theme.of(context).colorScheme`, `AppColors` extension, spacing constants). No raw hex in widgets.
- Icons: `phosphor_flutter` only. Regular by default, Fill only for the active nav tab, Duotone for empty states.
- One primary filled button per screen. Session actions: touch targets ≥ 56 dp.
- Numbers that change (weights, reps, timers) use tabular figures.

## Commands
- Codegen: `dart run build_runner build --delete-conflicting-outputs`
- Analyze: `flutter analyze` (must be clean)
- Test: `flutter test`
- Format: `dart format .`

## Before finishing any task
Run codegen, analyze, and tests. Report anything that couldn't be verified (e.g. Google sign-in needs real OAuth credentials, notifications need a device).
