// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:bantay_72_users/constants.dart';
import 'package:bantay_72_users/widgets/button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scaler/scaler.dart';
import 'package:cloud_functions/cloud_functions.dart'; // ⚠️ Add this

class VerificationScreen extends StatefulWidget {
  final String email;
  const VerificationScreen({super.key, required this.email});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  bool _isCooldown = false;
  int _cooldownSeconds = 30;
  Timer? _cooldownTimer;
  late Timer _checkVerificationTimer;
  bool _isVerified = false;

  @override
  void initState() {
    super.initState();
    _sendVerificationEmail(); // ⚠️ Now calls Cloud Function
    _startCooldown();
    _startVerificationChecker();
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _checkVerificationTimer.cancel();
    super.dispose();
  }

  Future<void> _sendVerificationEmail() async {
    try {
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
        'sendVerificationEmail',
      );
      final result = await callable.call(<String, dynamic>{
        'email': widget.email,
      });

      if (result.data['success'] == true) {
        debugPrint('Verification email sent to ${widget.email}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification email sent to ${widget.email}')),
        );
      }
    } catch (e) {
      debugPrint('Failed to send email: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to send email: $e')));
    }
  }

  void _startVerificationChecker() {
    _checkVerificationTimer = Timer.periodic(const Duration(seconds: 3), (
      timer,
    ) async {
      await FirebaseAuth.instance.currentUser?.reload();
      final user = FirebaseAuth.instance.currentUser;

      if (user != null && user.emailVerified) {
        setState(() {
          _isVerified = true;
        });
        timer.cancel();
      }
    });
  }

  Future<void> _resendEmail() async {
    if (_isCooldown) return;

    try {
      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
        'sendVerificationEmail',
      );
      final result = await callable.call(<String, dynamic>{
        'email': widget.email,
      });

      if (result.data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verification email resent to ${widget.email}'),
          ),
        );
        _startCooldown();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to resend email: $e')));
    }
  }

  void _startCooldown() {
    setState(() {
      _isCooldown = true;
      _cooldownSeconds = 30;
    });

    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_cooldownSeconds == 1) {
        timer.cancel();
        setState(() {
          _isCooldown = false;
        });
      } else {
        setState(() {
          _cooldownSeconds--;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Email Verification',
          style: GoogleFonts.poppins(color: white),
        ),
        backgroundColor: Primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_sharp),
          color: white,
          onPressed: () {
            Navigator.of(context).maybePop();
          },
        ),
      ),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              children: [
                SizedBox(height: Scaler.height(0.13, context)),
                Text(
                  _isVerified ? 'Account Verified' : 'Verify your Email',
                  style: GoogleFonts.poppins(
                    color: Primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 35.0,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20.0),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text:
                        _isVerified
                            ? 'Congratulations! Your email '
                            : "We've sent an email to ",
                    style: GoogleFonts.poppins(
                      color: Colors.grey[700],
                      fontSize: 15.0,
                    ),
                    children: [
                      TextSpan(
                        text: widget.email,
                        style: GoogleFonts.poppins(
                          color: Primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                        text:
                            _isVerified
                                ? ' has been verified.'
                                : '. Verify your account by clicking the link.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30.0),
                CustomButton(
                  onTap:
                      _isVerified
                          ? () => Navigator.pop(context, true)
                          : (_isCooldown ? null : _resendEmail),
                  height: 45.0,
                  width: Scaler.width(0.9, context),
                  fontSize: 18.0,
                  buttonName:
                      _isVerified
                          ? 'Continue'
                          : _isCooldown
                          ? 'Resend in $_cooldownSeconds s'
                          : 'Resend Email',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
