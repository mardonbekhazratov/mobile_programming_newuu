import 'package:flutter/material.dart';

import '../services/classifier.dart';
import '../theme/app_theme.dart';
import '../theme/design_credit.dart';
import '../widgets/common.dart';

/// Screen 1. Doubles as the loading and the start-up error screen.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key, required this.loading, required this.onRetry, required this.onStart});
  final Future<ImageClassifier> loading;
  final VoidCallback onRetry;
  final void Function(ImageClassifier) onStart;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
          future: loading,
          builder: (context, snap) {
            if (snap.hasError) return _error(snap.error!);
            return _body(context, snap.data);
          },
        ),
      ),
    );
  }

  Widget _error(Object e) {
    final load = e is ModelLoadException ? e : null;
    return StateView(
      icon: Icons.error_outline,
      title: load?.title ?? 'Start-up failed',
      message: [load?.detail ?? '$e', if (load?.path != null) 'Expected at: ${load!.path}'].join('\n\n'),
      action: FilledButton(onPressed: onRetry, child: const Text('Try again')),
    );
  }

  Widget _body(BuildContext context, ImageClassifier? classifier) {
    final theme = Theme.of(context);
    final t = context.tokens;
    final labels = classifier?.info.labels ?? const [];
    return ListView(
      padding: EdgeInsets.all(t.gutter),
      children: [
        SizedBox(height: t.gapXl * 2),
        Icon(Icons.center_focus_strong, size: 48, color: theme.colorScheme.primary),
        SizedBox(height: t.gapL),
        Text('Lens', style: theme.textTheme.displaySmall),
        SizedBox(height: t.gapS),
        Text(
          'Point the camera at one of the objects below and Lens tells you what it is, '
          'right on this phone, without the internet.',
          style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        SizedBox(height: t.gapXl),
        Text('I RECOGNISE', style: theme.textTheme.labelSmall),
        SizedBox(height: t.gapS),
        if (classifier == null)
          const LinearProgressIndicator()
        else
          Wrap(
            spacing: t.gapS,
            runSpacing: t.gapS,
            children: [for (final l in labels) Chip(label: Text(l))],
          ),
        SizedBox(height: t.gapXl),
        FilledButton(
          onPressed: classifier == null ? null : () => onStart(classifier),
          child: Text(classifier == null ? 'Loading model…' : 'Get started'),
        ),
        SizedBox(height: t.gapL),
        Text(
          'Design: ${DesignCredit.line}',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
