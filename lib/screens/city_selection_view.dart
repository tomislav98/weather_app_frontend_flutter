import 'package:flutter/material.dart';
import 'package:weather_app/db/sqflite_db.dart';
import 'package:weather_app/screens/home_page_view.dart';
import 'package:weather_app/screens/search_page_view.dart';
import 'package:weather_app/services/weather_api.dart';
import 'package:weather_app/utils/ui_colors.dart';

import '../models/weather.dart' show Weather;

class CitySelectionView extends StatefulWidget {
  const CitySelectionView({super.key});

  @override
  State<CitySelectionView> createState() => _CitySelectionViewState();
}

class _CitySelectionViewState extends State<CitySelectionView> {
  final dbHelper = DatabaseHelper();
  List<String> _savedCities = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('City Selection')),
      body: Center(
        child: ListView.builder(
          itemCount: _savedCities.length,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () async {
                setMostRecentCity(_savedCities[index]);

                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 1000),
                    pageBuilder:
                        (context, animation, secondaryAnimation) =>
                            const HomePageView(),
                    transitionsBuilder: (
                      context,
                      animation,
                      secondaryAnimation,
                      child,
                    ) {
                      const begin = Offset(1.0, 0.0); // From right
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
              },
              child: Container(
                height: 100,
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: UiColors.royalBlue.withValues(alpha: 0.8),

                  borderRadius: BorderRadius.circular(8),
                ),
                child: FutureBuilder(
                  future: fetchWeatherData(
                    _savedCities[index],
                  ), // need to modify
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData) {
                      return const Center(child: Text('No data available'));
                    }
                    Weather weather = snapshot.data!;
                    return GestureDetector(
                      onTap: () {
                        setMostRecentCity(weather.locationName);
                        Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            transitionDuration: const Duration(
                              milliseconds: 1500,
                            ),
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    const HomePageView(),
                            transitionsBuilder: (
                              context,
                              animation,
                              secondaryAnimation,
                              child,
                            ) {
                              const begin = Offset(1.0, 0.0); // From right
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
                      },
                      child: Row(
                        children: [
                          Text(
                            weather.locationName,
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Spacer(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "${weather.currentTemperature}°",
                                style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 24,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                weather.conditionText,
                                style: const TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 13,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 50, // optional fixed height for better control
          child: Center(
            child: GestureDetector(
              child: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 1000),
                      pageBuilder:
                          (context, animation, secondaryAnimation) =>
                              const SearchPageView(),
                      transitionsBuilder: (
                        context,
                        animation,
                        secondaryAnimation,
                        child,
                      ) {
                        const begin = Offset(1.0, 0.0); // From right
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
                },
                child: Column(children: [Icon(Icons.add), Text('Add City')]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> initialize() async {
    final cities = await dbHelper.getAllCities();
    setState(() {
      _savedCities = cities;
    });
  }

  @override
  void initState() {
    super.initState();
    initialize();
  }
}
