// ignore_for_file: avoid_print

import 'package:bantay_72_users/firebase_options.dart';
import 'package:bantay_72_users/firebase_services/notifications.dart';
import 'package:bantay_72_users/screens/choose_loc.dart';
import 'package:bantay_72_users/screens/generate_report.dart';
import 'package:bantay_72_users/screens/get_started.dart';
import 'package:bantay_72_users/screens/home.dart';
import 'package:bantay_72_users/screens/location.dart';
import 'package:bantay_72_users/screens/login.dart';
import 'package:bantay_72_users/screens/sign_up.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  // OneSignal.initialize("6e3a6f14-4506-41de-b9d7-a9eebb9be59c");
  // OneSignal.Notifications.requestPermission(true);
  await NotificationsService.instance.initialize();
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(411, 891), // Set this based on your Figma/mobile design
      minTextAdapt: true,
      splitScreenMode: true,
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Bantay 72',
        routerConfig: _router,
      ),
    );
  }

  final GoRouter _router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => GetStartedScreen()),
      GoRoute(path: '/login', builder: (context, state) => LogInScreen()),
      GoRoute(path: '/signup', builder: (context, state) => SignUpScreen()),
      GoRoute(
        path: '/location',
        builder: (context, state) => EnableLocationScreen(),
      ),
      GoRoute(path: '/home', builder: (context, state) => HomeScreen()),
      GoRoute(
        path: '/report',
        builder: (context, state) => ReportEmergencyScreen(),
      ),
      GoRoute(
        path: '/maps_report',
        builder: (context, state) => ChooseLocScreen(),
      ),
    ],
  );
}
