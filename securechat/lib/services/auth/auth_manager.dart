import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

//Firebase authentication was implemented following tutorial
//provided by https://www.youtube.com/watch?v=mBBycL0EtBQ&list=WL&index=68

class AuthManager extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // for login
  Future<UserCredential> loginWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential') {
        throw Exception('Please enter a valid email address or password.');
      } else if (e.code == 'channel-error') {
        throw Exception('Please fill in all the fields.');
      } else if (e.code == 'invalid-email') {
        throw Exception('Please enter a valid email address.');
      } else if (e.code == 'wrong-password') {
        throw Exception('Please enter the correct password.');
      } else {
        throw Exception(e.code);
      }
    }
  }

  // For Creating a new account
  Future<UserCredential> registerWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw Exception(
            'The password is too weak. Please use a stronger password.');
      } else if (e.code == 'email-already-in-use') {
        throw Exception('User is already registered. Please login.');
      } else if (e.code == 'invalid-email') {
        throw Exception('Please enter a valid email address.');
      } else if (e.code == 'channel-error') {
        throw Exception('Please fill in all the fields.');
      } else {
        throw Exception(e.code);
      }
    }
  }

  // For Signing out

  Future<void> signOut() async {
    return await FirebaseAuth.instance.signOut();
  }
}
