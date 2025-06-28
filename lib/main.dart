import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/home_page_view.dart';
import 'utils/logger.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await initLogger(); // Initialize file logger

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'Weather App',

      themeMode: themeProvider.themeMode,
      theme: ThemeData.light().copyWith(
        // WHITE THEME
        scaffoldBackgroundColor: Colors.white,
        textTheme: TextTheme(
          titleLarge: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          titleMedium: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),

          labelMedium: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 12,
            color: Colors.black, // or Colors.grey.shade600
            fontWeight: FontWeight.w400,
          ),
          labelLarge: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14,
            color: Colors.black, // or Colors.grey.shade600
            fontWeight: FontWeight.w400,
          ),
        ),
        cardColor: Colors.grey.shade200,
        colorScheme: ColorScheme.light(),
      ),
      darkTheme: ThemeData.dark().copyWith(
        // DARK THEME
        scaffoldBackgroundColor: const Color(
          0xFF2C3E50,
        ), // Indigo-like dark blue
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          titleMedium: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          labelLarge: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14,
            color: Colors.white70,
            fontWeight: FontWeight.w400,
          ),
          labelMedium: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 12,
            color: Colors.white60,
            fontWeight: FontWeight.w400,
          ),

          // const Color(0xFF3E4A59)
        ),
        cardColor: const Color(0xFF3E4A59),
        colorScheme: ColorScheme.dark(onPrimary: Colors.white),
      ),
      home: HomePageView(),
    );
  }
}
