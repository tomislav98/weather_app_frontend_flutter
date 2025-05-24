class HourlyWeather {
  final DateTime dateTime;
  final double temperature;
  final String description;
  final String icon;
  final int code;
  HourlyWeather({
    required this.dateTime,
    required this.temperature,
    required this.description,
    required this.icon,
    required this.code,
  });

  factory HourlyWeather.fromJson(Map<String, dynamic> json) {
    return HourlyWeather(
      dateTime: DateTime.fromMillisecondsSinceEpoch(
        (json['time_epoch'] as int) * 1000,
      ),
      temperature: (json['temp_c'] as num).toDouble(),
      description: json['condition']['text'],
      icon: json['condition']['icon'],
      code: json['condition']['code'],
    );
  }
}
