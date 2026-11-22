import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

/// Asset paths, exactly as declared under `flutter: assets:` in pubspec.yaml.
///
/// The model path can be overridden at build time to demonstrate the error
/// screen (T12) or to try the quantized export (stretch goal 2):
///   flutter run --dart-define=MODEL_ASSET=assets/model/model_unqant.tflite
const kModelAsset = String.fromEnvironment('MODEL_ASSET', defaultValue: 'assets/model/model_unquant.tflite');
const kLabelsAsset = 'assets/model/labels.txt';

class Prediction {
  const Prediction(this.label, this.confidence);
  final String label;
  final double confidence; // 0.0 to 1.0

  /// `(confidence * 100).toStringAsFixed(1)` followed by `%`.
  String get percent => '${(confidence * 100).toStringAsFixed(1)} %';
}

/// "0 Mug\n1 Bottle\n" becomes ['Mug', 'Bottle']. Pure, so it is unit-testable.
List<String> parseLabels(String raw) => [
  for (final line in raw.split('\n'))
    if (line.trim().isNotEmpty) line.trim().replaceFirst(RegExp(r'^\d+\s+'), ''),
];

/// Index i of [scores] belongs to line i of the labels. Pair first, sort
/// after: sorting the raw numbers first would put every label on the wrong row.
List<Prediction> pairAndSort(List<String> labels, List<double> scores) {
  if (labels.length != scores.length) {
    throw ArgumentError('${labels.length} labels but ${scores.length} scores');
  }
  return [for (var i = 0; i < labels.length; i++) Prediction(labels[i], scores[i])]
    ..sort((a, b) => b.confidence.compareTo(a.confidence));
}

/// Decodes [bytes] and crops/resizes them the way Teachable Machine did while
/// training: apply the EXIF rotation, take the centre square, scale it to
/// [size] × [size]. Throws a [FormatException] when the bytes are not an image.
img.Image prepareImage(Uint8List bytes, int size) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) {
    throw const FormatException('This file is not a picture the app can read (JPEG, PNG, GIF, BMP, WebP…).');
  }
  return img.copyResizeCropSquare(img.bakeOrientation(decoded), size: size);
}

/// Input tensor for the floating-point model: shape [1, size, size, 3], every
/// channel mapped from 0…255 to −1…1 with `value / 127.5 − 1`.
Float32List toFloatTensor(img.Image square) {
  final out = Float32List(square.width * square.height * 3);
  var i = 0;
  for (var y = 0; y < square.height; y++) {
    for (var x = 0; x < square.width; x++) {
      final p = square.getPixel(x, y);
      out[i++] = p.r / 127.5 - 1;
      out[i++] = p.g / 127.5 - 1;
      out[i++] = p.b / 127.5 - 1;
    }
  }
  return out;
}

/// Input tensor for the quantized model: the raw 0…255 channels, no scaling.
Uint8List toUint8Tensor(img.Image square) {
  final out = Uint8List(square.width * square.height * 3);
  var i = 0;
  for (var y = 0; y < square.height; y++) {
    for (var x = 0; x < square.width; x++) {
      final p = square.getPixel(x, y);
      out[i++] = p.r.toInt();
      out[i++] = p.g.toInt();
      out[i++] = p.b.toInt();
    }
  }
  return out;
}

/// Bytes in, tensor bytes out. Pure Dart, so it can run in another isolate.
ByteBuffer _encodeInput((Uint8List, int, bool) job) {
  final (bytes, size, quantized) = job;
  final square = prepareImage(bytes, size);
  return quantized ? toUint8Tensor(square).buffer : toFloatTensor(square).buffer;
}

/// Raised by [Classifier.load] with a message meant for the start-up screen.
class ModelLoadException implements Exception {
  const ModelLoadException(this.title, this.detail, {this.path});
  final String title;
  final String detail;
  final String? path; // where the file was expected, if a file is missing

  @override
  String toString() => '$title: $detail';
}

/// Everything the Model screen shows, read from the files themselves.
class ModelInfo {
  const ModelInfo({
    required this.modelAsset,
    required this.labelsAsset,
    required this.labels,
    required this.inputSize,
    required this.quantized,
    required this.modelBytes,
  });

  final String modelAsset;
  final String labelsAsset;
  final List<String> labels;
  final int inputSize;
  final bool quantized;
  final int modelBytes;

  String get modelFileName => modelAsset.split('/').last;
  int get classCount => labels.length;
}

/// What the screens depend on. The real implementation wraps TensorFlow
/// Lite; widget tests can hand the screens a fake without native code.
abstract interface class ImageClassifier {
  ModelInfo get info;

  /// Runs on the calling (UI) thread, as in the lab sample.
  List<Prediction> classify(Uint8List bytes);

  /// Pre-processing in a short-lived isolate, inference in the
  /// interpreter's own isolate (stretch goal 3).
  Future<List<Prediction>> classifyInBackground(Uint8List bytes);

  void close();
}

class Classifier implements ImageClassifier {
  Classifier._(this._interpreter, this._isolateInterpreter, this.info);

  final Interpreter _interpreter;
  final IsolateInterpreter _isolateInterpreter;
  @override
  final ModelInfo info;

  List<String> get labels => info.labels;
  int get inputSize => info.inputSize;

  /// 1. Loading is slow (read the file, allocate the tensors), so it happens
  /// once at start-up. Labels come from the same folder as the model.
  static Future<Classifier> load({String modelAsset = kModelAsset, String labelsAsset = kLabelsAsset}) async {
    final modelData = await _loadAsset(modelAsset, 'model');
    final rawLabels = await _loadAsset(labelsAsset, 'labels file');
    final labels = parseLabels(utf8.decode(rawLabels, allowMalformed: true));
    if (labels.isEmpty) {
      throw ModelLoadException(
        'The labels file is empty',
        'Export the model again and copy labels.txt from converted_tflite.zip.',
        path: labelsAsset,
      );
    }

    final Interpreter interpreter;
    try {
      interpreter = Interpreter.fromBuffer(modelData);
    } catch (e) {
      throw ModelLoadException(
        'The model file could not be opened',
        'It is not a TensorFlow Lite model, or it is damaged. Download the '
            'Tensorflow Lite export again ($e).',
        path: modelAsset,
      );
    }

    final input = interpreter.getInputTensor(0);
    final output = interpreter.getOutputTensor(0);
    final classes = output.shape.last;
    if (classes != labels.length) {
      interpreter.close();
      throw ModelLoadException(
        'Model and labels do not match',
        'The model has $classes outputs but labels.txt has ${labels.length} '
            'lines. Copy both files from the same export.',
        path: labelsAsset,
      );
    }

    final isolateInterpreter = await IsolateInterpreter.create(address: interpreter.address);
    return Classifier._(
      interpreter,
      isolateInterpreter,
      ModelInfo(
        modelAsset: modelAsset,
        labelsAsset: labelsAsset,
        labels: labels,
        inputSize: input.shape[1], // [1, 224, 224, 3]
        quantized: input.type == TensorType.uint8,
        modelBytes: modelData.length,
      ),
    );
  }

  static Future<Uint8List> _loadAsset(String path, String what) async {
    try {
      final data = await rootBundle.load(path);
      return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    } catch (_) {
      throw ModelLoadException(
        'The $what is missing',
        'No asset named "$path" is bundled. Put the file in assets/model/ '
            '(next to lib/, not inside it), check the spelling and keep '
            '"- assets/model/" under flutter: assets: in pubspec.yaml.',
        path: path,
      );
    }
  }

  @override
  List<Prediction> classify(Uint8List bytes) {
    final square = prepareImage(bytes, inputSize); // 2. same crop as training
    final input =
        info
            .quantized // 3. shape [1, 224, 224, 3]
        ? toUint8Tensor(square).buffer
        : toFloatTensor(square).buffer;
    final output = _newOutput(); // 4. shape [1, classes]
    _interpreter.run(input, output);
    return pairAndSort(labels, _scores(output)); // 5. pair, then sort
  }

  @override
  Future<List<Prediction>> classifyInBackground(Uint8List bytes) async {
    final size = inputSize;
    final quantized = info.quantized;
    final input = await Isolate.run(() => _encodeInput((bytes, size, quantized)));
    final output = _newOutput();
    await _isolateInterpreter.run(input, output);
    return pairAndSort(labels, _scores(output));
  }

  ByteBuffer _newOutput() => info.quantized ? Uint8List(labels.length).buffer : Float32List(labels.length).buffer;

  /// The float model ends in a softmax, so its numbers already add up to 1.
  /// The quantized one returns 0…255 per class: divide by 255.
  List<double> _scores(ByteBuffer output) =>
      info.quantized ? [for (final v in output.asUint8List()) v / 255] : output.asFloat32List().toList();

  @override
  void close() {
    _isolateInterpreter.close();
    _interpreter.close();
  }
}
