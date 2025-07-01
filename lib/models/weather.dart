import 'package:weather_app/models/hourly_weather.dart' show HourlyWeather;

class Weather {
  final String country;
  final String locationName;
  final double currentTemperature;
  final String conditionText;
  final double windSpeed;
  final String windDir;
  final int humidity;
  final List<HourlyWeather> hourly;
  final double feelslike_c;
  final double uv;
  final String sunrise;
  final String sunset;
  final int code;
  final double maxTempC;

  const Weather({
    required this.country,
    required this.locationName,
    required this.currentTemperature,
    required this.conditionText,
    required this.windSpeed,
    required this.windDir,
    required this.humidity,
    required this.hourly,
    required this.feelslike_c,
    required this.uv,
    required this.sunrise,
    required this.sunset,
    required this.code,
    required this.maxTempC,
  });

  factory Weather.fromJson(Map<String, dynamic> weatherJson) {
    final List<dynamic> hoursJson =
        weatherJson['forecast']['forecastday'][0]['hour'];

    final List<HourlyWeather> hourlyWeatherList =
        hoursJson.map((hourJson) => HourlyWeather.fromJson(hourJson)).toList();

    return Weather(
      country:
          weatherJson['location']['country'].toString().trim().toLowerCase(),
      locationName: weatherJson['location']['name'],
      currentTemperature: (weatherJson['current']['temp_c'] as num).toDouble(),
      conditionText:
          weatherJson['current']['condition']['text']
              .toString()
              .trim()
              .toLowerCase(),
      windSpeed: (weatherJson['current']['wind_kph'] as num).toDouble(),
      windDir: weatherJson['current']['wind_dir'],
      humidity: weatherJson['current']['humidity'],
      hourly: hourlyWeatherList,
      feelslike_c: (weatherJson['current']['feelslike_c'] as num).toDouble(),
      uv: (weatherJson['current']['uv'] as num).toDouble(),
      sunrise: (weatherJson['forecast']['forecastday'][0]['astro']['sunrise']),
      sunset: (weatherJson['forecast']['forecastday'][0]['astro']['sunset']),
      code: (weatherJson['current']['condition']['code'] as num).toInt(),
      maxTempC:
          (weatherJson['forecast']['forecastday'][0]['day']['maxtemp_c'] as num)
              .toDouble(),
    );
  }
}

List<Weather> parseHourlyWeather(Map<String, dynamic> json) {
  final List<dynamic> list = json['list'];
  return list.map((item) => Weather.fromJson(item)).toList();
}
