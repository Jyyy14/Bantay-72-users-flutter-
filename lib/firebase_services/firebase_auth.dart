// ignore_for_file: use_build_context_synchronously

import 'package:bantay_72_users/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signUpWithEmailandPassword(BuildContext context, String email, String password) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return credential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        negateToast(context, message: "Email is already in use");
      } else if (e.code == 'weak-password'){
        negateToast(context, message: "Password is weak");
      } else{
        negateToast(context, message: 'An error occured');
      }
    }

    return null;
  }

  Future<User?> signInWithEmailandPassword(BuildContext context, String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return credential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential') {
        negateToast(context, message: 'Invalid Email or Password');
      } else{
        negateToast(context, message: 'An error occurred');
      } 
    }

    return null;
  }
}
