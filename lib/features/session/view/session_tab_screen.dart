import 'package:endelea/core/l10n/l10n.dart';
import 'package:endelea/core/theme/app_spacing.dart';
import 'package:endelea/core/widgets/buttons.dart';
import 'package:endelea/core/widgets/feedback.dart';
import 'package:endelea/data/repositories/program_repository.dart';
import 'package:endelea/features/session/bloc/session_bloc.dart';
import 'package:endelea/features/session/bloc/session_start_cubit.dart';
import 'package:endelea/features/session/view/session_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// The workout tab: the session in progress, or what to start.
class SessionTabScreen extends StatelessWidget {
  const SessionTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SessionBloc, SessionState>(
      buildWhen: (a, b) =>
          a.runtimeType != b.runtimeType &&
          (a is! SessionRunning || b is! SessionRunning),
      builder: (context, state) => switch (state) {
        SessionRunning() => const SessionView(),
        SessionLoading() => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        SessionIdle() || SessionFinished() => BlocProvider(
          create: (context) =>
              SessionStartCubit(context.read<ProgramRepository>()),
          child: const SessionStartView(),
        ),
      },
    );
  }
}

class SessionStartView extends StatelessWidget {
  const SessionStartView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final session = context.read<SessionBloc>();
    return Scaffold(
      appBar: AppBar(title: Text(l10n.navSession)),
      body: BlocBuilder<SessionStartCubit, SessionStartState>(
        builder: (context, state) => switch (state) {
          SessionStartLoading() => const Center(
            child: CircularProgressIndicator(),
          ),
          SessionStartLoaded(next: null) => EmptyState(
            icon: PhosphorIconsDuotone.barbell,
            title: l10n.sessionNoProgramTitle,
            message: l10n.sessionNoProgramMessage,
            action: PrimaryActionButton(
              label: l10n.sessionStartFree,
              icon: PhosphorIconsRegular.play,
              onPressed: () => session.add(const SessionStarted()),
            ),
          ),
          SessionStartLoaded(:final next?, :final days) => ListView(
            padding: const EdgeInsets.all(AppSpacing.screen),
            children: [
              Text(
                l10n.sessionNextTitle.toUpperCase(),
                style: theme.textTheme.labelSmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        next.day.day.name,
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${next.program.name} · '
                        '${l10n.dayExercises(next.day.exerciseCount)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      PrimaryActionButton(
                        label: l10n.start,
                        icon: PhosphorIconsRegular.play,
                        onPressed: () => session.add(
                          SessionStarted(programDayId: next.day.day.id),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                l10n.sessionChooseDay.toUpperCase(),
                style: theme.textTheme.labelSmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              for (final day in days)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(day.day.name),
                  subtitle: Text(l10n.dayExercises(day.exerciseCount)),
                  trailing: const Icon(PhosphorIconsRegular.play),
                  onTap: () =>
                      session.add(SessionStarted(programDayId: day.day.id)),
                ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.sessionFree),
                trailing: const Icon(PhosphorIconsRegular.plus),
                onTap: () => session.add(const SessionStarted()),
              ),
            ],
          ),
        },
      ),
    );
  }
}
