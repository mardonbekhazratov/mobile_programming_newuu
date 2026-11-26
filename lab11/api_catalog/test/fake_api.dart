import 'dart:convert';
import 'dart:io';

import 'package:api_catalog/data/product_api.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// The saved fixture wrapped in a one-product page.
String pageBody() => jsonEncode({
  'products': [
    jsonDecode(File('test/fixtures/product.json').readAsStringSync()),
  ],
  'total': 1,
  'skip': 0,
  'limit': 20,
});

/// A [ProductApi] whose client always answers with [body] and [status].
ProductApi fakeApi(String body, {int status = 200}) => ProductApi(
  client: MockClient(
    (_) async => http.Response(
      body,
      status,
      headers: {'content-type': 'application/json; charset=utf-8'},
    ),
  ),
);
