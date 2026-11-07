import 'package:endelea/core/l10n/l10n.dart';
import 'package:endelea/features/session/view/mini_player.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

/// Index of the workout tab.
const sessionBranchIndex = 2;

/// Bottom navigation with five tabs. Fill icon on the active tab only.
/// While a session runs, a mini player sits above the bar on other tabs.
class AppShell extends StatelessWidget {
  const AppShell({required this.shell, super.key});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final destinations = [
      (PhosphorIconsRegular.house, PhosphorIconsFill.house, l10n.navHome),
      (
        PhosphorIconsRegular.listChecks,
        PhosphorIconsFill.listChecks,
        l10n.navPrograms,
      ),
      (
        PhosphorIconsRegular.barbell,
        PhosphorIconsFill.barbell,
        l10n.navSession,
      ),
      (
        PhosphorIconsRegular.clockCounterClockwise,
        PhosphorIconsFill.clockCounterClockwise,
        l10n.navHistory,
      ),
      (
        PhosphorIconsRegular.chartLineUp,
        PhosphorIconsFill.chartLineUp,
        l10n.navProgress,
      ),
    ];

    return Scaffold(
      body: shell,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (shell.currentIndex != sessionBranchIndex)
            MiniPlayer(onTap: () => shell.goBranch(sessionBranchIndex)),
          NavigationBar(
            selectedIndex: shell.currentIndex,
            onDestinationSelected: (index) => shell.goBranch(
              index,
              initialLocation: index == shell.currentIndex,
            ),
            destinations: [
              for (final (regular, fill, label) in destinations)
                NavigationDestination(
                  icon: Icon(regular),
                  selectedIcon: Icon(fill),
                  label: label,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
