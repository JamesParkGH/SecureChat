import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:securechat/components/my_button.dart';
import 'package:securechat/components/text_field.dart';
import 'package:securechat/controller/user_controller.dart';
import 'package:securechat/entities/user.dart';
import 'package:securechat/services/auth/auth_manager.dart';

class RegisterScreen extends StatefulWidget {
  final void Function() onTap;
  const RegisterScreen({super.key, required this.onTap});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confimPasswordController = TextEditingController();

  final userController = UserController();

  void signUp() async {
    if (passwordController.text != confimPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Passwords do not match"),
        ),
      );
      return;
    }
    final authService = Provider.of<AuthManager>(context, listen: false);

    try {
      await authService.registerWithEmailAndPassword(
          emailController.text, passwordController.text);

      UserModel user = UserModel(email: emailController.text, isOutOfOffice: false);
      userController.addUser(user);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
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
                  const Text("Create Account",
                      style: TextStyle(
                          fontSize: 30,
                          color: Colors.white,
                          fontFamily: 'Orbitron')),
                  // enter email section

                  const SizedBox(height: 50),
                  MyTextField(
                    controller: emailController,
                    hintText: 'Email',
                    obscureText: false,
                  ),

                  const SizedBox(height: 20),

                  // enter password section
                  MyTextField(
                      controller: passwordController,
                      hintText: 'Password',
                      obscureText: true),

                  const SizedBox(height: 20),

                  // enter password section
                  MyTextField(
                      controller: confimPasswordController,
                      hintText: 'Confirm Password',
                      obscureText: true),

                  const SizedBox(height: 20),

                  //sign in button
                  MyButton(onTap: signUp, text: "Create Account"),

                  const SizedBox(height: 20),

                  // login if already have account

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Have an account?",
                          style: TextStyle(
                              color: Colors.white, fontFamily: 'Orbitron')),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: const Text(
                          "Login Now",
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
