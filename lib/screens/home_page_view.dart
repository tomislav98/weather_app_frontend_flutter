import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';

import 'package:weather_app/db/sqflite_db.dart';
import '../models/weather.dart';
import '../services/weather_api.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';
import '../widgets/flippable_hourly_card.dart';
import 'package:provider/provider.dart';
import '../utils/weather_icon_mapper.dart';
import 'package:flutter_weather_bg_null_safety/flutter_weather_bg.dart';
import 'package:weather_app/theme_provider.dart';
import '../widgets/drawer_widget.dart';

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
  List<Map<String, String>> _savedCities = [];
  late PageController _pageController;
  late final String sunrise;
  late final String sunset;
  late final double totalDuration;
  late final double elapsed;
  late final double progress;
  final now = DateTime.now();
  final formatDate = DateFormat("hh:mm a");

  // Future<void> _showGpsDisableDialog(BuildContext context) async {
  //   bool? result = await showDialog<bool>(
  //     context: context,
  //     barrierDismissible: false, // User must tap a button
  //     builder: (context) {
  //       return AlertDialog(
  //         title: Text('GPS is enabled'),
  //         content: Text('Would you like to disable GPS?'),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.of(context).pop(false), // User says NO
  //             child: Text('No'),
  //           ),
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop(true); // User says YES
  //             },
  //             child: Text('Yes'),
  //           ),
  //         ],
  //       );
  //     },
  //   );

  //   if (result == true) {
  //     // User wants to disable GPS
  //     // You can navigate them to settings or give instructions
  //     _openLocationSettings();
  //   }
  // }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // void _openLocationSettings() {
  //   // Unfortunately, you cannot disable GPS programmatically for privacy reasons,
  //   // but you can open the location settings page for the user.

  //   Geolocator.openLocationSettings();
  // }

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
      _savedCities =
          cities
              .map(
                (row) => {
                  'city': row['city'] as String,
                  'country': row['country'] as String,
                },
              )
              .toList();
    });
  }

  Future<void> _refresh() async {
    // Step 1: Reload cities from the database
    final cities = await dbHelper.getAllCities();

    // Step 2: Optionally get the most recent one

    setState(() {
      // here is triggered FutureBuilder
      _savedCities =
          cities
              .map(
                (row) => {
                  'city': row['city'] as String,
                  'country': row['country'] as String,
                },
              )
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        titleSpacing: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0.0,

        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          width: MediaQuery.of(context).size.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              //Our profile image
              Builder(
                builder:
                    (context) => GestureDetector(
                      onTap: () {
                        // Open drawer if signed up
                        Scaffold.of(context).openDrawer();

                        // Show signup dialog
                        //_dialogBuilder(context);
                      },
                      child: CircleAvatar(
                        backgroundColor: Color(0xffE6E6E6),
                        radius: 20,
                        child: ClipOval(
                          child: Image.asset(
                            'assets/profile/avatar.jpg',
                            fit: BoxFit.cover,
                            width: 80,
                            height: 80,
                          ),
                        ),
                      ),
                    ),
              ),
              //our location dropdown
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Switch(
                    value: isDark,
                    onChanged: (value) {
                      themeProvider.toggleTheme(value);
                    },
                    activeColor: Colors.blue, // customize colors if you want
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      drawer: buildAppDrawer(context),

      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _savedCities.length,
                itemBuilder: (context, index) {
                  return RefreshIndicator(
                    onRefresh: _refresh,
                    child: FutureBuilder<Weather>(
                      future: fetchWeatherData(
                        _savedCities[index]['city']!,
                        _savedCities[index]['country']!,
                      ),
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
                count: _savedCities.length,
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
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.start,
              ),

              Row(
                children: [
                  Text(
                    DateFormat(
                      'EEEE, d MMMM',
                    ).format(DateTime.now()), // Example: Monday, 17 June
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  SizedBox(height: 1),
                  Text(
                    '(${weather.country})',
                    style: Theme.of(context).textTheme.labelMedium,
                    textAlign: TextAlign.start,
                  ),
                ],
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
                style: Theme.of(context).textTheme.labelLarge,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 5),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Theme.of(context).cardColor,
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
                style: Theme.of(context).textTheme.labelLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Humidity',
                style: Theme.of(context).textTheme.labelLarge,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 5),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Theme.of(context).cardColor,
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
                '${weather.humidity}%',
                style: Theme.of(context).textTheme.labelLarge,
                textAlign: TextAlign.start,
              ),
            ],
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Max temp',
                style: Theme.of(context).textTheme.labelLarge,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 5),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Theme.of(context).cardColor,
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
                style: Theme.of(context).textTheme.labelLarge,
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
            style: Theme.of(context).textTheme.titleMedium,
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

  // Widget _sunsetAndSunrise(BuildContext context, Weather weather) {
  //   final format = DateFormat("hh:mm a"); // Formato tipo "06:15 AM"
  //   DateTime today = DateTime.now();

  //   final sunriseParsed = format.parse(weather.sunrise);
  //   final sunsetParsed = format.parse(weather.sunset);

  //   final sunriseTime = DateTime(
  //     today.year,
  //     today.month,
  //     today.day,
  //     sunriseParsed.hour,
  //     sunriseParsed.minute,
  //   );

  //   final sunsetTime = DateTime(
  //     today.year,
  //     today.month,
  //     today.day,
  //     sunsetParsed.hour,
  //     sunsetParsed.minute,
  //   );

  //   final totalDuration = sunsetTime.difference(sunriseTime).inSeconds;
  //   final elapsed = now
  //       .difference(sunriseTime)
  //       .inSeconds
  //       .clamp(0, totalDuration);
  //   final progress = totalDuration == 0 ? 0.0 : elapsed / totalDuration;
  //   double maxWidth = 300; // larghezza barra

  //   //double progress = 0.5; // esempio

  //   return Container(
  //     width: MediaQuery.of(context).size.width * 0.9,
  //     height: MediaQuery.of(context).size.height * 0.1,
  //     color: Colors.blue,
  //     child: Column(
  //       children: [
  //         Row(
  //           children: [
  //             Text(
  //               'Sunrise and sunset',
  //               style: const TextStyle(
  //                 fontFamily: 'Montserrat',
  //                 fontSize: 20,
  //                 fontWeight: FontWeight.bold,
  //               ),
  //               textAlign: TextAlign.start,
  //             ),
  //           ],
  //         ),
  //         SizedBox(height: 20),
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: [
  //             Stack(
  //               clipBehavior: Clip.none,
  //               children: [
  //                 // Barra base
  //                 Container(
  //                   width: maxWidth,
  //                   height: 1,
  //                   decoration: BoxDecoration(
  //                     color: Colors.grey.shade300,
  //                     borderRadius: BorderRadius.circular(10),
  //                   ),
  //                 ),

  //                 // Barra riempita
  //                 Container(
  //                   width: maxWidth * progress,
  //                   height: 1,
  //                   decoration: BoxDecoration(
  //                     color: Colors.orangeAccent,
  //                     borderRadius: BorderRadius.circular(10),
  //                   ),
  //                 ),
  //                 Positioned(
  //                   left: -24,
  //                   top: -31,
  //                   child: SizedBox(
  //                     width: 48,
  //                     height: 48,
  //                     child: Lottie.asset(
  //                       'assets/animations/weather-icons/lottie/sunrise.json',
  //                     ),
  //                   ),
  //                 ),
  //                 Positioned(
  //                   left: maxWidth - 24,
  //                   top: -31,
  //                   child: SizedBox(
  //                     width: 48,
  //                     height: 48,
  //                     child: Lottie.asset(
  //                       'assets/animations/weather-icons/lottie/sunset.json',
  //                     ),
  //                   ),
  //                 ),

  //                 // Sole che si muove solo orizzontalmente
  //                 Positioned(
  //                   left:
  //                       (maxWidth * progress).clamp(24.0, maxWidth - 24.0) - 24,
  //                   top: -24,
  //                   child: SizedBox(
  //                     width: 48,
  //                     height: 48,
  //                     child: Lottie.asset(
  //                       'assets/animations/weather-icons/lottie/clear-day.json',
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ],
  //         ),
  //         SizedBox(height: 5),
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             Column(children: [Text(weather.sunrise)]),
  //             Column(children: [Text(weather.sunset)]),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }
}

Color _getTextColor(String conditionText) {
  final weatherType = getWeatherBgType(conditionText);

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
