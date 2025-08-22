import 'package:bantay_72_users/screens/login.dart';
import 'package:bantay_72_users/screens/sign_up.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/button.dart';
import '../constants.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SingleChildScrollView(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 250.h,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.fill,
                      image: AssetImage("assets/images/Rectangle 6.png"),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 90.h),
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome to Bantay 72',
                          style: GoogleFonts.poppins(
                            color: white,
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "Your Community's Lifeline",
                          style: GoogleFonts.poppins(
                            color: white,
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 100.h),

          Center(
            child: Column(
              children: [
                Container(
                  width: 150.w,
                  height: 160.h,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      fit: BoxFit.fitWidth,
                      image: AssetImage("assets/images/capstoneLogo.png"),
                    ),
                  ),
                ),
                Text(
                  'Bantay 72',
                  style: GoogleFonts.rubik(
                    color: Primary,
                    fontSize: 35.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  'Alerto sa Sakuna,',
                  style: GoogleFonts.rubik(
                    color: Primary,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                Text(
                  'Kaligtasan ay Sigurado',
                  style: GoogleFonts.rubik(
                    color: Primary,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 105.h),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Column(
              children: [
                CustomButton(
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LogInScreen()),
                      ),
                  fontSize: 18.sp,
                  height: 50.h,
                  width: double.infinity,
                  buttonName: 'Login',
                ),
            
                SizedBox(height: 5.h),
            
                CustomButton(
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignUpScreen()),
                      ),
                  fontSize: 18.sp,
                  height: 50.h,
                  width: double.infinity,
                  buttonName: 'Register',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
