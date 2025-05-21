import 'dart:async' show Timer;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/search_api.dart';

class SearchPageView extends StatefulWidget {
  const SearchPageView({super.key});

  @override
  State<SearchPageView> createState() => _SearchPageViewState();
}

class _SearchPageViewState extends State<SearchPageView> {
  TextEditingController _controller = TextEditingController();
  List<dynamic> _searchResults = [];
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() async {
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final query = _controller.text;
      if (query.isEmpty) {
        setState(() {
          _searchResults = [];
        });
        return;
      }
      final results = await searchCity(query);
      setState(() {
        _searchResults = results;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add the City')),
      body: RefreshIndicator(
        onRefresh: () async {},
        child: Column(
          children: [
            Container(
              width: double.infinity,
              margin: EdgeInsets.only(top: 40, left: 20, right: 20),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Color(0xff1D1617).withOpacity(0.11),
                    spreadRadius: 0.0,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: _controller,
                onChanged: (_) => _onSearchChanged(),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(16),
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Search...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            // 🔽 Show search results
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final city = _searchResults[index];
                  return ListTile(
                    title: Text('${city['name']}, ${city['country']}'),
                    onTap: () async {
                      // select the main city
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString('selectedCity', city['name']);

                      // set the list
                      List<String> savedCities =
                          prefs.getStringList('savedCities') ?? [];
                      if (!savedCities.contains(city['name'])) {
                        savedCities.add(city['name']);
                        await prefs.setStringList('savedCities', savedCities);
                      }
                      setState(() {
                        _controller.text = '';
                        _searchResults.clear();
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
