import 'package:flutter/material.dart';
import 'package:securechat/Screens/login_screen.dart';
import 'package:securechat/Screens/register_screen.dart';

class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({super.key});

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {
  bool showLoginScreen = true;

  void switchScreens() {
    setState(() {
      showLoginScreen = !showLoginScreen;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginScreen) {
      return LoginScreen(onTap: switchScreens);
    } else {
      return RegisterScreen(onTap: switchScreens);
    }
  }
}
