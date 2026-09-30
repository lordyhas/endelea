import 'package:flutter/material.dart';

import '../data/rest_timer.dart';
import '../utils/format.dart';

class RestTimerBar extends StatelessWidget {
  const RestTimerBar({super.key, required this.timer});

  final RestTimer timer;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: timer,
      builder: (context, _) {
        if (!timer.isRunning) return const SizedBox.shrink();
        final scheme = Theme.of(context).colorScheme;
        final label = formatDuration(timer.remaining, clock: true);
        return Material(
          color: scheme.secondaryContainer,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.hourglass_bottom,
                    color: scheme.onSecondaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Rest $label',
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(color: scheme.onSecondaryContainer),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => timer.add(const Duration(seconds: 15)),
                    child: const Text('+15s'),
                  ),
                  TextButton(onPressed: timer.stop, child: const Text('Skip')),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
