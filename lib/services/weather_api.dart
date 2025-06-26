import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather.dart';
import 'package:weather_app/config.dart' show WEATHER_API_KEY;
import 'package:weather_app/utils/logger.dart';
import 'dart:io';

Future<void> logWeatherData(String responseBody) async {
  final data = jsonDecode(responseBody) as Map<String, dynamic>;
  final logEntry = 'weather_data: ${jsonEncode(data)}\n';

  final logFile = File('weather_log.txt');
  await logFile.writeAsString(logEntry, mode: FileMode.append);
}

Future<Weather> fetchWeatherData(String city) async {
  //appLogger.i('Fetching weather data for $city');
  final response = await http.get(
    Uri.parse(
      'https://api.weatherapi.com/v1/forecast.json?key=$WEATHER_API_KEY&q=$city&days=3',
    ),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final formattedJson = const JsonEncoder.withIndent('  ').convert(data);
    //appLogger.i('Weather API response:\n$formattedJson');
    return Weather.fromJson(data);
  } else {
    //appLogger.e('Failed with status: ${response.statusCode}');
    throw Exception('Failed to load weather data.');
  }
}

/*
  get the most recent city that would be displayed
  on the main page
*/
Future<String> getMostRecentCity() async {
  final prefs = await SharedPreferences.getInstance();
  String savedCities = prefs.getString('selectedCity') ?? 'Vatican';
  return savedCities;
}

/*
  set the user last selected city
*/
Future<void> setMostRecentCity(String city) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('selectedCity', city);
}

Future<List<String>> fetchRadarTimestamps() async {
  final url = Uri.parse('https://api.rainviewer.com/public/weather-maps.json');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final frames = data['radar']['past'] as List;
    return frames.map((frame) => frame['time'].toString()).toList();
  } else {
    throw Exception('Failed to fetch RainViewer radar data');
  }
}
