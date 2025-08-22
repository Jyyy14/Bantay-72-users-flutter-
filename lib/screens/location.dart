// ignore_for_file: use_build_context_synchronously

import 'package:bantay_72_users/constants.dart';
import 'package:bantay_72_users/widgets/button.dart';
import 'package:bantay_72_users/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scaler/scaler.dart';
import 'package:permission_handler/permission_handler.dart';

class EnableLocationScreen extends StatefulWidget {
  const EnableLocationScreen({super.key});

  @override
  State<EnableLocationScreen> createState() => _EnableLocationScreenState();
}

class _EnableLocationScreenState extends State<EnableLocationScreen> {
  Future<void> checkPermission(BuildContext context) async {
    bool? userResponse = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Allow Location Permission"),
        content: Text("This app needs access to your location. Do you want to allow it?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // User denies
            child: Text("Deny"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // User allows
            child: Text("Allow"),
          ),
        ],
      ),
    );

    if (userResponse == true) {
      final status = await Permission.location.request();

      if (status.isGranted) {
        approvedToast(context, message: 'Permission Granted');
        context.go('/home');

      } else {
        negateToast(context, message: 'Permission Denied');
      }
    } else {
      negateToast(context, message: 'Permission Denied');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage("assets/images/Rectangle 6.png"),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 90),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: Scaler.width(0.1, context),
                      height: Scaler.height(0.1, context),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.fitWidth,
                          image: AssetImage("assets/images/capstone_logo.png"),
                        ),
                      ),
                    ),
                    SizedBox(width: 13),
                    Text(
                      'Bantay 72',
                      style: GoogleFonts.radioCanada(
                        color: white,
                        fontSize: 45,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          Spacer(),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Transform.scale(
                scale: 2.5,
                child: Icon(Icons.location_on, color: Secondary),
              ),
              SizedBox(width: 25),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Track yourself.",
                    style: GoogleFonts.poppins(
                      color: Primary,
                      fontSize: 25,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    "\tPlease allow location permission.",
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  )
                ],
              ),
            ],
          ),
          Spacer(),
          Column(
            children: [
              CustomButton(
                onTap: () => checkPermission(context),
                height: 45,
                width: Scaler.width(0.8, context),
                fontSize: 16,
                buttonName: 'Allow',
              ),
              SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  context.go('/home');
                },
                child: Text(
                  'Skip for now',
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),

              SizedBox(height: 40,),
            ],
          ),
        ],
      ),
    );
  }
}
