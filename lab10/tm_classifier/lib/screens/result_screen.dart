import 'package:flutter/material.dart';

import '../models.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

/// Screen 3. The same widget for every source; history reopens it without
/// running the model again.
class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.record});
  final ClassificationRecord record;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.tokens;
    final maxImage = MediaQuery.sizeOf(context).height * t.imageMaxFraction;
    final total = record.predictions.fold(0.0, (s, p) => s + p.confidence) * 100;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Result'),
        actions: [
          SourceChip(record.origin),
          SizedBox(width: t.gapL),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(t.gutter),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxImage),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(t.radiusL),
                child: Image.memory(record.bytes, fit: BoxFit.contain),
              ),
            ),
          ),
          SizedBox(height: t.gapXl),
          Text(record.top.label, style: theme.textTheme.headlineSmall, textAlign: TextAlign.center),
          SizedBox(height: t.gapL),
          PredictionBars(predictions: record.predictions),
          SizedBox(height: t.gapM),
          Text(
            'Total ${total.toStringAsFixed(1)} % · classified in ${record.elapsed.inMilliseconds} ms',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
