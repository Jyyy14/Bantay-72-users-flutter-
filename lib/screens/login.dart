import 'package:bantay_72_users/constants.dart';
import 'package:bantay_72_users/firebase_services/firebase_auth.dart';
import 'package:bantay_72_users/screens/home.dart';
import 'package:bantay_72_users/screens/reset_password.dart';
import 'package:bantay_72_users/screens/sign_up.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // <-- changed
import '../widgets/button.dart';
import '../widgets/textformfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/dialogs.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final FirebaseAuthService _auth = FirebaseAuthService();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 250.h,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.fill,
                          image: AssetImage("assets/images/Rectangle 6.png"),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(15.w),
                      child: Row(
                        children: [
                          Container(
                            width: 0.08.sw,
                            height: 0.08.sw,
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                fit: BoxFit.fitWidth,
                                image: AssetImage(
                                  "assets/images/capstoneLogo.png",
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 13.w),
                          Text(
                            'Bantay 72',
                            style: GoogleFonts.poppins(
                              color: white,
                              fontSize: 25.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 130.h),
                      child: Center(
                        child: Text(
                          'Login',
                          style: GoogleFonts.radioCanada(
                            color: white,
                            fontSize: 45.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 30.h),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 28.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextFormField(
                        labelText: 'Email',
                        controller: emailController,
                        prefixIcon: Icon(
                          Icons.mail,
                          color: const Color.fromARGB(144, 0, 0, 0),
                        ),
                        isEmail: true,
                        validator:
                            (value) =>
                                value!.isEmpty ? 'Enter your email' : null,
                        onSaved: (value) => emailController.text = value!,
                        fontSize: 17.sp,
                        fontColor: Colors.black,
                        height: 0.1.sh,
                        width: double.infinity,
                      ),

                      CustomTextFormField(
                        isLast: true,
                        controller: passwordController,
                        labelText: 'Password',
                        isObscure: true,
                        validator:
                            (value) =>
                                value!.isEmpty ? 'Enter your password' : null,
                        onSaved: (value) => passwordController.text = value!,
                        fontSize: 17.sp,
                        fontColor: black,
                        height: 0.1.sh,
                        width: double.infinity,
                      ),

                      GestureDetector(
                        onTap:
                            () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ResetPasswordScreen(),
                              ),
                            ),
                        child: Text(
                          'Forgot password?',
                          style: GoogleFonts.poppins(
                            color: Primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      SizedBox(height: 40.h),

                      CustomButton(
                        onTap: _login,
                        fontSize: 18.sp,
                        height: 58.h,
                        width: double.infinity,
                        buttonName: 'Login',
                      ),

                      SizedBox(height: 8.h),

                      GestureDetector(
                        onTap:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignUpScreen(),
                              ),
                            ),
                        child: Center(
                          child: Text(
                            'Create new Account',
                            style: GoogleFonts.poppins(
                              color: Primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15.0),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Divider(
                                color: Colors.grey,
                                thickness: 1,
                                endIndent: 10, // space between line and text
                              ),
                            ),
                            Text(
                              "or",
                              style: TextStyle(
                                color: black,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Expanded(
                              child: Divider(
                                color: Colors.grey,
                                thickness: 1,
                                indent: 10, // space between text and line
                              ),
                            ),
                          ],
                        ),
                      ),

                      CustomButton(
                        bgColor: white,
                        fontColor: black,
                        hasBorder: true,
                        splashColor: Colors.grey[300]!,
                        fontWeight: FontWeight.w500,
                        onTap: () {},
                        hasLeading: true,
                        leading: Image.asset('assets/images/google.png'),
                        // () {
                        //   _proceedToVerify();
                        // },
                        // () => Navigator.push(
                        //   context,
                        //   MaterialPageRoute(builder: (context) => VerificationScreen()),
                        // ),
                        height: 58.0,
                        fontSize: 16.0,
                        width: double.infinity,
                        buttonName: 'Sign in with Google',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      await customDialog(
        context,
        title: 'Error',
        content: 'All fields are required to continue',
      );
      return;
    }

    User? user = await _auth.signInWithEmailandPassword(
      context,
      emailController.text,
      passwordController.text,
    );

    if (user != null) {
      emailController.clear();
      passwordController.clear();

      await customDialog(
        context,
        title: 'Success',
        content: 'User successfully logged in!',
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
    }
  }
}
