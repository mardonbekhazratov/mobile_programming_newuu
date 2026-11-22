import 'package:flutter/material.dart';

import '../models.dart';
import '../services/classifier.dart';
import '../theme/app_theme.dart';

/// One row per label: name, bar, percentage. The top row is emphasised.
class PredictionBars extends StatelessWidget {
  const PredictionBars({super.key, required this.predictions});
  final List<Prediction> predictions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.tokens;
    return Column(
      children: [
        for (final (i, p) in predictions.indexed)
          Padding(
            padding: EdgeInsets.symmetric(vertical: t.gapXs + 2),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    p.label,
                    overflow: TextOverflow.ellipsis,
                    style: i == 0 ? theme.textTheme.titleSmall : theme.textTheme.bodyMedium,
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(t.barHeight),
                    child: LinearProgressIndicator(
                      value: p.confidence,
                      minHeight: t.barHeight,
                      color: i == 0 ? theme.colorScheme.primary : theme.colorScheme.outline,
                    ),
                  ),
                ),
                SizedBox(
                  width: 72,
                  child: Text(
                    p.percent,
                    textAlign: TextAlign.end,
                    style: (i == 0 ? theme.textTheme.titleSmall : theme.textTheme.bodyMedium)?.copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class SourceChip extends StatelessWidget {
  const SourceChip(this.origin, {super.key});
  final ImageOrigin origin;

  @override
  Widget build(BuildContext context) => Chip(avatar: Icon(origin.icon, size: 18), label: Text(origin.label));
}

/// Designed empty / error state.
class StateView extends StatelessWidget {
  const StateView({super.key, required this.icon, required this.title, required this.message, this.action});
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.tokens;
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(t.gutter),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(icon, size: 32, color: theme.colorScheme.onPrimaryContainer),
            ),
            SizedBox(height: t.gapL),
            Text(title, style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
            SizedBox(height: t.gapS),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[SizedBox(height: t.gapL), action!],
          ],
        ),
      ),
    );
  }
}

class RecordTile extends StatelessWidget {
  const RecordTile({super.key, required this.record, required this.onTap});
  final ClassificationRecord record;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final time = TimeOfDay.fromDateTime(record.time).format(context);
    return ListTile(
      onTap: onTap,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(t.radiusS),
        child: Image.memory(record.bytes, width: t.thumbnail, height: t.thumbnail, fit: BoxFit.cover, cacheWidth: 168),
      ),
      title: Text(record.top.label, overflow: TextOverflow.ellipsis),
      subtitle: Text('${record.top.percent} · $time'),
      trailing: Tooltip(message: record.origin.label, child: Icon(record.origin.icon)),
    );
  }
}
