// ignore_for_file: use_build_context_synchronously

import 'package:bantay_72_users/constants.dart';
import 'package:bantay_72_users/screens/emergency_screen.dart';
import 'package:bantay_72_users/screens/generate_report.dart';
import 'package:bantay_72_users/screens/get_started.dart';
import 'package:bantay_72_users/screens/help.dart';
import 'package:bantay_72_users/screens/history.dart';
import 'package:bantay_72_users/screens/notifications.dart';
import 'package:bantay_72_users/screens/profile_screen.dart';
import 'package:bantay_72_users/widgets/button.dart';
import 'package:bantay_72_users/widgets/dialogs.dart';
import 'package:bantay_72_users/widgets/status_bar.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final User? user = FirebaseAuth.instance.currentUser;
  final items = <Widget>[
    Icon(Icons.home),
    Icon(Icons.report),
    Icon(Icons.warning),
    Icon(Icons.person),
  ];
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String getGreeting() {
    final now = DateTime.now();
    final hour = now.hour;
    final minute = now.minute;

    if (hour >= 5 && (hour < 9 || (hour == 9 && minute <= 30))) {
      return "umaga"; // 5:00am - 9:30am
    } else if (hour >= 10 && hour < 14) {
      return "tanghali"; // 10:00am - 1:59pm
    } else if (hour >= 14 && hour < 18) {
      return "hapon"; // optional: 2:00pm - 5:59pm
    } else {
      return "gabi"; // 6:00pm - 4:59am
    }
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
          body: IndexedStack(
            index: _selectedIndex,
            children: [
              _buildHomeContent(username),
              HelpScreen(),
              const EmergencyScreen(),
              const ProfileScreen(),
            ],
          ),
          bottomNavigationBar: Theme(
            data: Theme.of(
              context,
            ).copyWith(iconTheme: IconThemeData(color: white)),
            child: CurvedNavigationBar(
              buttonBackgroundColor: Primary,
              backgroundColor: Colors.transparent,
              color: Primary,
              index: _selectedIndex,
              height: 60.h,
              onTap: _onTappedBar,
              items: items,
            ),
          ),
        );
      },
    );
  }

  Future<bool> _handleBackPress(BuildContext context) async {
    final shouldLogout = await logoutDialog(
      context,
      title: 'Confirm Logout',
      content: 'Are you sure you want to log out?',
    );

    if (shouldLogout) {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => GetStartedScreen()),
      );
    }

    return shouldLogout;
    // Prevent popping the screen
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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _handleBackPress(context);
        }
      },
      child: Scaffold(
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
                  MaterialPageRoute(
                    builder: (context) => NotificationsScreen(),
                  ),
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
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 35.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30.w),
                    child: Column(
                      children: [
                        Text.rich(
                          TextSpan(
                            text: 'Magandang ${getGreeting()}, ',
                            style: GoogleFonts.poppins(
                              color: black,
                              fontWeight: FontWeight.w600,
                              fontSize: 30.sp,
                            ),
                            children: [
                              TextSpan(
                                text: '$username!',
                                style: GoogleFonts.poppins(
                                  color: Primary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 30.sp,
                                ),
                              ),
                            ],
                          ),
                          softWrap: true,
                          maxLines: 2,
                          overflow:
                              TextOverflow
                                  .ellipsis, // optional: avoids layout breaking
                        ),

                        const SizedBox(height: 35),

                        SizedBox(
                          width: double.infinity,
                          child: Card(
                            shape: RoundedRectangleBorder(
                              side: BorderSide(color: black, width: 1.5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Your report matters!',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),

                                  const SizedBox(height: 4.0),

                                  Text(
                                    'Report any concerns in your area for a safer community!',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),

                                  const SizedBox(height: 14.0),

                                  Row(
                                    children: [
                                      Expanded(
                                        child: CustomButton(
                                          onTap: () =>  Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (context) =>
                                                          HistoryScreen(),
                                                ),
                                              ),
                                          height: 45,
                                          width: double.infinity,
                                          buttonName: 'View Reports',
                                          fontSize: 14.sp,
                                        ),
                                      ),

                                      Expanded(
                                        child: CustomButton(
                                          onTap:
                                              () => Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (context) =>
                                                          ReportEmergencyScreen(),
                                                ),
                                              ),
                                          height: 45,
                                          width: double.infinity,
                                          buttonName: 'Report an issue',
                                          fontSize: 14.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Discover Latest News',
                              style: GoogleFonts.poppins(
                                color: black,
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const SizedBox(height: 4.0),

                            Text(
                              'Latest news and updates in Barangay 72',
                              style: GoogleFonts.poppins(
                                color: black,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w400,
                              ),
                            ),

                            const SizedBox(height: 20),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.asset('assets/images/news.png'),
                                ),

                                const SizedBox(height: 12),

                                Text(
                                  'COMMUNITY',
                                  style: GoogleFonts.poppins(
                                    color: Primary,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                Text(
                                  'Barangay 72 holds community clean-up drive',
                                  style: GoogleFonts.poppins(
                                    color: black,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // Padding(
                  //   padding: EdgeInsets.symmetric(horizontal: 25.w),
                  //   child: Align(
                  //     alignment: Alignment.bottomCenter,
                  //     child: ReportStatusBar(),
                  //   ),
                  // ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _onTappedBar(int value) {
    setState(() {
      _selectedIndex = value;
    });
    _pageController.animateToPage(
      value,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}
