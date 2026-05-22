import 'package:flutter/material.dart';

import '../app/store_scope.dart';
import '../app/template_scope.dart';
import '../models/exercise.dart';
import '../models/workout_template.dart';
import 'active_workout_screen.dart';
import 'template_editor_screen.dart';

class TemplatesScreen extends StatelessWidget {
  const TemplatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final templates = TemplateScope.of(context).templates;
    return Scaffold(
      appBar: AppBar(title: const Text('Routines')),
      floatingActionButton: FloatingActionButton(
        // Tabs live in an IndexedStack with other floating buttons.
        heroTag: null,
        tooltip: 'New routine',
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const TemplateEditorScreen()),
        ),
        child: const Icon(Icons.add),
      ),
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

  void _start(BuildContext context) {
    final store = StoreScope.of(context);
    if (store.active != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Finish your current workout first')),
      );
      return;
    }
    store.startFromTemplate(template);
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const ActiveWorkoutScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card.outlined(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => TemplateEditorScreen(template: template),
          ),
        ),
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
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.tonalIcon(
                  onPressed: () => _start(context),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
