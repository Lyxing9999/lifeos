import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  final SharedPreferences prefs;

  const LocalStorageService(this.prefs);

  Future<bool> setString(String key, String value) async {
    return prefs.setString(key, value);
  }

  String? getString(String key) {
    return prefs.getString(key);
  }

  Future<bool> remove(String key) async {
    return prefs.remove(key);
  }
}
