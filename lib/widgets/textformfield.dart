// ignore_for_file: prefer_typing_uninitialized_variables, must_be_immutable

import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants.dart';
import 'package:flutter/material.dart';

class CustomTextFormField extends StatefulWidget {
  CustomTextFormField({
    super.key,
    required this.validator,
    required this.onSaved,
    this.controller,
    this.isEmail = false,
    this.labelText,
    this.isObscure = false,
    required this.fontSize,
    required this.fontColor,
    this.hintTextSize = 17.0,
    this.hintText = '',
    this.fillColor = white,
    required this.height,
    required this.width,
    this.keyboardType = TextInputType.text,
    this.maxLength = 200,
    this.inputFormatters = const [],
    this.onChanged,
    this.prefixIcon,
    this.readonly = false,
    this.isLast = false,
  });

  final isEmail;
  final Widget? prefixIcon;
  final String? labelText;
  final validator;
  final onSaved;
  final controller;
  final isObscure;
  final fontSize;
  final fontColor;
  final double height, width;
  final hintTextSize;
  final hintText;
  final fillColor;
  final Function(String)? onChanged;
  final bool readonly;
  final bool isLast;

  TextInputType keyboardType;
  int maxLength;
  final List<TextInputFormatter> inputFormatters;

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  bool secureText = true;
  bool showClear = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_updateClearButton);
  }

  void _updateClearButton() {
    setState(() {
      showClear = widget.controller.text.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    widget.keyboardType = widget.keyboardType;
    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: TextFormField(
        onFieldSubmitted: (_) {
          if (widget.isLast) {
            FocusScope.of(context).unfocus(); // close keyboard
          } else {
            FocusScope.of(context).nextFocus(); // move to next field
          }
        }, // Move to next field
        textInputAction:
            widget.isLast ? TextInputAction.done : TextInputAction.next,
        readOnly: widget.readonly,
        validator: widget.validator,
        onSaved: widget.onSaved,
        onChanged: widget.onChanged,
        controller: widget.controller,
        obscureText: widget.isObscure ? secureText : false,
        keyboardType: widget.keyboardType,
        inputFormatters: [
          LengthLimitingTextInputFormatter(widget.maxLength),
          ...widget.inputFormatters,
        ],
        style: TextStyle(fontSize: widget.fontSize, color: widget.fontColor),
        decoration: InputDecoration(
          label:
              widget.labelText != null
                  ? Text(
                    widget.labelText!,
                    style: GoogleFonts.poppins(color: Colors.black),
                  )
                  : null,
          focusColor: white,
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Primary, width: 1),
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
          errorBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Color.fromARGB(255, 77, 68, 67),
              width: 2,
            ),
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
          errorStyle: GoogleFonts.poppins(),
          focusedErrorBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 2),
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Primary, width: 2),
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
          filled: true,
          hintStyle: GoogleFonts.poppins(
            textStyle: TextStyle(
              color: Colors.grey,
              fontSize: widget.hintTextSize,
            ),
          ),
          hintText: widget.hintText,
          fillColor: widget.fillColor,
          prefixIcon:
              widget.prefixIcon ??
              (widget.isObscure
                  ? IconButton(
                    onPressed: () {
                      setState(() {
                        secureText = !secureText;
                      });
                    },
                    icon: Icon(
                      secureText
                          ? Icons.visibility_off_rounded
                          : Icons.visibility,
                      color: Primary,
                    ),
                  )
                  : null),
          suffixIcon:
              showClear
                  ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: () => widget.controller.clear(),
                  )
                  : null,
        ),
      ),
    );
  }
}
