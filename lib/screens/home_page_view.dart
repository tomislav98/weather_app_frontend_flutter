import 'package:flutter/material.dart';
import '../models/weather.dart';
import '../services/weather_api.dart';
import 'package:lottie/lottie.dart';

class HomePageView extends StatefulWidget {
  const HomePageView({super.key});

  @override
  State<HomePageView> createState() => _HomePageViewState();
}

class _HomePageViewState extends State<HomePageView> {
  late Future<Weather> futureWeather;
  int _selectedIndex = 0;
  @override
  void initState() {
    super.initState();
    futureWeather = fetchWeatherData('Some city'); // !TODO
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _refresh() async {
    setState(() {
      futureWeather = fetchWeatherData('Some city'); // re-fetch data
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Weather"),
        backgroundColor: Colors.purple,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<Weather>(
          future: futureWeather,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Lottie.asset(
                  'assets/animations/loading/loading_indicator.json',
                  width: 150,
                  height: 150,
                ),
              );
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData) {
              return const Center(child: Text('No data available'));
            }

            final weather = snapshot.data!;

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  _buildMainWeatherInfo(weather),
                  _buildHourlyForecast(weather),
                  Container(color: Colors.amber, width: 300, height: 300),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.schedule), label: 'Hourly'),
          BottomNavigationBarItem(icon: Icon(Icons.date_range), label: 'Daily'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildMainWeatherInfo(Weather weather) {
    return Container(
      color: Colors.white,
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.19,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            weather.locationName,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "${weather.currentTemperature}°C",
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 18,
              fontWeight: FontWeight.normal,
            ),
          ),
          Text(
            weather.conditionText,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
          ),
        ],
      ),
    );
  }

  Widget _buildHourlyForecast(Weather weather) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9, // 90% of screen width
      height: MediaQuery.of(context).size.height * 0.19, // 20% of screen height
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            Colors.blueGrey.shade100, // or any color that contrasts with white
        borderRadius: BorderRadius.circular(16), // rounded corners
      ),
      child: SizedBox(
        height: 120,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: weather.hourly.length,
          itemBuilder: (context, index) {
            final hour = weather.hourly[index];
            return Container(
              width: 80,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('${hour.dateTime.hour}:00'),
                  Image.network('https:${hour.icon}'),
                  Text('${hour.temperature}°C'),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

final Map<int, IconData> weatherCodeToIcon = {
  1000: Icons.wb_sunny, // Sunny / Clear
  1003: Icons.wb_cloudy, // Partly Cloudy
  1006: Icons.cloud, // Cloudy
  1009: Icons.cloud_queue, // Overcast
  1030: Icons.blur_on, // Mist
  1063: Icons.grain, // Patchy rain
  1066: Icons.ac_unit, // Patchy snow
  1069: Icons.ac_unit, // Patchy sleet
  1072: Icons.ac_unit, // Freezing drizzle
  1087: Icons.flash_on, // Thunder
  1114: Icons.ac_unit, // Blowing snow
  1117: Icons.ac_unit, // Blizzard
  1135: Icons.foggy, // Fog (use custom if foggy isn't supported)
  1147: Icons.foggy, // Freezing fog
  1150: Icons.grain, // Light drizzle
  1153: Icons.grain,
  1168: Icons.grain,
  1171: Icons.grain,
  1180: Icons.grain,
  1183: Icons.grain,
  1186: Icons.grain,
  1189: Icons.grain,
  1192: Icons.grain,
  1195: Icons.grain,
  1198: Icons.ac_unit,
  1201: Icons.ac_unit,
  1204: Icons.ac_unit,
  1207: Icons.ac_unit,
  1210: Icons.ac_unit,
  1213: Icons.ac_unit,
  1216: Icons.ac_unit,
  1219: Icons.ac_unit,
  1222: Icons.ac_unit,
  1225: Icons.ac_unit,
  1237: Icons.ac_unit,
  1240: Icons.grain,
  1243: Icons.grain,
  1246: Icons.grain,
  1249: Icons.ac_unit,
  1252: Icons.ac_unit,
  1255: Icons.ac_unit,
  1258: Icons.ac_unit,
  1261: Icons.ac_unit,
  1264: Icons.ac_unit,
  1273: Icons.flash_on,
  1276: Icons.flash_on,
  1279: Icons.flash_on,
  1282: Icons.flash_on,
};
