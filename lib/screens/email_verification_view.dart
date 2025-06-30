import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'home_page_view.dart';

class EmailVerificationView extends StatelessWidget {
  const EmailVerificationView({super.key});

  Future<void> checkEmailVerificationAndProceed(BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;

    await user?.reload();
    user = FirebaseAuth.instance.currentUser;

    if (user != null && user.emailVerified) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePageView()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please verify your email before continuing.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Email Verification")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'A verification email has been sent to your inbox.\n\nPlease verify your email and then click Continue.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  await checkEmailVerificationAndProceed(context);
                },
                child: const Text("Continue"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
