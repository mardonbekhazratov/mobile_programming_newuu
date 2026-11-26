import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product.dart';
import '../models/product_page.dart';

class ApiException implements Exception {
  const ApiException(this.message);
  final String message;
  @override
  String toString() => message;
}

class ProductApi {
  ProductApi({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;
  static const _host = 'dummyjson.com';

  Future<ProductPage> getProducts({int limit = 20, int skip = 0}) async {
    final uri = Uri.https(_host, '/products', {
      'limit': '$limit',
      'skip': '$skip',
    });
    return ProductPage.fromJson(await _get(uri));
  }

  Future<Product> getProduct(int id) async {
    final uri = Uri.https(_host, '/products/$id');
    return Product.fromJson(await _get(uri));
  }

  Future<ProductPage> search(String query) async {
    final uri = Uri.https(_host, '/products/search', {'q': query});
    return ProductPage.fromJson(await _get(uri));
  }

  Future<Map<String, dynamic>> _get(Uri uri) async {
    final http.Response response;
    try {
      response = await _client.get(uri).timeout(const Duration(seconds: 10));
    } on TimeoutException {
      throw const ApiException(
        'The server is taking too long to answer. Please try again.',
      );
    } on http.ClientException {
      throw const ApiException(
        'No internet connection. Check your network and try again.',
      );
    }
    if (response.statusCode != 200) {
      throw ApiException('Server answered ${response.statusCode}');
    }
    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } on FormatException {
      throw const ApiException('The server sent data the app could not read.');
    }
  }
}
