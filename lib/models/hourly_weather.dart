class HourlyWeather {
  final DateTime dateTime;
  final double temperature;
  final String description;
  final String icon;
  final int code;
  final int chanceOfRain;
  HourlyWeather({
    required this.dateTime,
    required this.temperature,
    required this.description,
    required this.icon,
    required this.code,
    required this.chanceOfRain,
  });

  factory HourlyWeather.fromJson(Map<String, dynamic> json) {
    return HourlyWeather(
      dateTime: DateTime.fromMillisecondsSinceEpoch(
        (json['time_epoch'] as int) * 1000,
      ),
      temperature: (json['temp_c'] as num).toDouble(),
      description: json['condition']['text'].toString().trim().toLowerCase(),
      icon: json['condition']['icon'],
      code: json['condition']['code'],
      chanceOfRain: json['chance_of_rain'] as int,
    );
  }
}
