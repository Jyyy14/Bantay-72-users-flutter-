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
  final Widget? leading;
  final Color? iconColor;
  final bool hasLeading;
  final bool? hasBorder;
  final FontWeight fontWeight;
  final Color bgColor;
  final Color fontColor;
  final Color splashColor;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.onTap,
    required this.height,
    required this.width,
    required this.buttonName,
    this.splashColor = Secondary,
    this.bgColor = Primary,
    this.fontColor = white,
    this.hasBorder = false,
    this.iconColor,
    this.fontSize = 18.0,
    this.leading,
    this.fontWeight = FontWeight.w500,
    this.hasLeading = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onTap == null;

    return Opacity(
      opacity: isDisabled ? 0.6 : 1.0, // 👈 Dims the entire button
      child: Card(
        color: isDisabled ? Colors.grey[400] : bgColor,
        child: InkWell(
          onTap: isDisabled ? null : onTap,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          splashColor: splashColor, // isGmail
          //     ? const Color.fromARGB(151, 0, 0, 0)
          //     : isDisabled
          //     ? Colors.transparent
          //     : Secondary,
          child: Container(
            height: height,
            width: width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              border: hasBorder == true ? Border.all(color: Colors.black) : null,
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
                      : hasLeading && leading != null
                      ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Transform.scale(
                            scale: 0.6,
                            child: leading!,
                          ),
                          Text(
                            buttonName,
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: fontSize,
                              fontWeight: fontWeight,
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
