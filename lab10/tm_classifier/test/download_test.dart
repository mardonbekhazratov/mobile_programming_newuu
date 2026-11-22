import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tm_classifier/services/image_sources.dart';

void main() {
  ImageSources with_(http.Response r) => ImageSources(client: MockClient((_) async => r));
  final fails = throwsA(isA<SourceException>());

  test('200 + image/* gives the bytes', () async {
    final s = with_(http.Response.bytes([1, 2, 3], 200, headers: {'content-type': 'image/png'}));
    expect(await s.fromUrl('https://x.test/a.png'), [1, 2, 3]);
  });

  test('404, a web page, a bad address and a timeout each fail politely', () async {
    expect(with_(http.Response('', 404, headers: {'content-type': 'image/png'})).fromUrl('https://x.test/a'), fails);
    expect(with_(http.Response('<html>', 200, headers: {'content-type': 'text/html'})).fromUrl('https://x.test'), fails);
    expect(with_(http.Response('', 200)).fromUrl('not a url'), fails);
    final slow = ImageSources(
      client: MockClient((_) => Completer<http.Response>().future),
      timeout: const Duration(milliseconds: 10),
    );
    expect(slow.fromUrl('https://x.test/a.png'), fails);
  });
}
