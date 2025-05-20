import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather.dart';
import 'package:weather_app/config.dart' show WEATHER_API_KEY;

Future<Weather> fetchWeatherData(String city) async {
  final response = await http.get(
    Uri.parse(
      'https://api.weatherapi.com/v1/forecast.json?key=${WEATHER_API_KEY}&q=$city&days=3',
    ),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return Weather.fromJson(data);
  } else {
    print(response.body);
    throw Exception('Failed to load weather data.');
  }
}
