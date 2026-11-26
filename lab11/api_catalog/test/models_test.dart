import 'dart:convert';
import 'dart:io';

import 'package:api_catalog/models/product.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Product.fromJson parses the saved response', () {
    final json = jsonDecode(
      File('test/fixtures/product.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    final product = Product.fromJson(json);

    expect(product.title, 'Essence Mascara Lash Princess');
    expect(product.price, isA<double>());
    expect(product.price, 9.99);
    expect(product.tags, ['beauty', 'mascara']);
    expect(product.reviews, hasLength(3));
    expect(product.dimensions.width, 15.14);
  });

  test('missing brand is null, missing tags become an empty list', () {
    final product = Product.fromJson({
      'id': 7,
      'title': 'Plain box',
      'description': 'A box.',
      'price': 10, // an int on purpose
      'rating': 4,
      'thumbnail': 'https://example.com/t.png',
      'images': <String>[],
      'dimensions': {'width': 1, 'height': 2, 'depth': 3},
      'reviews': <Map<String, dynamic>>[],
    });

    expect(product.brand, isNull);
    expect(product.tags, isEmpty);
    expect(product.price, 10.0);
  });
}
