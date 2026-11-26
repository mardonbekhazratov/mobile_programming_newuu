import 'package:api_catalog/data/product_api.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_api.dart';

void main() {
  test('getProducts returns the product in the page', () async {
    final page = await fakeApi(pageBody()).getProducts();

    expect(page.products, hasLength(1));
    expect(page.products.single.title, 'Essence Mascara Lash Princess');
  });

  test('getProduct throws ApiException on 404', () async {
    final api = fakeApi(
      '{"message":"Product with id \'0\' not found"}',
      status: 404,
    );

    await expectLater(api.getProduct(0), throwsA(isA<ApiException>()));
  });
}
