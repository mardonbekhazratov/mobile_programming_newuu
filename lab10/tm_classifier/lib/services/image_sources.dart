import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

/// A failure with a message that can go straight on screen.
class SourceException implements Exception {
  const SourceException(this.message);
  final String message;
  @override
  String toString() => message;
}

class ImageSources {
  ImageSources({http.Client? client, this.timeout = const Duration(seconds: 15)}) : _client = client ?? http.Client();

  final _picker = ImagePicker();
  final http.Client _client;
  final Duration timeout;

  /// null = the user cancelled.
  Future<Uint8List?> fromCamera() => _pick(ImageSource.camera);
  Future<Uint8List?> fromGallery() => _pick(ImageSource.gallery);

  Future<Uint8List?> _pick(ImageSource source) async {
    final shot = await _picker.pickImage(source: source, maxWidth: 1024);
    return shot == null ? null : await shot.readAsBytes();
  }

  Future<Uint8List> fromUrl(String url) async {
    final uri = Uri.tryParse(url.trim());
    if (uri == null || !uri.hasScheme || !uri.scheme.startsWith('http') || uri.host.isEmpty) {
      throw const SourceException('That is not a web address. It must start with https://');
    }
    final http.Response response;
    try {
      response = await _client.get(uri).timeout(timeout);
    } on TimeoutException {
      throw SourceException('No answer within ${timeout.inSeconds} s. Try again or use another address.');
    } on SocketException {
      throw const SourceException('No connection. Check Wi-Fi or mobile data.');
    } on http.ClientException catch (e) {
      throw SourceException('Download failed: ${e.message}');
    } on HandshakeException {
      throw const SourceException('Secure connection failed.');
    }
    if (response.statusCode != 200) {
      throw SourceException('The server answered ${response.statusCode} instead of an image.');
    }
    final type = response.headers['content-type'] ?? '';
    if (!type.startsWith('image/')) {
      throw SourceException(
        'That address is ${type.isEmpty ? 'not an image' : '"$type"'}, not a picture. '
        'Copy the image address, not the page address.',
      );
    }
    return response.bodyBytes;
  }
}
