import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:securechat/Screens/home_screen.dart';
import 'package:securechat/services/auth/login_or_register.dart';

class Auth extends StatelessWidget {
  const Auth({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            // check use is logged in or not

            if (snapshot.hasData) {
              return const HomeScreen();
            } else {
              return const LoginOrRegister();
            }
          }),
    );
  }
}
