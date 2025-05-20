import 'package:flutter_dotenv/flutter_dotenv.dart';

class Config {
  static String get apiKey => dotenv.env['API_KEY'] ?? '';
}

final String WEATHER_API_KEY = Config.apiKey;
