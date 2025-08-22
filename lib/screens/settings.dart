// ignore_for_file: use_build_context_synchronously

import 'package:bantay_72_users/constants.dart';
import 'package:bantay_72_users/screens/contact_support.dart';
import 'package:bantay_72_users/screens/get_started.dart';
import 'package:bantay_72_users/screens/terms_privacy.dart';
import 'package:bantay_72_users/widgets/button.dart';
import 'package:bantay_72_users/widgets/dialogs.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _locationSharing = false;
  bool _appNotifications = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: GoogleFonts.poppins(color: white)),
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
        padding: EdgeInsets.symmetric(horizontal: 20.0.w),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  SizedBox(height: 20.h),

                  Text(
                    'Privacy & Security',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 16.0,
                    ),
                  ),

                  SizedBox(height: 15.0.h),

                  _buildSettingsCard(
                    title: 'Location Sharing',
                    content: 'Share location during emergencies',
                    button: Switch(
                      value: _locationSharing,
                      onChanged: (val) {
                        setState(() => _locationSharing = val);
                      },
                      activeColor: white,
                      activeTrackColor: Primary,
                      inactiveThumbColor: white,
                      inactiveTrackColor: unread,
                    ),
                  ),

                  SizedBox(height: 6.0),

                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 15.0.h),
                    child: Text(
                      'Notifications',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 16.0.sp,
                      ),
                    ),
                  ),

                  SizedBox(height: 6.0.h),

                  _buildSettingsCard(
                    title: 'App Notifications',
                    content: 'Updates and Reminders',
                    button: Switch(
                      value: _appNotifications,
                      onChanged: (val) {
                        setState(() => _appNotifications = val);
                      },
                      activeColor: white,
                      activeTrackColor: Primary,
                      inactiveThumbColor: white,
                      inactiveTrackColor: unread,
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 15.0.h),
                    child: Text(
                      'Help & Support',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 16.0.sp,
                      ),
                    ),
                  ),

                  SizedBox(height: 6.0.h),

                  GestureDetector(
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ContactSupportScreen(),
                          ),
                        ),
                    child: _buildSettingsCard(
                      title: 'Contact Support',
                      content: '',
                      button: IconButton(
                        icon: Icon(Icons.arrow_forward_sharp),
                        color: black, // 1
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ContactSupportScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  SizedBox(height: 6.0.h),

                  GestureDetector(
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TermsPrivacyScreen(),
                          ),
                        ),
                    child: _buildSettingsCard(
                      title: 'Terms & Privacy Policy',
                      content: '',
                      button: IconButton(
                        icon: Icon(Icons.arrow_forward_sharp),
                        color: black, // 1
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TermsPrivacyScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Container(
              color: Colors.white,
              padding: const EdgeInsets.only(top: 10.0),
              child: CustomButton(
                onTap: () => _handleLogOut(context),
                height: 45.0,
                width: double.infinity,
                buttonName: 'Logout',
              ),
            ),

            SizedBox(height: 70.0.h),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogOut(BuildContext context) async {
    final shouldLogout = await logoutDialog(
      context,
      title: 'Confirm Logout',
      content: 'Are you sure you want to log out?',
    );

    if (shouldLogout) {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const GetStartedScreen()),
      );
    }
    // Prevent popping the screen
  }

  Widget _buildSettingsCard({
    required String title,
    required String content,
    required Widget button,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (content.isNotEmpty) ...[
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: black,
                      fontSize: 15.0.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5.0),
                  Text(
                    content,
                    style: TextStyle(
                      color: black,
                      fontSize: 12.0.sp,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ] else ...[
                  Center(
                    child: Text(
                      title,
                      style: GoogleFonts.poppins(
                        color: black,
                        fontSize: 15.0.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),

            button,
          ],
        ),
      ),
    );
  }
}
