import 'package:bantay_72_users/constants.dart';
import 'package:bantay_72_users/firebase_services/firestore.dart';
import 'package:bantay_72_users/screens/about.dart';
import 'package:bantay_72_users/screens/account_details.dart';
import 'package:bantay_72_users/screens/history.dart';
import 'package:bantay_72_users/screens/home.dart';
import 'package:bantay_72_users/screens/settings.dart';
import 'package:bantay_72_users/widgets/button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scaler/scaler.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirestoreService _firestore = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> _fetchUsername() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    // 🔥 Fetch from Firestore using your service
    final doc = await _firestore.fetchDocument(
      context: context,
      collection: "users",
      docId: user.uid, // Assuming userId is the document ID
    );

    if (doc != null && doc.exists) {
      return doc['username'] as String?;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Account', style: GoogleFonts.rubik(color: white)),
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 20.0,
              horizontal: 18.0,
            ),
            child: FutureBuilder<String?>(
              future: _fetchUsername(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data == null) {
                  return Text('No username found');
                } else {
                  return _buildEditProfile(
                    context,
                    snapshot.data!,
                    AccountDetailsScreen(),
                  );
                }
              },
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 10.0,
                horizontal: 25.0,
              ),
              child: ListView(
                children: [
                  _buildMenuItem(context, 'Report History', HistoryScreen()),
                  const SizedBox(height: 10.0),
                  _buildMenuItem(context, 'Settings', SettingsScreen()),
                  const SizedBox(height: 10.0),
                  _buildMenuItem(context, 'About', AboutScreen()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, String title, Widget screen) {
    return ListTile(
      title: Text(
        title,
        style: GoogleFonts.poppins(
          color: black,
          fontSize: 20.0,
          fontWeight: FontWeight.w400,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_sharp),
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => screen),
          ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
    );
  }

  Widget _buildEditProfile(BuildContext context, String title, Widget screen) {
    return SizedBox(
      height: 110,
      width: double.infinity,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.account_circle,
                    size: 45.0,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 12.0),
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: black,
                      fontSize: 20.0,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),

              CustomButton(
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => screen),
                    ),
                height: Scaler.height(0.05, context),
                width: Scaler.width(0.18, context),
                buttonName: 'Profile',
                fontSize: 13.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
