import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../services/auth_service.dart';
import '../services/alert_api.dart';
import '../screens/city_selection_view.dart';
import '../utils/transition_logic.dart' show navigateWithSlideTransition;
import '../screens/radar_page_view.dart';
import '../screens/welcome_page_view.dart';

Widget buildAppDrawer(BuildContext context, bool isSignedIn) {
  final authService = AuthService();
  final user = authService.getCurrentUser;
  return Drawer(
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          decoration: BoxDecoration(color: Color(0xFF34495E)),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Color(0xffE6E6E6),
                radius: 40,
                child: ClipOval(
                  child: Image.asset(
                    'assets/profile/avatar.jpg',
                    fit: BoxFit.cover,
                    width: 80,
                    height: 80,
                  ),
                ),
              ),
              SizedBox(width: 16),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user != null ? (user.email ?? 'User name') : 'Profile',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  GestureDetector(
                    onTap:
                        isSignedIn
                            ? null
                            : () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const WelcomePageView(),
                                ),
                              );
                            },
                    child: Text(
                      'Welcome screen',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        ListTile(
          leading: Lottie.asset(
            'assets/animations/weather-icons/lottie/city.json',
            fit: BoxFit.contain,
            alignment: Alignment.center,
          ),
          title: const Text('Select City'),
          onTap:
              () => navigateWithSlideTransition(
                context,
                const CitySelectionView(),
              ),
        ),
        ListTile(
          leading: Lottie.asset(
            'assets/animations/weather-icons/lottie/lightning-bolt.json',
            fit: BoxFit.contain,
            alignment: Alignment.center,
          ),
          title: const Text('Set Alert system'),
          onTap:
              user != null
                  ? () async {
                    await callNotifyApi();
                  }
                  : null,
          enabled: user != null,
        ),
        ListTile(
          leading: Lottie.asset(
            'assets/animations/weather-icons/lottie/compass.json',
            fit: BoxFit.contain,
            alignment: Alignment.center,
          ),
          title: const Text('Radar'),
          onTap:
              () => navigateWithSlideTransition(context, const RadarPageView()),
        ),
      ],
    ),
  );
}
