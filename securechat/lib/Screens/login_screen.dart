import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:securechat/components/my_button.dart';
import 'package:securechat/components/text_field.dart';
import 'package:securechat/services/auth/auth_manager.dart';

class LoginScreen extends StatefulWidget {
  final void Function() onTap;
  const LoginScreen({super.key, required this.onTap});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void SignIn() async {
    final authService = Provider.of<AuthManager>(context, listen: false);

    try {
      await authService.loginWithEmailAndPassword(
          emailController.text, passwordController.text);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // sign in text
                  const SizedBox(height: 0),
                  const Text("Login",
                      style: TextStyle(
                          fontSize: 30,
                          color: Colors.white,
                          fontFamily: 'Orbitron')),
                  // enter email section

                  const SizedBox(height: 50),
                  MyTextField(
                      controller: emailController,
                      hintText: 'Email',
                      obscureText: false),

                  const SizedBox(height: 20),

                  // enter password section
                  MyTextField(
                      controller: passwordController,
                      hintText: 'Password',
                      obscureText: true),

                  const SizedBox(height: 20),

                  //sign in button
                  MyButton(onTap: SignIn, text: "Sign In"),

                  const SizedBox(height: 20),

                  // register if no account

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?",
                          style: TextStyle(
                              color: Colors.white, fontFamily: 'Orbitron')),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: const Text(
                          "Register Now",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                              fontFamily: 'Orbitron'),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
