import 'package:bantay_72_users/constants.dart';
import 'package:bantay_72_users/screens/about.dart';
import 'package:bantay_72_users/screens/account_details.dart';
import 'package:bantay_72_users/screens/home.dart';
import 'package:bantay_72_users/screens/settings.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Account', style: GoogleFonts.rubik(color: white)),
        backgroundColor: Primary,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_sharp),
          color: white, // 1
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 30.0),
        children: [
          _buildMenuItem(context, 'Account Details', AccountDetailsScreen()),
          const SizedBox(height: 32),
          _buildMenuItem(context, 'Settings', SettingsScreen()),
          const SizedBox(height: 32),
          _buildMenuItem(context, 'About', AboutScreen()),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, String title, Widget screen) {
    return ListTile(
      title: Text(title, style: GoogleFonts.poppins(color: black, fontSize: 20.0, fontWeight: FontWeight.w400)),
      trailing: const Icon(Icons.arrow_forward_sharp),
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => screen),
          ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
    );
  }
}
