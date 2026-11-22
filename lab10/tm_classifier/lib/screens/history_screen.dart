import 'package:flutter/material.dart';

import '../models.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// Screen 4. Every classification of this session, newest first.
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key, required this.history, required this.onOpen, required this.onStart});
  final History history;
  final void Function(ClassificationRecord) onOpen;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return ListenableBuilder(
      listenable: history,
      builder: (context, _) {
        final items = history.items;
        if (items.isEmpty) {
          return StateView(
            icon: Icons.history,
            title: 'No classifications yet',
            message: 'Take a photo, choose one from the gallery or download an image. Every result lands here.',
            action: FilledButton(onPressed: onStart, child: const Text('Classify something')),
          );
        }
        return ListView(
          padding: EdgeInsets.symmetric(vertical: t.gapL),
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: t.gutter),
              child: Row(
                children: [
                  Expanded(child: Text('History', style: Theme.of(context).textTheme.headlineSmall)),
                  TextButton(onPressed: history.clear, child: const Text('Clear')),
                ],
              ),
            ),
            for (final r in items) RecordTile(record: r, onTap: () => onOpen(r)),
          ],
        );
      },
    );
  }
}
