import 'package:core/core.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// [KeyValueStore] backed by `shared_preferences`.
class SharedPrefsKeyValueStore implements KeyValueStore {
  SharedPrefsKeyValueStore(this._prefs);

  final SharedPreferences _prefs;

  @override
  Future<String?> read(String key) async => _prefs.getString(key);

  @override
  Future<bool> write(String key, String value) => _prefs.setString(key, value);

  @override
  Future<bool> delete(String key) => _prefs.remove(key);
}
