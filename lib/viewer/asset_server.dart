import 'dart:io';

import 'package:flutter/services.dart';

/// A tiny web server on the phone itself (127.0.0.1 only) that hands the 3D
/// viewer its files: the page from the app's assets, the models from the
/// downloaded 3D pack.
///
/// The viewer uses JavaScript modules, which a WebView only runs when the page
/// comes from a server. Nothing leaves the phone: the server is bound to the
/// loopback address and only serves files that are inside the app.
class AssetServer {
  AssetServer({required this.modelsPath});

  /// Folder of the 3D pack with male/ and female/ inside.
  final String modelsPath;

  HttpServer? _server;

  bool get running => _server != null;

  /// Starts the server and returns the address of the viewer page.
  Future<Uri> start() async {
    final existing = _server;
    if (existing != null) {
      return Uri.parse('http://127.0.0.1:${existing.port}/index.html');
    }
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _server = server;
    server.listen(_handle, onError: (_) {});
    return Uri.parse('http://127.0.0.1:${server.port}/index.html');
  }

  Future<void> stop() async {
    final server = _server;
    _server = null;
    await server?.close(force: true);
  }

  Future<void> _handle(HttpRequest request) async {
    final response = request.response;
    try {
      var path = Uri.decodeComponent(request.uri.path);
      if (path.isEmpty || path == '/') path = '/index.html';
      if (path.contains('..') || path.contains('\\')) {
        response.statusCode = HttpStatus.notFound;
        await response.close();
        return;
      }
      List<int> bytes;
      if (path.startsWith('/models/')) {
        bytes = await File('$modelsPath${path.substring('/models'.length)}')
            .readAsBytes();
      } else {
        final data = await rootBundle.load('assets/web$path');
        bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      }
      response.headers.contentType = _typeOf(path);
      response.headers.set(HttpHeaders.cacheControlHeader, 'no-store');
      response.contentLength = bytes.length;
      response.add(bytes);
    } catch (_) {
      response.statusCode = HttpStatus.notFound;
    }
    try {
      await response.close();
    } catch (_) {
      // The page went away; nothing to do.
    }
  }

  static ContentType _typeOf(String path) {
    if (path.endsWith('.html')) return ContentType.html;
    if (path.endsWith('.js')) {
      return ContentType('text', 'javascript', charset: 'utf-8');
    }
    if (path.endsWith('.json')) return ContentType.json;
    return ContentType.binary;
  }
}
