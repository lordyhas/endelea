import 'package:flutter/material.dart';

import '../app/template_scope.dart';
import '../models/exercise.dart';
import '../models/workout_template.dart';

class TemplatesScreen extends StatelessWidget {
  const TemplatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final templates = TemplateScope.of(context).templates;
    return Scaffold(
      appBar: AppBar(title: const Text('Routines')),
      body: templates.isEmpty
          ? const Center(child: Text('No routine yet'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: templates.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) =>
                  TemplateCard(template: templates[index]),
            ),
    );
  }
}

class TemplateCard extends StatelessWidget {
  const TemplateCard({super.key, required this.template});

  final WorkoutTemplate template;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card.outlined(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  template.place == TrainingPlace.home
                      ? Icons.house_outlined
                      : Icons.fitness_center,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    template.name,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                Text(
                  '${template.exercises.length} exercises · '
                  '${template.setCount} sets',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              template.exercises.map((e) => e.exercise.name).join(', '),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
