import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../models/hourly_weather.dart';
import '../utils/weather_icon_mapper.dart';

class FlippableHourlyCard extends StatefulWidget {
  final List<HourlyWeather> hour;

  const FlippableHourlyCard({super.key, required this.hour});

  @override
  State<FlippableHourlyCard> createState() => _FlippableHourlyCardState();
}

class _FlippableHourlyCardState extends State<FlippableHourlyCard> {
  bool _isFlipped = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _isFlipped = !_isFlipped),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (child, animation) {
          final rotate = Tween(begin: pi, end: 0.0).animate(animation);
          return AnimatedBuilder(
            animation: rotate,
            child: child,
            builder: (context, child) {
              final isUnder = (ValueKey(_isFlipped) != child!.key);
              var tilt = ((animation.value - 0.5).abs() - 0.5) * 0.003;
              tilt *= isUnder ? -1.0 : 1.0;
              final value = isUnder ? min(rotate.value, pi / 2) : rotate.value;
              return Transform(
                transform: Matrix4.rotationY(value)..setEntry(3, 0, tilt),
                alignment: Alignment.center,
                child: child,
              );
            },
          );
        },
        layoutBuilder: (widget, list) => Stack(children: [widget!, ...list]),
        switchInCurve: Curves.easeInBack,
        switchOutCurve: Curves.easeOutBack,
        child: _isFlipped ? _buildBack(widget.hour) : _buildFront(widget.hour),
      ),
    );
  }

  Widget _buildFront(List<HourlyWeather> hourly) {
    return SizedBox(
      height: 140,
      width: MediaQuery.of(context).size.width * 0.9,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: hourly.length,
        itemBuilder: (context, index) {
          final hour = hourly[index];
          return Card(
            key: const ValueKey(true),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 8),
            color: Theme.of(context).cardColor,
            child: Container(
              width: 80,
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${hour.dateTime.hour}:00',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 50,
                    height: 50,
                    child: Lottie.asset(
                      getWeatherIconForCode(hour.description),
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${hour.temperature}°C',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBack(List<HourlyWeather> hourly) {
    return SizedBox(
      height: 140, // Set desired height
      width: MediaQuery.of(context).size.width * 0.9,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: hourly.length,
        itemBuilder: (context, index) {
          final hour = hourly[index];
          return Card(
            key: ValueKey('back_$index'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 8),
            color: Theme.of(context).cardColor,
            child: Container(
              width: 80,
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${hour.dateTime.hour}:00',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 50,
                    height: 50,
                    child: Lottie.asset(
                      getWeatherIconForCode('umbrella'),
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${hour.chanceOfRain}%',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
