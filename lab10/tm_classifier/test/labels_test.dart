import 'package:flutter_test/flutter_test.dart';
import 'package:tm_classifier/services/classifier.dart';

void main() {
  test('parseLabels strips the index from each line', () {
    expect(parseLabels('0 Mug\n1 Bottle\n'), ['Mug', 'Bottle']);
  });

  test('parseLabels copes with CRLF, a trailing blank line and spaces', () {
    const raw = '0 Mug\r\n1 Bottle\r\n2 Car keys\r\n\r\n';
    expect(parseLabels(raw), ['Mug', 'Bottle', 'Car keys']);
  });

  test('parseLabels keeps digits that belong to the label', () {
    expect(parseLabels('0 7Up can\n1 2 pens\n'), ['7Up can', '2 pens']);
  });
}
