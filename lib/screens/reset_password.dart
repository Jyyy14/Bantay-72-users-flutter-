// ignore_for_file: use_build_context_synchronously

import 'package:bantay_72_users/constants.dart';
import 'package:bantay_72_users/widgets/button.dart';
import 'package:bantay_72_users/widgets/dialogs.dart';
import 'package:bantay_72_users/widgets/textformfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scaler/scaler.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  TextEditingController emailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reset password', style: GoogleFonts.poppins(color: white)),
        backgroundColor: Primary,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_sharp),
          color: white, // 1
          onPressed: () {
            Navigator.of(context).maybePop();
          },
        ),
      ),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: Scaler.height(0.15, context)),
            Text(
              'Enter Email Address',
              style: GoogleFonts.poppins(
                color: Primary,
                fontWeight: FontWeight.w600,
                fontSize: 27.0,
              ),
            ),
        
            const SizedBox(height: 10.0),
        
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Text(
                'Enter the email address associated with your account.',
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w400,
                  fontSize: 15.0,
                ),
              ),
            ),
        
            Padding(
              padding: const EdgeInsets.only(top: 30.0, bottom: 20.0),
              child: CustomTextFormField(
                controller: emailController,
                isEmail: true,
                validator:
                    (value) => value!.isEmpty ? 'Enter your email' : null,
                onSaved: (value) => emailController.text = value!,
                fontSize: 17.0,
                fontColor: Colors.black,
                height: Scaler.height(0.1, context),
                width: Scaler.width(0.9, context),
              ),
            ),
        
            CustomButton(
              onTap: () => _resetPassword(context),
              fontSize: 18.0,
              height: 45.0,
              width: Scaler.width(0.9, context),
              buttonName: 'Reset Password',
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _resetPassword(BuildContext context) async {
    String email = emailController.text;

    if (email.isEmpty) {
      await customDialog(
        context,
        title: 'Error',
        content: 'Field should not be empty',
      );
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailController.text.trim(),
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Password reset email sent!')));
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? 'Error occurred')));
    }
  }
}
