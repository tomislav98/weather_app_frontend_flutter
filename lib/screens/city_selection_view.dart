import 'package:flutter/material.dart';
import 'package:weather_app/db/sqflite_db.dart';
import 'package:weather_app/screens/home_page_view.dart';
import 'package:weather_app/screens/search_page_view.dart';
import 'package:weather_app/services/weather_api.dart';
import '../models/weather.dart' show Weather;
import '../utils/transition_logic.dart';

class CitySelectionView extends StatefulWidget {
  const CitySelectionView({super.key});

  @override
  State<CitySelectionView> createState() => _CitySelectionViewState();
}

class _CitySelectionViewState extends State<CitySelectionView> {
  final dbHelper = DatabaseHelper();
  List<Map<String, String>> _savedCities = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('City Selection'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            navigateWithSlideTransition(context, HomePageView());
          },
        ),
      ),
      body: Center(
        child: ListView.builder(
          itemCount: _savedCities.length,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () async {
                setMostRecentCity(_savedCities[index]['city']!);

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
              child: Dismissible(
                key: ValueKey(_savedCities[index]),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  color: Colors.red.withOpacity(0.5),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) {
                  setState(() {
                    final db = DatabaseHelper();
                    db.deleteCity(
                      _savedCities[index]['city']!,
                      _savedCities[index]['country']!,
                    );

                    _savedCities.removeAt(index);
                  });

                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('City removed')));
                },
                child: Container(
                  height: 100,
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,

                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: FutureBuilder(
                    future: fetchWeatherData(
                      _savedCities[index]['city']!,
                      _savedCities[index]['country']!,
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
                          navigateWithSlideTransition(context, HomePageView());
                        },

                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  weather.locationName,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                Text(
                                  weather.country,
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),
                            const Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "${weather.currentTemperature}°",
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  weather.conditionText,
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).scaffoldBackgroundColor,
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 50, // optional fixed height for better control
          child: Center(
            child: GestureDetector(
              child: GestureDetector(
                onTap: () {
                  navigateWithSlideTransition(context, SearchPageView());
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
  void initState() {
    super.initState();
    initialize();
  }
}
