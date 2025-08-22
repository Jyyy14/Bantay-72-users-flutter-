// ignore_for_file: unused_import
import '../constants.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';


void negateToast(BuildContext context, {required String message}) {
  FToast fToast = FToast();
  fToast.init(context); // Requires context to work properly

  Widget toast = Container(
    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(25.0),
      color: const Color.fromARGB(255, 95, 95, 95),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.info, color: white),
        const SizedBox(width: 12.0),
        Text(
          message,
          style: const TextStyle(color: white),
        ),
      ],
    ),
  );

  fToast.showToast(
    child: toast,
    gravity: ToastGravity.TOP,
    toastDuration: const Duration(seconds: 2),
  );
}

void approvedToast(BuildContext context, {required String message}){
  FToast fToast = FToast();
  fToast.init(context); // Requires context to work properly

  Widget toast = Container(
    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(25.0),
      color: Colors.green,
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check, color: white),
        const SizedBox(width: 12.0),
        Text(
          message,
          style: const TextStyle(color: white),
        ),
      ],
    ),
  );

  fToast.showToast(
    child: toast,
    gravity: ToastGravity.TOP,
    toastDuration: const Duration(seconds: 2),
  );
}

