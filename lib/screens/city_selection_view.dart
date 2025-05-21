import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app/screens/search_page_view.dart';

class CitySelectionView extends StatefulWidget {
  const CitySelectionView({super.key});

  @override
  State<CitySelectionView> createState() => _CitySelectionViewState();
}

class _CitySelectionViewState extends State<CitySelectionView> {
  List<String> _savedCities = [];

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedCities = prefs.getStringList('savedCities') ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('City Selection')),
      body: Center(
        child: ListView.builder(
          itemCount: _savedCities.length,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () async {
                // Handle tap for the city at _savedCities[index]
                print('Tapped city: ${_savedCities[index]}');
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('selectedCity', _savedCities[index]);
              },
              child: Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(16),
                color: Colors.blueAccent,
                child: Text(
                  _savedCities[index],
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.grey[200],
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SearchPageView(),
                  ),
                );
                print('Text tapped!');
              },
              child: Text(
                'Centered icon and text',
                style: TextStyle(
                  color: Colors.blue, // Optional for visual feedback
                  decoration: TextDecoration.underline, // Optional
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
