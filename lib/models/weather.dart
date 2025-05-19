import 'package:weather_app/models/hourly_weather.dart' show HourlyWeather;

class Weather {
  final String locationName;
  final double currentTemperature;
  final String conditionText;
  final double windSpeed;
  final int humidity;
  final List<HourlyWeather> hourly;

  const Weather({
    required this.locationName,
    required this.currentTemperature,
    required this.conditionText,
    required this.windSpeed,
    required this.humidity,
    required this.hourly,
  });

  factory Weather.fromJson(Map<String, dynamic> weatherJson) {
    final List<dynamic> hoursJson =
        weatherJson['forecast']['forecastday'][0]['hour'];

    final List<HourlyWeather> hourlyWeatherList =
        hoursJson.map((hourJson) => HourlyWeather.fromJson(hourJson)).toList();

    return Weather(
      locationName: weatherJson['location']['name'],
      currentTemperature: (weatherJson['current']['temp_c'] as num).toDouble(),
      conditionText: weatherJson['current']['condition']['text'],
      windSpeed: (weatherJson['current']['wind_kph'] as num).toDouble(),
      humidity: weatherJson['current']['humidity'],
      hourly: hourlyWeatherList,
    );
  }
}

List<Weather> parseHourlyWeather(Map<String, dynamic> json) {
  final List<dynamic> list = json['list'];
  return list.map((item) => Weather.fromJson(item)).toList();
}
