import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
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
    throw Exception('Failed to load weather data.');
  }
}

/*
  Save the cities in the list
  the cites that was selected by user
*/
void saveTheCities(String city) async {
  final prefs = await SharedPreferences.getInstance();
  // set the list
  List<String> savedCities = prefs.getStringList('savedCities') ?? [];
  if (!savedCities.contains(city)) {
    savedCities.add(city);
    await prefs.setStringList('savedCities', savedCities);
  }
}

/*
  Get all the cites user selected
*/
Future<List<String>> getSavedCities() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getStringList('savedCities') ?? ['Vatican'];
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
