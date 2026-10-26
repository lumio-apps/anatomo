import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../update_service.dart';

/// Version of the 3D models this app expects. It is the number in the
/// GitHub release `pack-<version>` that holds them (see pack.yml).
const int kPackVersion = 1;
const String kPackTag = 'pack-$kPackVersion';
const String kPackIndex = 'anatomo-3d-pack.json';

/// Download size of the pack in MB (the files are gzip-compressed).
const int kPackSizeMb = 68;

enum PackState { checking, missing, downloading, ready, failed }

/// The optional 3D pack: the 3D models, downloaded once from the app's GitHub
/// release and kept in the app's own folder. Without it the app shows the 2D
/// pictures, which are always inside the app.
class Pack3D extends ChangeNotifier {
  Pack3D._();

  static final Pack3D instance = Pack3D._();

  /// The 3D view runs in a WebView, which Anatomo has on Android only.
  static bool get supported => !kIsWeb && Platform.isAndroid;

  PackState _state = PackState.checking;
  double _progress = 0;
  int _sizeMb = 0;
  Directory? _dir;
  bool _started = false;
  http.Client? _client;

  PackState get state => _state;
  double get progress => _progress;
  bool get ready => _state == PackState.ready;

  /// Size of the download in MB, once known (0 before).
  int get sizeMb => _sizeMb;

  /// Folder with male/ and female/ inside, when the pack is ready.
  String? get modelsPath => ready ? '${_dir!.path}/models' : null;

  Future<Directory> _root() async => getApplicationSupportDirectory();

  Future<void> init() async {
    if (_started) return;
    _started = true;
    if (!supported) {
      _set(PackState.missing);
      return;
    }
    try {
      final root = await _root();
      final dir = Directory('${root.path}/pack3d-v$kPackVersion');
      _dir = dir;
      final ok = File('${dir.path}/ready.json');
      _set(await ok.exists() ? PackState.ready : PackState.missing);
      // Packs of older app versions are not needed any more.
      await for (final e in root.list()) {
        final name = e.path.split(Platform.pathSeparator).last;
        if (e is Directory &&
            name.startsWith('pack3d-') &&
            name != 'pack3d-v$kPackVersion') {
          await e.delete(recursive: true);
        }
      }
    } catch (_) {
      _set(PackState.missing);
    }
  }

  void _set(PackState s) {
    _state = s;
    notifyListeners();
  }

  static Uri _asset(String name) => Uri.https(
        'github.com',
        '/$kGithubOwner/$kGithubRepo/releases/download/$kPackTag/$name',
      );

  /// Downloads the pack. Progress goes from 0 to 1.
  Future<void> download() async {
    if (!supported || _state == PackState.downloading || ready) return;
    _progress = 0;
    _set(PackState.downloading);
    final client = http.Client();
    _client = client;
    Directory? tmp;
    try {
      final root = await _root();
      final dir = Directory('${root.path}/pack3d-v$kPackVersion');
      tmp = Directory('${root.path}/pack3d-download');
      if (await tmp.exists()) await tmp.delete(recursive: true);
      final res = await client.get(_asset(kPackIndex)).timeout(const Duration(seconds: 30));
      if (res.statusCode != 200) {
        throw HttpException('GitHub returned ${res.statusCode}');
      }
      final index = jsonDecode(res.body) as Map<String, dynamic>;
      final files = (index['files'] as List).cast<Map<String, dynamic>>();
      final total = files.fold<int>(0, (n, f) => n + (f['size'] as int));
      _sizeMb = (total / (1024 * 1024)).round();
      var done = 0;
      for (final f in files) {
        final name = f['name'] as String;
        final path = f['path'] as String;
        if (path.contains('..') || path.startsWith('/') || path.contains('\\')) {
          throw const FormatException('Bad file name in the 3D pack');
        }
        final file = File('${tmp.path}/models/$path');
        await file.parent.create(recursive: true);
        final req = await client.send(http.Request('GET', _asset(name)));
        if (req.statusCode != 200) {
          throw HttpException('Download failed (${req.statusCode})');
        }
        // The files are stored gzip-compressed in the release.
        var got = 0;
        final counted = req.stream.map((chunk) {
          got += chunk.length;
          final p = total > 0 ? (done + got) / total : 0.0;
          if (p - _progress >= 0.005) {
            _progress = p;
            notifyListeners();
          }
          return chunk;
        });
        await counted.transform(gzip.decoder).pipe(file.openWrite());
        if (got != f['size'] || await file.length() != f['raw']) {
          throw const HttpException('Download was not complete');
        }
        done += got;
      }
      await File('${tmp.path}/ready.json').writeAsString(
        jsonEncode({'version': kPackVersion, 'files': files.length}),
        flush: true,
      );
      if (await dir.exists()) await dir.delete(recursive: true);
      await tmp.rename(dir.path);
      _dir = dir;
      _progress = 1;
      _set(PackState.ready);
    } catch (_) {
      try {
        final t = tmp;
        if (t != null && await t.exists()) await t.delete(recursive: true);
      } catch (_) {
        // A half download is cleaned up on the next try.
      }
      _set(_cancelled ? PackState.missing : PackState.failed);
    } finally {
      _cancelled = false;
      _client = null;
      client.close();
    }
  }

  bool _cancelled = false;

  void cancel() {
    if (_state != PackState.downloading) return;
    _cancelled = true;
    _client?.close();
  }

  /// Deletes the pack (to free space).
  Future<void> remove() async {
    final dir = _dir;
    if (dir == null) return;
    try {
      if (await dir.exists()) await dir.delete(recursive: true);
    } catch (_) {
      // Removing is best effort.
    }
    _set(PackState.missing);
  }
}
