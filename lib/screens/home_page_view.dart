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
import '../widgets/flippable_hourly_card.dart';

import '../utils/weather_icon_mapper.dart';
import 'package:weather_app/screens/user_form_view.dart';
import 'package:flutter_weather_bg_null_safety/flutter_weather_bg.dart';

class HomePageView extends StatefulWidget {
  const HomePageView({super.key});

  @override
  State<HomePageView> createState() => _HomePageViewState();
}

class _HomePageViewState extends State<HomePageView>
    with TickerProviderStateMixin {
  Future<Placemark>? manageGPS;
  late Future<void> locationServiceDialog;
  final dbHelper = DatabaseHelper();
  List<String> savedCities = [];
  late PageController _pageController;
  late final String sunrise;
  late final String sunset;
  late final double totalDuration;
  late final double elapsed;
  late final double progress;
  final now = DateTime.now();
  final formatDate = DateFormat("hh:mm a");

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

  Future<void> _dialogBuilder(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          //title: const Text('Basic dialog title'),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: 380,
            child: const UserFormView(),
          ),
        );
      },
    );
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
    // is checking if the widget is still "alive" before calling setState,
    //  to avoid calling setState on a disposed widget, which would cause a runtime error.
    // it's built in
    if (!mounted) return;
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
        automaticallyImplyLeading: false,
        centerTitle: false,
        titleSpacing: 0,
        backgroundColor: Colors.white,
        elevation: 0.0,

        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          width: MediaQuery.of(context).size.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              //Our profile image
              GestureDetector(
                onTap: () {
                  _dialogBuilder(context);
                  // your widget here
                },
                child: CircleAvatar(
                  backgroundColor: Color(0xffE6E6E6),
                  radius: 20,
                  child: ClipOval(
                    child: Image.asset(
                      'assets/profile/avatar.jpg',
                      fit: BoxFit.cover,
                      width: 80, // match diameter
                      height: 80,
                    ),
                  ),
                ),
              ),
              //our location dropdown
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () => _showBottomMenu(context),
                    color: Colors.black, // Or any color you want for the icon
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

      //AppBar(
      //   backgroundColor: Colors.white,
      //   leading: CircleAvatar(
      //     backgroundColor: Color(0xffE6E6E6),
      //     radius: 30,
      //     child: Icon(Icons.person, color: Color(0xffCCCCCC)),
      //   ),
      //   actions: [
      //     IconButton(
      //       icon: const Icon(Icons.more_vert),
      //       onPressed: () => _showBottomMenu(context),
      //       color: Colors.black, // Or any color you want for the icon
      //     ),
      //   ],
      // ),
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
                        //print('🧪 Debug test: builder triggered');

                        return SingleChildScrollView(
                          child: Container(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _mainTitleWeatherInfo(weather),
                                SizedBox(height: 10),
                                _buildMainWeatherInfo(weather),
                                SizedBox(height: 10),
                                _buildThreeIcons(weather),
                                SizedBox(height: 10),
                                _buildHourlyForecast(weather),
                                //_sunsetAndSunrise(context, weather),
                              ],
                            ),
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
    final width = MediaQuery.sizeOf(context).width;

    return Container(
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            /// 🌦️ Weather background layer clipped inside rounded border
            ///  one example WeatherType.lightRainy
            WeatherBg(
              weatherType: getWeatherBgType(weather.conditionText),
              width: width,
              height: 200,
            ),

            // Positioned(
            //   top: -40,
            //   left: 20,
            //   child: Lottie.asset(
            //     getWeatherIconForCode(weather.conditionText),
            //     width: 150,
            //     height: 150,
            //   ),
            // ),
            Positioned(
              bottom: 30,
              left: 20,
              child: Text(
                weather.conditionText,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _getTextColor(weather.conditionText),
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
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 50,
                        fontWeight: FontWeight.normal,
                        color: _getTextColor(weather.conditionText),
                      ),
                    ),
                  ),
                  Text(
                    "°", // celsius
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      color: _getTextColor(weather.conditionText),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
    final width = MediaQuery.of(context).size.width * 0.9;

    return Container(
      width: width,
      height: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title bar
          Text(
            'Today',
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.start,
          ),

          const SizedBox(height: 20),

          // Hourly forecast cards row
          SizedBox(
            height: 140,
            width: width,
            child: FlippableHourlyCard(hour: weather.hourly),
          ),
        ],
      ),
    );
  }

  Widget _sunsetAndSunrise(BuildContext context, Weather weather) {
    final format = DateFormat("hh:mm a"); // Formato tipo "06:15 AM"
    DateTime today = DateTime.now();

    final sunriseParsed = format.parse(weather.sunrise);
    final sunsetParsed = format.parse(weather.sunset);

    final sunriseTime = DateTime(
      today.year,
      today.month,
      today.day,
      sunriseParsed.hour,
      sunriseParsed.minute,
    );

    final sunsetTime = DateTime(
      today.year,
      today.month,
      today.day,
      sunsetParsed.hour,
      sunsetParsed.minute,
    );

    final totalDuration = sunsetTime.difference(sunriseTime).inSeconds;
    final elapsed = now
        .difference(sunriseTime)
        .inSeconds
        .clamp(0, totalDuration);
    final progress = totalDuration == 0 ? 0.0 : elapsed / totalDuration;
    double maxWidth = 300; // larghezza barra

    //double progress = 0.5; // esempio

    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height * 0.1,
      color: Colors.blue,
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Sunrise and sunset',
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.start,
              ),
            ],
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  // Barra base
                  Container(
                    width: maxWidth,
                    height: 1,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  // Barra riempita
                  Container(
                    width: maxWidth * progress,
                    height: 1,
                    decoration: BoxDecoration(
                      color: Colors.orangeAccent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Positioned(
                    left: -24,
                    top: -31,
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: Lottie.asset(
                        'assets/animations/weather-icons/lottie/sunrise.json',
                      ),
                    ),
                  ),
                  Positioned(
                    left: maxWidth - 24,
                    top: -31,
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: Lottie.asset(
                        'assets/animations/weather-icons/lottie/sunset.json',
                      ),
                    ),
                  ),

                  // Sole che si muove solo orizzontalmente
                  Positioned(
                    left:
                        (maxWidth * progress).clamp(24.0, maxWidth - 24.0) - 24,
                    top: -24,
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: Lottie.asset(
                        'assets/animations/weather-icons/lottie/clear-day.json',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(children: [Text(weather.sunrise)]),
              Column(children: [Text(weather.sunset)]),
            ],
          ),
        ],
      ),
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

Color _getTextColor(String conditionText) {
  final weatherType = getWeatherBgType(conditionText);
  print("This is the weather type: $weatherType");
  if (weatherType == WeatherType.sunny || weatherType == WeatherType.cloudy) {
    return Colors.black;
  } else {
    return Colors.white;
  }
}

String getWeatherIconForCode(String condition) {
  return weatherCodeToLottie[condition] ??
      "assets/animations/weather-icons/lottie/not-available.json"; // fallback icon
}
