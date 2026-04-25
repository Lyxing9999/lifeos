import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  Env._();

  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? '';

  static String get googleMapsApiKey => dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
}
