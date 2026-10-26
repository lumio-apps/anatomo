import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// The layers of the 3D body that can be switched on and off.
const List<String> kLayers = [
  'organs',
  'bones',
  'muscles',
  'nerves',
  'vessels',
  'skin',
];

const Map<String, bool> kDefaultLayers = {
  'organs': true,
  'bones': true,
  'muscles': false,
  'nerves': false,
  'vessels': false,
  'skin': true,
};

/// Everything Anatomo remembers, saved as a small JSON file on the phone.
///
/// The keys in the file never change between versions, so an update keeps
/// the user's choices.
class AppSettings extends ChangeNotifier {
  AppSettings._(this._file);

  /// Used when the phone storage cannot be opened (and in tests).
  AppSettings.inMemory() : _file = null;

  final File? _file;

  String? _language;
  String _sex = 'male';
  bool _onboarded = false;
  final Map<String, bool> _layers = Map.of(kDefaultLayers);

  /// Language code chosen by the user, or null to follow the phone.
  String? get language => _language;
  String get sex => _sex;
  bool get onboarded => _onboarded;
  Map<String, bool> get layers => Map.unmodifiable(_layers);

  static Future<AppSettings> load() async {
    final dir = await getApplicationSupportDirectory();
    final settings = AppSettings._(File('${dir.path}/settings.json'));
    await settings._read();
    return settings;
  }

  Future<void> _read() async {
    final file = _file;
    if (file == null) return;
    try {
      if (!await file.exists()) return;
      final data = jsonDecode(await file.readAsString());
      if (data is! Map) return;
      final lang = data['language'];
      if (lang is String && lang.isNotEmpty) _language = lang;
      final sex = data['sex'];
      if (sex == 'male' || sex == 'female') _sex = sex as String;
      _onboarded = data['onboarded'] == true;
      final layers = data['layers'];
      if (layers is Map) {
        for (final layer in kLayers) {
          final v = layers[layer];
          if (v is bool) _layers[layer] = v;
        }
      }
    } catch (_) {
      // A broken file is ignored; the defaults are used.
    }
  }

  Future<void> _save() async {
    final file = _file;
    if (file == null) return;
    try {
      final tmp = File('${file.path}.tmp');
      await tmp.writeAsString(
        jsonEncode({
          'language': _language,
          'sex': _sex,
          'onboarded': _onboarded,
          'layers': _layers,
        }),
        flush: true,
      );
      await tmp.rename(file.path);
    } catch (_) {
      // Saving is best effort. The app keeps working without it.
    }
  }

  void setLanguage(String? code) {
    if (_language == code) return;
    _language = code;
    notifyListeners();
    _save();
  }

  void setSex(String sex) {
    if (_sex == sex || (sex != 'male' && sex != 'female')) return;
    _sex = sex;
    notifyListeners();
    _save();
  }

  void finishOnboarding() {
    if (_onboarded) return;
    _onboarded = true;
    notifyListeners();
    _save();
  }

  void setLayer(String layer, bool on) {
    if (!kLayers.contains(layer) || _layers[layer] == on) return;
    _layers[layer] = on;
    notifyListeners();
    _save();
  }

  /// Takes the layer state reported by the viewer (it may switch a layer on
  /// by itself when a hidden part is opened).
  void syncLayers(Map<String, bool> layers) {
    var changed = false;
    for (final layer in kLayers) {
      final v = layers[layer];
      if (v != null && _layers[layer] != v) {
        _layers[layer] = v;
        changed = true;
      }
    }
    if (!changed) return;
    notifyListeners();
    _save();
  }
}
