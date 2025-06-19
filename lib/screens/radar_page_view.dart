import 'dart:async' show Timer;

import 'package:flutter/material.dart';
import '../services/weather_api.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class RadarPageView extends StatefulWidget {
  const RadarPageView({super.key});

  @override
  State<RadarPageView> createState() => _RadarPageView();
}

class _RadarPageView extends State<RadarPageView> {
  List<String> timestamps = [];
  String currentFrame = '';
  Timer? animationTimer;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchRadarTimestamps().then((frames) {
      setState(() {
        timestamps = frames;
        if (timestamps.isNotEmpty) {
          currentFrame = timestamps[0];
        }
      });
      startAnimation();
    });
  }

  void startAnimation() {
    animationTimer = Timer.periodic(Duration(seconds: 3), (_) {
      if (timestamps.isEmpty) return;

      setState(() {
        currentIndex = (currentIndex + 1) % timestamps.length;
        currentFrame = timestamps[currentIndex];
      });
    });
  }

  @override
  void dispose() {
    animationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(51.509364, -0.128928),
              initialZoom: 3.2,
            ),
            children: [
              // base map
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.radar',
              ),
              if (currentFrame.isNotEmpty)
                // rain weather
                TileLayer(
                  urlTemplate:
                      'https://tilecache.rainviewer.com/v2/radar/$currentFrame/256/{z}/{x}/{y}/2/1_1.png',
                  tileProvider: NetworkTileProvider(),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
