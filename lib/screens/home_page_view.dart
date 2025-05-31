import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart' show Geolocator;
import 'package:weather_app/db/sqflite_db.dart';
import 'package:weather_app/screens/city_selection_view.dart';
import 'package:weather_app/utils/ui_colors.dart';
import '../models/weather.dart';
import '../models/weather_icons.dart' show WeatherIcons;
import '../services/weather_api.dart';
import '../services/location_api.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class HomePageView extends StatefulWidget {
  const HomePageView({super.key});

  @override
  State<HomePageView> createState() => _HomePageViewState();
}

class _HomePageViewState extends State<HomePageView> {
  late Future<Weather> futureWeather;
  Future<Placemark>? manageGPS;
  late Future<void> locationServiceDialog;
  String _selectedCity = 'Vatican';
  final dbHelper = DatabaseHelper();
  List<String> savedCities = [];
  late PageController _pageController;

  Future<void> _dialogBuilder(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Basic dialog title'),
          content: const Text(
            'A dialog is a type of modal window that\n'
            'appears in front of app content to\n'
            'provide critical information, or prompt\n'
            'for a decision to be made.',
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Disable'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Enable'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    initialize();
    _pageController = PageController();
  }

  Future<void> initialize() async {
    final cities = await dbHelper.getAllCities();

    final recent = await getMostRecentCity();
    setState(() {
      savedCities = cities;
      _selectedCity = recent;
    });
  }

  Future<void> _refresh() async {
    // Step 1: Reload cities from the database
    final cities = await dbHelper.getAllCities();

    // Step 2: Optionally get the most recent one
    final recent = cities.isNotEmpty ? cities.first : 'Vatican';

    setState(() {
      // here is triggered FutureBuilder
      savedCities = cities;
      _selectedCity = recent;
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
              ListTile(
                leading: const Icon(Icons.location_city),
                title: const Text('Select city'),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 1000),
                      pageBuilder:
                          (context, animation, secondaryAnimation) =>
                              const CitySelectionView(),
                      transitionsBuilder: (
                        context,
                        animation,
                        secondaryAnimation,
                        child,
                      ) {
                        const begin = Offset(1.0, 0.0); // Slide from right
                        const end = Offset.zero;
                        const curve = Curves.ease;

                        final tween = Tween(
                          begin: begin,
                          end: end,
                        ).chain(CurveTween(curve: curve));
                        final offsetAnimation = animation.drive(tween);

                        return SlideTransition(
                          position: offsetAnimation,
                          child: child,
                        );
                      },
                    ),
                  );
                  // handle edit
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Delete'),
                onTap: () {
                  Navigator.pop(context);
                  // handle delete
                },
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
        title: const Text("Royale weather"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          GestureDetector(
            onTap: () => _showBottomMenu(context),
            child: Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.more_vert),
            ),
          ),
        ],
      ),
      body: Column(
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
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData) {
                        return const Center(child: Text('No data available'));
                      }

                      final weather = snapshot.data!;

                      return SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildMainWeatherInfo(weather),
                            const SizedBox(height: 10),
                            _buildHourlyForecast(weather),
                            const SizedBox(height: 10),
                            _build_environmental_comfort(weather),
                            const SizedBox(height: 10),
                            _build_wind_forecast(weather),
                            const SizedBox(height: 10),
                            _build_sunrise_widget(weather),
                            const SizedBox(height: 10),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 4), // space between icon and text
              Text(
                weather.locationName,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () async {
                  final serviceEnabled =
                      await Geolocator.isLocationServiceEnabled();
                  if (serviceEnabled) {
                    _dialogBuilder(context);
                    return;
                  }
                  final placemark = await getCurrentPosition();
                  dbHelper.insertCity(placemark.locality!);
                  setState(() {
                    _selectedCity = placemark.locality!;
                    futureWeather = fetchWeatherData(_selectedCity);
                  });
                },
                child: const Icon(
                  Icons.my_location,
                  size: 24,
                  color: Colors.blueAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "${weather.currentTemperature}",
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 50,
                  fontWeight: FontWeight.normal,
                ),
              ),
              Icon(WeatherIcons.wi_celsius, size: 70, color: Colors.black),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            weather.conditionText,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildHourlyForecast(Weather weather) {
    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.04,
          color: Colors.white,
          child: Text(
            'WEATHER FORECAST',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.start,
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.9, // 90% of screen width
          height:
              MediaQuery.of(context).size.height * 0.20, // 20% of screen height
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: UiColors.royalBlue.withValues(
              alpha: 0.8,
            ), // or any color that contrasts with white
            borderRadius: BorderRadius.circular(16), // rounded corners
          ),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.15,
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
                      Text(
                        '${hour.dateTime.hour}:00',
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Icon(
                        getWeatherIconForCode(hour.code),
                        size: 50,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${hour.temperature}°C',
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _build_environmental_comfort(Weather weather) {
    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.04,
          color: Colors.white,
          child: Text(
            'ENVIRONMENTAL COMFORT',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.start,
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.9, // 90% of screen width
          height:
              MediaQuery.of(context).size.height * 0.19, // 20% of screen height
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: UiColors.royalBlue.withValues(
              alpha: 0.8,
            ), // or any color that contrasts with white
            borderRadius: BorderRadius.circular(16), // rounded corners
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Humidity',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    '${weather.humidity}',
                    style: TextStyle(
                      fontSize: 50,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.start,
                  ),
                ],
              ),
              Icon(WeatherIcons.wi_humidity, size: 70, color: Colors.white),
              Spacer(),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text(
                        'Perceived',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(width: 8),
                      Text(
                        '${weather.feelslike_c}',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        'UV index',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(width: 8),
                      Text(
                        '${weather.uv}',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _build_wind_forecast(Weather weather) {
    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.04,
          color: Colors.white,
          child: Text(
            'WIND',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.start,
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.9, // 90% of screen width
          height:
              MediaQuery.of(context).size.height * 0.19, // 20% of screen height
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: UiColors.royalBlue.withValues(
              alpha: 0.8,
            ), // or any color that contrasts with white
            borderRadius: BorderRadius.circular(16), // rounded corners
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(WeatherIcons.wi_strong_wind, size: 70, color: Colors.white),
              Spacer(),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text(
                        'Direction',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(width: 8),
                      Text(
                        weather.windDir,
                        style: TextStyle(fontSize: 18, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        'Speed',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(width: 8),
                      Text(
                        weather.windSpeed.toString(),
                        style: TextStyle(fontSize: 18, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _build_sunrise_widget(Weather weather) {
    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.04,
          color: Colors.white,
          child: Text(
            'SUNRISE/SUNSET',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.start,
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.9, // 90% of screen width
          height:
              MediaQuery.of(context).size.height * 0.19, // 20% of screen height
          padding: const EdgeInsets.all(16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: UiColors.royalBlue.withValues(
              alpha: 0.8,
            ), // or any color that contrasts with white
            borderRadius: BorderRadius.circular(16), // rounded corners
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(WeatherIcons.wi_sunrise, size: 70, color: Colors.white),
                  Text(
                    'Sunrise',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 1),
                  Text(
                    weather.sunrise,
                    style: TextStyle(fontSize: 16, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),

              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Icon(
                      WeatherIcons.wi_sunset,
                      size: 70,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Sunset',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 1),
                  Text(
                    weather.sunset,
                    style: TextStyle(fontSize: 16, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

final Map<int, IconData> weatherCodeToIcon = {
  1000: WeatherIcons.wi_day_sunny,
  1003: WeatherIcons.wi_day_cloudy,
  1006: WeatherIcons.wi_cloudy,
  1009: WeatherIcons.wi_cloudy_gusts,
  1030: WeatherIcons.wi_fog,
  1063: WeatherIcons.wi_day_rain,
  1066: WeatherIcons.wi_day_snow,
  1069: WeatherIcons.wi_day_snow,
  1072: WeatherIcons.wi_day_snow,
  1087: WeatherIcons.wi_day_thunderstorm,
  1114: WeatherIcons.wi_day_snow_wind,
  1117: WeatherIcons.wi_day_snow_wind,
  1135: WeatherIcons.wi_night_cloudy,
  1147: WeatherIcons.wi_night_cloudy,
  1150: WeatherIcons.wi_day_rain,
  1153: WeatherIcons.wi_day_rain,
  1168: WeatherIcons.wi_rain_wind,
  1171: WeatherIcons.wi_rain_wind,
  1180: WeatherIcons.wi_day_showers,
  1183: WeatherIcons.wi_day_showers,
  1186: WeatherIcons.wi_day_rain_wind,
  1189: WeatherIcons.wi_day_rain_wind,
  1192: WeatherIcons.wi_day_rain_wind,
  1195: WeatherIcons.wi_day_rain_wind,
  1198: WeatherIcons.wi_day_rain_wind,
  1201: WeatherIcons.wi_day_rain_wind,
  1204: WeatherIcons.wi_day_snow,
  1207: WeatherIcons.wi_day_snow,
  1210: WeatherIcons.wi_day_snow,
  1213: WeatherIcons.wi_day_snow,
  1216: WeatherIcons.wi_day_snow,
  1219: WeatherIcons.wi_day_snow,
  1222: WeatherIcons.wi_day_snow,
  1225: WeatherIcons.wi_day_snow,
  1237: WeatherIcons.wi_day_hail,
  1240: WeatherIcons.wi_day_showers,
  1243: WeatherIcons.wi_day_showers,
  1246: WeatherIcons.wi_day_showers,
  1249: WeatherIcons.wi_day_snow,
  1252: WeatherIcons.wi_day_snow,
  1255: WeatherIcons.wi_day_snow,
  1258: WeatherIcons.wi_day_snow_wind,
  1261: WeatherIcons.wi_day_snow_wind,
  1264: WeatherIcons.wi_day_snow_wind,
  1273: WeatherIcons.wi_day_thunderstorm,
  1276: WeatherIcons.wi_day_thunderstorm,
  1279: WeatherIcons.wi_day_thunderstorm,
  1282: WeatherIcons.wi_day_thunderstorm,
};

IconData getWeatherIconForCode(int code) {
  return weatherCodeToIcon[code] ?? WeatherIcons.wi_fog; // fallback icon
}
