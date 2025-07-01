import 'dart:async' show Timer;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app/db/sqflite_db.dart';
import 'package:weather_app/screens/home_page_view.dart';
import '../services/search_api.dart';
import '../utils/transition_logic.dart';
import '../screens/city_selection_view.dart';

class SearchPageView extends StatefulWidget {
  const SearchPageView({super.key});

  @override
  State<SearchPageView> createState() => _SearchPageViewState();
}

class _SearchPageViewState extends State<SearchPageView> {
  final TextEditingController _controller = TextEditingController();
  List<dynamic> _searchResults = [];
  final dbHelper = DatabaseHelper();
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
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: const Text('Add the City'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            navigateWithSlideTransition(context, CitySelectionView());
          },
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: RefreshIndicator(
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
                    fillColor: const Color(0xCC34495E),
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
                        await dbHelper.insertCity(
                          city['name'],
                          city['country'],
                        );

                        setState(() {
                          _controller.text = '';
                          _searchResults.clear();
                        });
                        if (!mounted) return;
                        navigateWithSlideTransition(
                          context,
                          const HomePageView(),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
