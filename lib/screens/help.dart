import 'package:bantay_72_users/constants.dart';
import 'package:bantay_72_users/screens/generate_report.dart';
import 'package:bantay_72_users/screens/notifications.dart';
import 'package:bantay_72_users/widgets/dialogs.dart';
import 'package:bantay_72_users/widgets/status_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:scaler/scaler.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  static const statuses = [
    'ongoing',
    'arrived',
    'on the way',
    'validated',
    'unread',
    'completed',
  ];
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      customDialog(
        context,
        title: 'Use this app responsibly',
        content:
            'Sending false emergency reports is a serious offense. Misuse of the HELP button or fake emergency alerts may result in legal consequences, including fines or imprisonment under the law. ',
        titleFontSize: 20.0.sp,
        textCenter: true,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Bantay 72',
            style: GoogleFonts.radioCanada(
              color: white,
              fontSize: 25.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: Primary,
          leading: Transform.scale(
            scale: 0.6,
            child: Image.asset('assets/images/capstoneLogo.png'),
          ),
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(18.w),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Primary),
            ),
          ),
        ),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('users')
              .doc(user?.uid)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            backgroundColor: white,
            body: Center(
              child: const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Primary),
              ),
            ),
          );
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final username = userData['username'] ?? 'No username';

        return Scaffold(
          resizeToAvoidBottomInset: true,
          body: _buildHomeContent(username),
        );
      },
    );
  }

  Widget _buildHomeContent(String username) {
    const statuses = [
      'ongoing',
      'arrived',
      'on the way',
      'validated',
      'unread',
      'completed',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bantay 72',
          style: GoogleFonts.rubik(
            color: white,
            fontSize: 25.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Primary,
        leading: Transform.scale(
          scale: 0.6,
          child: Image.asset('assets/images/capstoneLogo.png'),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationsScreen()),
              );
            },
            icon: Icon(Icons.notifications_active_sharp, color: white),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('sos_reports')
                .where('userId', isEqualTo: user?.uid)
                .where('status', whereIn: statuses)
                .snapshots(),
        builder: (context, snapshot) {
          final reportCount = snapshot.data?.docs.length ?? 0;
          final isDisabled = reportCount >= 3;

          return SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 35.h),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isDisabled
                                  ? 'You have reached the reports limit.'
                                  : 'Help is just a click away',
                              style: GoogleFonts.poppins(
                                color: black,
                                fontSize: isDisabled ? 22.sp : 25.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                text:
                                    isDisabled
                                        ? 'Wait for other reports to be'
                                        : 'Tap',
                                style: GoogleFonts.poppins(
                                  color: black,
                                  fontSize: isDisabled ? 22.sp : 25.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                                children: [
                                  TextSpan(
                                    text:
                                        isDisabled
                                            ? ' Resolved.'
                                            : ' Help button ',
                                    style: GoogleFonts.poppins(
                                      color: isDisabled ? completed : Primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: isDisabled ? 22.sp : 25.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 50.h),

                        AbsorbPointer(
                          absorbing: isDisabled,
                          child: Opacity(
                            opacity: isDisabled ? 0.5 : 1.0,
                            child: GestureDetector(
                              onTap: () async {
                                if (mounted) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => ReportEmergencyScreen(),
                                    ),
                                  );
                                }
                              },
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  ClipOval(
                                    child: Transform.scale(
                                      scale: 1.2,
                                      child: Lottie.asset(
                                        'assets/animation/sos.json',
                                        animate: false, // 👈 disables animation
                                        repeat: false,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'Help',
                                    style: GoogleFonts.poppins(
                                      color: white,
                                      fontSize: 40.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 30.h),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 25.w),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: ReportStatusBar(),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
