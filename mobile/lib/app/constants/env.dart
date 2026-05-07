import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  Env._();

  static String get baseUrl => _value('API_BASE_URL');
  static String get apiBaseUrl => baseUrl;

  static String get googleMapsApiKey => _value('GOOGLE_MAPS_API_KEY');

  static String get googleServerClientId => _value('GOOGLE_SERVER_CLIENT_ID');

  static String get appTimezone => _value('APP_TIMEZONE');

  static String _value(String key) {
    if (!dotenv.isInitialized) return '';
    return dotenv.env[key] ?? '';
  }
}
