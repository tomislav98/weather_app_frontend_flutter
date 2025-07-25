// lib/widgets/auth_wrapper.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/sign_up_page_view.dart';
import '../widgets/drawer_widget.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // or splash screen
        } else if (snapshot.hasData) {
          return buildAppDrawer(context);
        } else {
          return SignUpPageView();
        }
      },
    );
  }
}
