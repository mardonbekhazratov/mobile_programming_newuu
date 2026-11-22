import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'classifier.dart';

const kSampleAsset = 'assets/model/sample.jpg';

/// T10: classifies the bundled sample photo once at start-up and prints every
/// label with its percentage. Check: one line per class, the right label on
/// top, and a sum of 1.0 (within 0.01).
Future<void> runSmokeTest(ImageClassifier classifier) async {
  final Uint8List bytes;
  try {
    final data = await rootBundle.load(kSampleAsset);
    bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  } catch (_) {
    debugPrint(
      '[smoke] skipped: copy a photo of a trained object to '
      '$kSampleAsset',
    );
    return;
  }

  final watch = Stopwatch()..start();
  final predictions = classifier.classify(bytes);
  watch.stop();

  final width = predictions.fold(0, (w, p) => p.label.length > w ? p.label.length : w);
  final sum = predictions.fold(0.0, (s, p) => s + p.confidence);
  debugPrint('[smoke] $kSampleAsset in ${watch.elapsedMilliseconds} ms');
  for (final p in predictions) {
    debugPrint('[smoke]   ${p.label.padRight(width)}  ${p.percent.padLeft(7)}');
  }
  debugPrint(
    '[smoke] ${predictions.length} lines for '
    '${classifier.info.classCount} classes, top: ${predictions.first.label}, '
    'sum ${sum.toStringAsFixed(4)} '
    '${(sum - 1).abs() <= 0.01 ? 'OK' : 'NOT 1.0 - check the pre-processing'}',
  );
}
