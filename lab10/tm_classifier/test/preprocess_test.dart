import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:tm_classifier/services/classifier.dart';

void main() {
  // A 300 × 100 picture: red on the left third, green in the middle, blue on
  // the right. The centre-square crop must keep only the green part.
  img.Image stripes() {
    final image = img.Image(width: 300, height: 100);
    for (var y = 0; y < 100; y++) {
      for (var x = 0; x < 300; x++) {
        final c = x < 100 ? [255, 0, 0] : (x < 200 ? [0, 255, 0] : [0, 0, 255]);
        image.setPixelRgb(x, y, c[0], c[1], c[2]);
      }
    }
    return image;
  }

  test('prepareImage crops the centre square and resizes it', () {
    final square = prepareImage(img.encodePng(stripes()), 224);
    expect(square.width, 224);
    expect(square.height, 224);
    final p = square.getPixel(112, 112);
    expect([p.r, p.g, p.b], [0, 255, 0]);
  });

  test('toFloatTensor has 224 * 224 * 3 values between -1 and 1', () {
    final tensor = toFloatTensor(prepareImage(img.encodePng(stripes()), 224));
    expect(tensor.length, 224 * 224 * 3);
    expect(tensor.every((v) => v >= -1 && v <= 1), isTrue);
    expect(tensor.sublist(0, 3), [-1.0, 1.0, -1.0]); // green: r=0, g=255, b=0
  });

  test('toUint8Tensor keeps the raw channels for the quantized model', () {
    final tensor = toUint8Tensor(prepareImage(img.encodePng(stripes()), 224));
    expect(tensor.sublist(0, 3), [0, 255, 0]);
  });

  test('bytes of a text file end in a FormatException, not a crash', () {
    expect(() => prepareImage(utf8.encode('just some text'), 224), throwsFormatException);
  });

  test('pairAndSort pairs index i with label i before sorting', () {
    final result = pairAndSort(['Mug', 'Bottle', 'Keys'], [0.2, 0.7, 0.1]);
    expect(result.map((p) => p.label), ['Bottle', 'Mug', 'Keys']);
    expect(result.first.percent, '70.0 %');
  });
}
