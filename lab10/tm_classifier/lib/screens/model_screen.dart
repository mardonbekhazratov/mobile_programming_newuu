import 'package:flutter/material.dart';

import '../services/classifier.dart';
import '../theme/app_theme.dart';
import '../theme/design_credit.dart';

/// Screen 5. Reads everything from the loaded classifier, not from the files.
class ModelScreen extends StatelessWidget {
  const ModelScreen({super.key, required this.info, required this.onSample, required this.onTextFile});
  final ModelInfo info;
  final VoidCallback onSample, onTextFile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = context.tokens;
    Widget row(String k, String v) => ListTile(
      dense: true,
      title: Text(k),
      trailing: Text(v, style: theme.textTheme.titleSmall),
    );
    Widget heading(String s) => Padding(
      padding: EdgeInsets.fromLTRB(t.gapXs, t.gapXl, 0, t.gapS),
      child: Text(s, style: theme.textTheme.labelSmall),
    );
    return ListView(
      padding: EdgeInsets.all(t.gutter),
      children: [
        Text('Model', style: theme.textTheme.headlineSmall),
        heading('FILE'),
        Card(
          child: Column(
            children: [
              row('Model file', info.modelFileName),
              row('Size', '${(info.modelBytes / 1024 / 1024).toStringAsFixed(1)} MB'),
              row('Input', '${info.inputSize} × ${info.inputSize} × 3, ${info.quantized ? 'uint8' : 'float32'}'),
              row('Classes', '${info.classCount}'),
            ],
          ),
        ),
        heading('LABELS (labels.txt)'),
        Card(
          child: Column(
            children: [
              for (final (i, l) in info.labels.indexed)
                ListTile(
                  dense: true,
                  leading: Text('$i', style: theme.textTheme.titleSmall),
                  title: Text(l),
                ),
            ],
          ),
        ),
        heading('CHECKS'),
        OutlinedButton(onPressed: onSample, child: const Text('Classify sample.jpg')),
        SizedBox(height: t.gapS),
        OutlinedButton(onPressed: onTextFile, child: const Text('Classify a text file')),
        heading('DESIGN'),
        Card(
          child: ListTile(
            title: Text('${DesignCredit.name} by ${DesignCredit.author}'),
            subtitle: Text('${DesignCredit.licence}\n${DesignCredit.url}'),
            isThreeLine: true,
          ),
        ),
      ],
    );
  }
}
