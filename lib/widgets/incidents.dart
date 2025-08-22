// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:bantay_72_users/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scaler/scaler.dart';

class IncidentsButton extends StatelessWidget {
  final bool pressed;
  final VoidCallback onTap;
  // final double height;
  // final double width;
  final double fontSize;
  final String buttonName;
  final FontWeight fontWeight;
  final Color bgColor;
  final Color fontColor;
  final Color selectedButt;
  final Color selectedButtText;
  final Icon icon;

  const IncidentsButton({
    super.key,
    required this.onTap,
    // this.height = 70,
    // this.width = 205,
    this.fontSize = 20.0,
    required this.buttonName,
    this.fontWeight = FontWeight.w500,
    this.bgColor = white,
    this.fontColor = black,
    this.selectedButt = selected,
    this.selectedButtText = selectedText,
    required this.icon,
    this.pressed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: pressed ? selectedButt : bgColor,
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: Scaler.height(0.09, context),
          width: Scaler.width(0.4, context),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(120)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              icon,
              Text(
                buttonName,
                style: GoogleFonts.poppins(
                  color: pressed ? selectedButtText : fontColor,
                  fontSize: fontSize,
                  fontWeight: fontWeight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
