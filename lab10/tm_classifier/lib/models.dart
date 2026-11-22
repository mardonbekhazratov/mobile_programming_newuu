import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'services/classifier.dart';

enum ImageOrigin {
  camera('Camera', Icons.photo_camera_outlined),
  gallery('Gallery', Icons.photo_library_outlined),
  download('Download', Icons.link),
  sample('Sample', Icons.science_outlined);

  const ImageOrigin(this.label, this.icon);
  final String label;
  final IconData icon;
}

class ClassificationRecord {
  ClassificationRecord(this.bytes, this.predictions, this.origin, this.elapsed) : time = DateTime.now();
  final Uint8List bytes;
  final List<Prediction> predictions; // sorted, highest first
  final ImageOrigin origin;
  final Duration elapsed;
  final DateTime time;

  Prediction get top => predictions.first;
}

/// Session history, newest first.
class History extends ChangeNotifier {
  final List<ClassificationRecord> _items = [];
  List<ClassificationRecord> get items => List.unmodifiable(_items);
  ClassificationRecord? get latest => _items.isEmpty ? null : _items.first;

  void add(ClassificationRecord r) {
    _items.insert(0, r);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
