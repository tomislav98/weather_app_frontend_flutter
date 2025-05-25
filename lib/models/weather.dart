import 'package:weather_app/models/hourly_weather.dart' show HourlyWeather;

class Weather {
  final String locationName;
  final double currentTemperature;
  final String conditionText;
  final double windSpeed;
  final String windDir;
  final int humidity;
  final List<HourlyWeather> hourly;
  final double feelslike_c;
  final double uv;
  const Weather({
    required this.locationName,
    required this.currentTemperature,
    required this.conditionText,
    required this.windSpeed,
    required this.windDir,
    required this.humidity,
    required this.hourly,
    required this.feelslike_c,
    required this.uv,
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
      windDir: weatherJson['current']['wind_dir'],
      humidity: weatherJson['current']['humidity'],
      hourly: hourlyWeatherList,
      feelslike_c: (weatherJson['current']['feelslike_c'] as num).toDouble(),
      uv: (weatherJson['current']['uv'] as num).toDouble(),
    );
  }
}

List<Weather> parseHourlyWeather(Map<String, dynamic> json) {
  final List<dynamic> list = json['list'];
  return list.map((item) => Weather.fromJson(item)).toList();
}
