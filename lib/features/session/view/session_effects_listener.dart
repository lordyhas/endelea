import 'dart:async';

import 'package:endelea/core/l10n/l10n.dart';
import 'package:endelea/core/router/app_router.dart';
import 'package:endelea/features/session/bloc/session_bloc.dart';
import 'package:endelea/features/session/data/platform_session_effects.dart';
import 'package:endelea/features/session/data/session_effects.dart';
import 'package:endelea/features/settings/bloc/settings_cubit.dart';
import 'package:endelea/features/settings/bloc/sync_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// App-wide side effects of the session: open the workout tab when a
/// session starts, the summary when it ends, keep the screen on, and
/// localize the rest notification.
class SessionEffectsListener extends StatelessWidget {
  const SessionEffectsListener({
    required this.router,
    required this.alerts,
    required this.child,
    super.key,
  });

  final GoRouter router;
  final RestAlerts alerts;
  final Widget child;

  static Future<void> _keepScreenOn({required bool enabled}) async {
    try {
      await WakelockPlus.toggle(enable: enabled);
    } on Object {
      // Not available (tests, desktop): the session works without it.
    }
  }

  @override
  Widget build(BuildContext context) {
    final alerts = this.alerts;
    if (alerts is LocalRestAlerts) {
      final l10n = context.l10n;
      alerts.texts = RestAlertTexts(
        title: l10n.restOverTitle,
        body: l10n.restOverBody,
        channelName: l10n.restChannelName,
        channelDescription: l10n.restChannelDescription,
      );
    }
    return MultiBlocListener(
      listeners: [
        BlocListener<SessionBloc, SessionState>(
          listenWhen: (a, b) =>
              (a is SessionIdle && b is SessionRunning) ||
              (a is! SessionFinished && b is SessionFinished),
          listener: (context, state) {
            if (state is SessionFinished) {
              context.read<SyncBloc>().add(
                const SyncRequested(SyncReason.sessionFinished),
              );
              unawaited(router.push(AppRoutes.sessionSummary(state.sessionId)));
            } else {
              router.go(AppRoutes.session);
            }
          },
        ),
        BlocListener<SessionBloc, SessionState>(
          listenWhen: (a, b) => (a is SessionRunning) != (b is SessionRunning),
          listener: (context, state) => _keepScreenOn(
            enabled:
                state is SessionRunning &&
                context.read<SettingsCubit>().settings.keepScreenOn,
          ),
        ),
      ],
      child: child,
    );
  }
}
