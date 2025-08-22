import 'package:bantay_72_users/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DataProtectionScreen extends StatelessWidget {
  const DataProtectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Data Protection Rights',
          style: GoogleFonts.poppins(color: white),
        ),
        backgroundColor: Primary,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_sharp),
          color: white, // 1
          onPressed: () {
            Navigator.of(context).maybePop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'You have the right to access, correct, or delete your personal data at any time. We comply with all applicable data protection laws to ensure your privacy and security.',
              style: GoogleFonts.poppins(fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}
