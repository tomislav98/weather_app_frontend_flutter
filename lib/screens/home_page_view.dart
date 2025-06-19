import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart' show Geolocator;
import 'package:weather_app/db/sqflite_db.dart';
import 'package:weather_app/screens/city_selection_view.dart';
import '../models/weather.dart';
import '../services/weather_api.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:weather_app/screens/radar_page_view.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';

class HomePageView extends StatefulWidget {
  const HomePageView({super.key});

  @override
  State<HomePageView> createState() => _HomePageViewState();
}

class _HomePageViewState extends State<HomePageView> {
  Future<Placemark>? manageGPS;
  late Future<void> locationServiceDialog;
  final dbHelper = DatabaseHelper();
  List<String> savedCities = [];
  late PageController _pageController;

  Future<void> _showGpsDisableDialog(BuildContext context) async {
    bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // User must tap a button
      builder: (context) {
        return AlertDialog(
          title: Text('GPS is enabled'),
          content: Text('Would you like to disable GPS?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // User says NO
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // User says YES
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      // User wants to disable GPS
      // You can navigate them to settings or give instructions
      _openLocationSettings();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _openLocationSettings() {
    // Unfortunately, you cannot disable GPS programmatically for privacy reasons,
    // but you can open the location settings page for the user.

    Geolocator.openLocationSettings();
  }

  @override
  void initState() {
    super.initState();
    initialize();
    _pageController = PageController();
  }

  Future<void> initialize() async {
    final cities = await dbHelper.getAllCities();

    setState(() {
      savedCities = cities;
    });
  }

  Future<void> _refresh() async {
    // Step 1: Reload cities from the database
    final cities = await dbHelper.getAllCities();

    // Step 2: Optionally get the most recent one

    setState(() {
      // here is triggered FutureBuilder
      savedCities = cities;
    });
  }

  void _showBottomMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _bottomMenuItem(
                title: 'Select city',
                lottieAsset: 'assets/animations/weather-icons/lottie/city.json',
                onTap:
                    () => _navigateWithSlideTransition(
                      context,
                      const CitySelectionView(),
                    ),
              ),
              _bottomMenuItem(
                title: 'Radar',
                lottieAsset:
                    'assets/animations/weather-icons/lottie/compass.json',
                onTap:
                    () => _navigateWithSlideTransition(
                      context,
                      const RadarPageView(),
                    ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showBottomMenu(context),
            color: Colors.black, // Or any color you want for the icon
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: savedCities.length,
                itemBuilder: (context, index) {
                  return RefreshIndicator(
                    onRefresh: _refresh,
                    child: FutureBuilder<Weather>(
                      future: fetchWeatherData(savedCities[index]),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        } else if (!snapshot.hasData) {
                          return const Center(child: Text('No data available'));
                        }

                        final weather = snapshot.data!;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Center(child: _mainTitleWeatherInfo(weather)),

                              Center(child: _buildMainWeatherInfo(weather)),

                              Center(child: _buildThreeIcons(weather)),

                              _buildHourlyForecast(weather),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),

            // Fixed page indicator below the PageView
            // The SmoothPageIndicator needs to know the
            // current page index so it can highlight the correct dot.
            // Simple analogy:

            // Think of a controller as a remote control:
            // The remote controls the TV (view).
            // It sends commands to the TV to change the channel or volume.
            // It also receives feedback (current channel) so it can display
            //  the correct info on its screen.
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SmoothPageIndicator(
                controller: _pageController,
                count: savedCities.length,
                effect: WormEffect(
                  dotHeight: 12,
                  dotWidth: 12,
                  activeDotColor: Colors.blueAccent,
                  dotColor: Colors.grey.shade300,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mainTitleWeatherInfo(Weather weather) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height * 0.07,
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                weather.locationName,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.start,
              ),
              Text(
                DateFormat(
                  'EEEE, d MMMM',
                ).format(DateTime.now()), // Example: Monday, 17 June
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  color: Colors.grey, // or Colors.grey.shade600
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainWeatherInfo(Weather weather) {
    return Column(
      children: [
        Container(
          width: MediaQuery.sizeOf(context).width,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                Color(0xFF90CAF9), // light blue
                Color(0xFF42A5F5), // medium blue
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.5),
                offset: const Offset(0, 25),
                blurRadius: 10,
                spreadRadius: -12,
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: -40,
                left: 20,
                child: Lottie.asset(
                  getWeatherIconForCode(weather.conditionText),
                  width: 150,
                  height: 150,
                ),
              ),
              Positioned(
                bottom: 30,
                left: 20,
                child: Text(
                  weather.conditionText,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.normal,
                    color: Colors.white,
                  ),
                ),
              ),
              Positioned(
                top: 20,
                right: 20,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        "${weather.currentTemperature}",
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 50,
                          fontWeight: FontWeight.normal,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Text(
                      "°", // celsius
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildThreeIcons(Weather weather) {
    return Container(
      padding: EdgeInsets.all(30),
      width: MediaQuery.of(context).size.width * 0.9,

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Wind Speed',
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 10,
                  fontWeight: FontWeight.normal,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 5),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey.shade200,
                ),
                child: SizedBox(
                  width: 50,
                  height: 50,
                  child: Lottie.asset(
                    'assets/animations/weather-icons/lottie/wind.json',
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                  ),
                ),
              ),

              SizedBox(height: 5),
              Text(
                '${weather.windSpeed} km/h',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Humidity',
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 10,
                  fontWeight: FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 5),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey.shade200,
                ),
                child: SizedBox(
                  width: 50,
                  height: 50,

                  child: Lottie.asset(
                    'assets/animations/weather-icons/lottie/humidity.json',
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                  ),
                ),
              ),
              SizedBox(height: 5),
              Text(
                '${weather.humidity}',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.start,
              ),
            ],
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Max temp',
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 10,
                  fontWeight: FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 5),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey.shade200,
                ),
                child: SizedBox(
                  width: 50,
                  height: 50,
                  child: Lottie.asset(
                    'assets/animations/weather-icons/lottie/thermometer-celsius.json',
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                  ),
                ),
              ),
              SizedBox(height: 5),
              Text(
                '${weather.maxTempC} °C',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.start,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHourlyForecast(Weather weather) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Title bar: you can also use Card here if you want elevation
        Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.04,
          alignment: Alignment.centerLeft,
          child: Text(
            'Today',
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.start,
          ),
        ),

        //const SizedBox(height: 4),
        Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.20,
          padding: const EdgeInsets.all(16),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: weather.hourly.length,
            itemBuilder: (context, index) {
              final hour = weather.hourly[index];
              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 8),
                color: Colors.grey.shade200,

                child: Container(
                  width: 80,
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${hour.dateTime.hour}:00',
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                          color: Colors.black87,
                        ),
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
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _bottomMenuItem({
    required String title,
    required String lottieAsset,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Lottie.asset(
        lottieAsset,
        width: 40,
        height: 40,
        fit: BoxFit.contain,
        alignment: Alignment.center,
      ),
      title: Text(title),
      onTap: onTap,
    );
  }

  void _navigateWithSlideTransition(BuildContext context, Widget page) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 1000),
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.ease;
          final tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }
}

final Map<String, String> weatherCodeToLottie = {
  // ☀️ Clear / Sunny

  // 🌤️ Clouds / Fog / Haze
  "overcast": "assets/animations/weather-icons/lottie/overcast-haze.json",

  "freezing fog":
      "assets/animations/weather-icons/lottie/overcast-day-smoke.json",

  // 🌧️ Rain
  "patchy light rain":
      "assets/animations/weather-icons/lottie/overcast-drizzle.json",

  "torrential rain shower":
      "assets/animations/weather-icons/lottie/thunderstorms-day-overcast-rain.json",

  // ❄️ Snow
  "patchy light snow":
      "assets/animations/weather-icons/lottie/overcast-day-snow.json",
  "light snow": "assets/animations/weather-icons/lottie/overcast-day-snow.json",
  "moderate snow":
      "assets/animations/weather-icons/lottie/overcast-night-snow.json",
  "heavy snow":
      "assets/animations/weather-icons/lottie/overcast-night-overcast-snow.json",
  "blowing snow":
      "assets/animations/weather-icons/lottie/thunderstorms-night-overcast-snow.json",

  // 🌨️ Sleet
  "patchy sleet possible":
      "assets/animations/weather-icons/lottie/overcast-sleet.json",
  "light sleet":
      "assets/animations/weather-icons/lottie/overcast-day-sleet.json",
  "moderate or heavy sleet":
      "assets/animations/weather-icons/lottie/overcast-night-sleet.json",

  // 🌩️ Thunderstorms
  "moderate or heavy rain with thunder":
      "assets/animations/weather-icons/lottie/thunderstorms-overcast-rain.json",
  "patchy light rain with thunder":
      "assets/animations/weather-icons/lottie/thunderstorms-day-overcast-rain.json",
  "patchy light snow with thunder":
      "assets/animations/weather-icons/lottie/thunderstorms-day-overcast-snow.json",
  "moderate or heavy snow with thunder":
      "assets/animations/weather-icons/lottie/thunderstorms-night-overcast-snow.json",

  // 🧊 Hail / Ice
  "ice pellets":
      "assets/animations/weather-icons/lottie/overcast-day-hail.json",
  "light showers of ice pellets":
      "assets/animations/weather-icons/lottie/overcast-night-hail.json",
  "moderate or heavy showers of ice pellets":
      "assets/animations/weather-icons/lottie/overcast-hail.json",

  // 🌫️ Smoke / Dust
  "sandstorm":
      "assets/animations/weather-icons/lottie/overcast-night-smoke.json",

  // 🌈 Special
  "rainbow": "assets/animations/weather-icons/lottie/rainbow.json",
  "rainbow with sun":
      "assets/animations/weather-icons/lottie/rainbow-clear.json",

  "sunny": "assets/animations/weather-icons/lottie/clear-day.json",
  "clear": "assets/animations/weather-icons/lottie/clear-night.json",
  "cloudy": "assets/animations/weather-icons/lottie/cloudy.json",

  "partly cloudy":
      "assets/animations/weather-icons/lottie/partly-cloudy-day.json",
  "partly cloudy night":
      "assets/animations/weather-icons/lottie/partly-cloudy-night.json",
  "partly cloudy day":
      "assets/animations/weather-icons/lottie/partly-cloudy-day.json",
  "light rain": "assets/animations/weather-icons/lottie/rain.json",
  "moderate rain": "assets/animations/weather-icons/lottie/rain.json",
  "heavy rain": "assets/animations/weather-icons/lottie/rain.json",
  "patchy rain possible":
      "assets/animations/weather-icons/lottie/partly-cloudy-day-rain.json",
  "patchy rain nearby":
      "assets/animations/weather-icons/lottie/partly-cloudy-day-rain.json",
  "light drizzle": "assets/animations/weather-icons/lottie/drizzle.json",
  "patchy drizzle possible":
      "assets/animations/weather-icons/lottie/partly-cloudy-day-drizzle.json",
  "hail": "assets/animations/weather-icons/lottie/hail.json",
  "sleet":
      "assets/animations/weather-icons/lottie/partly-cloudy-day-sleet.json",
  "snow": "assets/animations/weather-icons/lottie/snow.json",
  "patchy snow possible":
      "assets/animations/weather-icons/lottie/partly-cloudy-day-snow.json",
  "smoke": "assets/animations/weather-icons/lottie/smoke.json",
  "mist": "assets/animations/weather-icons/lottie/mist.json",
  "fog": "assets/animations/weather-icons/lottie/mist.json",
  "dust": "assets/animations/weather-icons/lottie/dust.json",
  "dusty": "assets/animations/weather-icons/lottie/dust.json",
  "dust day": "assets/animations/weather-icons/lottie/dust-day.json",
  "dust night": "assets/animations/weather-icons/lottie/dust-night.json",
  "dust wind": "assets/animations/weather-icons/lottie/dust-wind.json",
  "windy": "assets/animations/weather-icons/lottie/wind.json",
  "tornado": "assets/animations/weather-icons/lottie/tornado.json",
  "hurricane": "assets/animations/weather-icons/lottie/hurricane.json",
  "thundery outbreaks possible":
      "assets/animations/weather-icons/lottie/thunderstorms-overcast.json",
  "thunderstorms":
      "assets/animations/weather-icons/lottie/thunderstorms-overcast.json",
};

// final Map<int, String> weatherCodeToLottie = {
//   // ☀️ Clear / Sunny
//   1000: 'assets/animations/weather-icons/lottie/clear-day.json',

//   // 🌤️ Partly Cloudy
//   1003: 'assets/animations/weather-icons/lottie/partly-cloudy-day.json',
//   1006: 'assets/animations/weather-icons/lottie/cloudy.json',
//   1009: 'assets/animations/weather-icons/lottie/overcast.json',

//   // 🌫️ Mist / Fog / Haze
//   1030: 'assets/animations/weather-icons/lottie/mist.json',
//   1135: 'assets/animations/weather-icons/lottie/fog.json',
//   1147: 'assets/animations/weather-icons/lottie/fog.json',
//   1430: 'assets/animations/weather-icons/lottie/haze.json',

//   // 🌧️ Drizzle
//   1150: 'assets/animations/weather-icons/lottie/drizzle.json',
//   1153: 'assets/animations/weather-icons/lottie/drizzle.json',
//   1168:
//       'assets/animations/weather-icons/lottie/drizzle.json', // freezing drizzle
//   1171: 'assets/animations/weather-icons/lottie/drizzle.json',

//   // 🌧️ Rain
//   1180: 'assets/animations/weather-icons/lottie/rain.json',
//   1183: 'assets/animations/weather-icons/lottie/rain.json',
//   1186: 'assets/animations/weather-icons/lottie/rain.json',
//   1189: 'assets/animations/weather-icons/lottie/rain.json',
//   1192: 'assets/animations/weather-icons/lottie/overcast-rain.json',
//   1195: 'assets/animations/weather-icons/lottie/overcast-rain.json',
//   1198: 'assets/animations/weather-icons/lottie/rain.json', // freezing rain
//   1201:
//       'assets/animations/weather-icons/lottie/rain.json', // heavy freezing rain
//   // 🌨️ Sleet (ice pellets)
//   1204: 'assets/animations/weather-icons/lottie/sleet.json',
//   1207: 'assets/animations/weather-icons/lottie/sleet.json',

//   // ❄️ Snow
//   1210: 'assets/animations/weather-icons/lottie/snow.json',
//   1213: 'assets/animations/weather-icons/lottie/snow.json',
//   1216: 'assets/animations/weather-icons/lottie/snow.json',
//   1219: 'assets/animations/weather-icons/lottie/snow.json',
//   1222: 'assets/animations/weather-icons/lottie/snow.json',
//   1225: 'assets/animations/weather-icons/lottie/snow.json',

//   // 🌨️ Ice pellets / Hail
//   1237: 'assets/animations/weather-icons/lottie/hail.json',

//   // 🌦️ Light rain showers
//   1240: 'assets/animations/weather-icons/lottie/rain.json',
//   1243: 'assets/animations/weather-icons/lottie/rain.json',
//   1246: 'assets/animations/weather-icons/lottie/overcast-rain.json',

//   // 🌨️ Snow showers
//   1249: 'assets/animations/weather-icons/lottie/snow.json',
//   1252: 'assets/animations/weather-icons/lottie/snow.json',
//   1255: 'assets/animations/weather-icons/lottie/snow.json',
//   1258: 'assets/animations/weather-icons/lottie/overcast-snow.json',

//   // 🧊 Ice pellets showers / Hail
//   1261: 'assets/animations/weather-icons/lottie/hail.json',
//   1264: 'assets/animations/weather-icons/lottie/hail.json',

//   // 🌩️ Thunderstorm (no precipitation)
//   1273: 'assets/animations/weather-icons/lottie/thunderstorms.json',
//   1276: 'assets/animations/weather-icons/lottie/thunderstorms.json',

//   // 🌩️ Thunderstorm with snow
//   1279: 'assets/animations/weather-icons/lottie/thunderstorms-snow.json',
//   1282: 'assets/animations/weather-icons/lottie/thunderstorms-snow.json',

//   // 🌪️ Tornado / hurricane fallback (if needed)
//   9000: 'assets/animations/weather-icons/lottie/hurricane.json',
// };

String getWeatherIconForCode(String condition) {
  return weatherCodeToLottie[condition] ??
      "assets/animations/weather-icons/lottie/not-available.json"; // fallback icon
}
