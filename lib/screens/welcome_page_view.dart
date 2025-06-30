import 'package:flutter/material.dart';
import 'package:weather_app/screens/home_page_view.dart';

import 'package:weather_app/screens/sign_in_page_view.dart';
import 'package:weather_app/screens/sign_up_page_view.dart';

import 'package:lottie/lottie.dart';

class WelcomePageView extends StatelessWidget {
  const WelcomePageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed:
              () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePageView()),
              ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(16),
          //height: MediaQuery.of(context).size.height * 0.5,
          width: MediaQuery.of(context).size.width * 0.9,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.black,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 50, // adjust width
                    height: 50,
                    child: Lottie.asset(
                      'assets/animations/weather-icons/lottie/overcast-day.json',
                      fit: BoxFit.contain,
                      alignment: Alignment.center,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text(
                "Welcome to tomislav's weather!",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 20),
              Container(
                // height: MediaQuery.of(context).size.height * 0.9,
                width: MediaQuery.of(context).size.width * 0.9,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF90CAF9), // light blue
                      Color(0xFF42A5F5), // medium blue
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextButton(
                  style: TextButton.styleFrom(foregroundColor: Colors.black),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignUpPageView(),
                      ),
                    );
                  },
                  child: Text(
                    'Sign up',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Already have an account? ',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),

                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignInPageView(),
                        ),
                      );
                    },
                    child: Text(
                      'Sign in',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Don\'t want to sign in right now?',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),

                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomePageView(),
                        ),
                      );
                    },
                    child: Text(
                      'Skip for now',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'By continuing, you agree to ',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Terms of Service',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
