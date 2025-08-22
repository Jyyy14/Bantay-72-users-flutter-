// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../constants.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback? onTap;
  final double height;
  final double width;
  final double fontSize;
  final String buttonName;
  final Icon icon;
  final bool isGmail;
  final FontWeight fontWeight;
  final Color bgColor;
  final Color fontColor;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.onTap,
    required this.height,
    required this.width,
    required this.buttonName,
    this.bgColor = Primary,
    this.fontColor = white,
    this.fontSize = 18.0,
    this.icon = const Icon(null),
    this.fontWeight = FontWeight.w500,
    this.isGmail = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onTap == null;

    return Opacity(
      opacity: isDisabled ? 0.6 : 1.0, // 👈 Dims the entire button
      child: Card(
        color:
            isGmail
                ? white
                : isDisabled
                ? Colors.grey[400]
                : bgColor,
        elevation: 3,
        child: InkWell(
          onTap: isDisabled ? null : onTap,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          splashColor:
              isGmail
                  ? const Color.fromARGB(151, 0, 0, 0)
                  : isDisabled
                  ? Colors.transparent
                  : Secondary,
          child: Container(
            height: height,
            width: width,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: Center(
              child:
                  isLoading
                      ? const SizedBox(
                        height: 24.0,
                        width: 24.0,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(Primary),
                        ),
                      )
                      : isGmail
                      ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Transform.scale(
                            scale: 0.75,
                            child: Icon(
                              FontAwesomeIcons.google,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 10.0),
                          Text(
                            buttonName,
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: fontSize,
                            ),
                          ),
                        ],
                      )
                      : Text(
                        buttonName,
                        style: GoogleFonts.poppins(
                          color: isDisabled ? Colors.black45 : fontColor,
                          fontSize: fontSize,
                          fontWeight: fontWeight,
                        ),
                      ),
            ),
          ),
        ),
      ),
    );
  }
}
