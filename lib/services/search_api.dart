// GET http://api.weatherapi.com/v1/search.json?key=YOUR_API_KEY&q=paris
import 'dart:convert' show jsonDecode;

import 'package:weather_app/config.dart' show WEATHER_API_KEY;
import 'package:http/http.dart' as http;

Future<List<dynamic>> searchCity(String query) async {
  final response = await http.get(
    Uri.parse(
      'http://api.weatherapi.com/v1/search.json?key=$WEATHER_API_KEY&q=$query',
    ),
  );
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to load data');
  }
}
