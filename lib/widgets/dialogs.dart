// ignore_for_file: use_build_context_synchronously, avoid_print, no_leading_underscores_for_local_identifiers

import 'package:bantay_72_users/firebase_services/firestore.dart';
import 'package:bantay_72_users/screens/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:scaler/scaler.dart';
import '../constants.dart';

Future<void> customDialog(
  BuildContext context, {
  required String title,
  required String content,
}) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          title,
          style: GoogleFonts.poppins(
            color: Primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(content, style: GoogleFonts.poppins()),
        actions: <Widget>[
          SizedBox(
            height: 40,
            width: Scaler.width(0.3, context),
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Primary,
                foregroundColor: Colors.white,
              ),
              child: Center(
                child: Text('Okay', style: GoogleFonts.poppins(color: white)),
              ),
            ),
          ),
        ],
      );
    },
  );
}

Future<void> redirectDialog(
  BuildContext context, {
  required String title,
  required String content,
}) async {
  await showDialog<void>(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return PopScope(
        canPop: false,
        child: AlertDialog(
          title: Text(
            title,
            style: GoogleFonts.poppins(
              color: Primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(content, style: GoogleFonts.poppins()),
          actions: <Widget>[
            SizedBox(
              height: 40,
              width: Scaler.width(0.3, context),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Return true explicitly

                  // Slight delay to allow dialog to close smoothly before navigation
                  Future.delayed(const Duration(milliseconds: 100), () {
                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HomeScreen()),
                      );
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Primary,
                  foregroundColor: white,
                ),
                child: Center(
                  child: Text('Okay', style: GoogleFonts.poppins(color: white)),
                ),
              ),
            ),
          ],
        ),
      );
    },
  ); // Return false if dialog was dismissed without pressing button
}

Future<bool> confirmationDialog(
  BuildContext context, {
  required String title,
  required String content,
}) async {
  // Use the correct return type for showDialog
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false, // User must tap a button to dismiss dialog
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          title,
          style: GoogleFonts.poppins(
            color: Primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(content, style: GoogleFonts.poppins(color: black)),
        actions: <Widget>[
          // No button
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                height: 40,
                width: Scaler.width(0.23, context),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(false); // Return false
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                  ),
                  child: Center(
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.poppins(color: white),
                    ),
                  ),
                ),
              ),

              SizedBox(width: 10),

              SizedBox(
                height: 40,
                width: Scaler.width(0.23, context),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(true); // Return true
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Primary,
                    foregroundColor: Colors.white,
                  ),
                  child: Center(
                    child: Text(
                      'Submit',
                      style: GoogleFonts.poppins(color: white),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Yes button
        ],
      );
    },
  );

  // Make sure we return a boolean value
  return result ?? false;
}

Future<bool> logoutDialog(
  BuildContext context, {
  required String title,
  required String content,
}) async {
  // Use the correct return type for showDialog
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false, // User must tap a button to dismiss dialog
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          title,
          style: GoogleFonts.poppins(
            color: Primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(content, style: GoogleFonts.poppins(color: black)),
        actions: <Widget>[
          // No button
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                height: 40,
                width: Scaler.width(0.23, context),
                child: TextButton(
                  style: TextButton.styleFrom(foregroundColor: selectedText),
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('Cancel'),
                ),
              ),

              SizedBox(width: 10),

              SizedBox(
                height: 40,
                width: Scaler.width(0.23, context),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(true); // Return true
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Primary,
                    foregroundColor: Colors.white,
                  ),
                  child: Center(
                    child: Text(
                      'Okay',
                      style: GoogleFonts.poppins(color: white),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Yes button
        ],
      );
    },
  );

  // Make sure we return a boolean value
  return result ?? false;
}

Future<String?> reauthenticationDialog(BuildContext context) async {
  final TextEditingController passwordController = TextEditingController();

  String? password;

  await showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          'Re-authentication Required',
          style: GoogleFonts.poppins(
            color: Primary,
            fontSize: 17.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Please enter your current password to proceed.',
              style: GoogleFonts.poppins(color: black),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Current Password',
                hintStyle: GoogleFonts.poppins(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ],
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                height: 40,
                width: Scaler.width(0.23, context),
                child: TextButton(
                  style: TextButton.styleFrom(foregroundColor: selectedText),
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel'),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 40,
                width: Scaler.width(0.28, context),
                child: ElevatedButton(
                  onPressed: () {
                    password = passwordController.text.trim();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Primary,
                    foregroundColor: Colors.white,
                  ),
                  child: Center(
                    child: Text(
                      'Confirm',
                      style: GoogleFonts.poppins(color: white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    },
  );

  return password?.isNotEmpty == true ? password : null;
}

Future<void> ratingsDialog(BuildContext context, String reportId) {
  double rating = 1.0;
  TextEditingController msgController = TextEditingController();
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return PopScope(
        canPop: false,
        child: AlertDialog(
          title: Text(
            "How's our service?",
            style: GoogleFonts.poppins(
              color: Primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Emergency has been completed. Kindly rate our services.',
                  style: GoogleFonts.poppins(),
                ),
                SizedBox(height: 20.0),
                Center(
                  child: RatingBar.builder(
                    initialRating: rating,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    unratedColor: unread,
                    itemBuilder:
                        (context, _) => Icon(
                          Icons.star,
                          color: const Color.fromARGB(255, 235, 219, 77),
                        ),
                    onRatingUpdate: (value) {
                      rating = value;
                    },
                  ),
                ),

                SizedBox(height: 20.0),

                Center(
                  child: Text(
                    'or leave a message below.',
                    style: GoogleFonts.poppins(),
                    textAlign: TextAlign.center,
                  ),
                ),

                SizedBox(height: 10.0),

                TextFormField(
                  controller: msgController,
                  maxLength: 50,
                  maxLines: null,
                  expands: false,
                  style: TextStyle(fontSize: 15, color: black),
                  decoration: InputDecoration(
                    label: Text(
                      'Your Message',
                      style: GoogleFonts.poppins(color: black),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Primary, width: 1),
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),

          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance
                      .collection('sos_reports')
                      .doc(reportId)
                      .update({
                        'rating': rating,
                        'feedback': msgController.text.trim(),
                      });

                  Navigator.of(context).pop(); // Close dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Thank you for your feedback!")),
                  );
                } catch (e) {
                  print("Error updating report rating: $e");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Failed to submit rating.")),
                  );
                }
              },
              child: Text('Submit', style: GoogleFonts.poppins(color: white)),
              // child: Center(
              //   child: SizedBox(
              //     width: 20,
              //     height: 20,
              //     child: CircularProgressIndicator(color: white, strokeWidth: 2),
              //   ),
              // ),
            ),
          ],
        ),
      );
    },
  );
}

Future<void> volunteersDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          'Thank you for stepping up!',
          style: GoogleFonts.poppins(
            color: Primary,
            fontWeight: FontWeight.w600,
            fontSize: 30.0,
          ),
          textAlign: TextAlign.center,
        ),
        content: Text(
          "You're officially part of this emergency! Stay safe and wait for futher instructions.",
          style: GoogleFonts.poppins(),
          textAlign: TextAlign.justify,
        ),
        actions: <Widget>[
          SizedBox(
            height: 40,
            width: Scaler.width(0.35, context),
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Primary,
                foregroundColor: Colors.white,
              ),
              child: Center(
                child: Text(
                  "Let's do this!",
                  style: GoogleFonts.poppins(color: white),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}

Future<void> showReportHistory(BuildContext context, String docId) {
  return showDialog(
    context: context,
    builder: (context) {
      return StreamBuilder<DocumentSnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('resolved_reports')
                .doc(docId)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return AlertDialog(
              content: Center(child: CircularProgressIndicator(color: Primary)),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return AlertDialog(content: Text('No report data found.'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final volunteer = data['volunteer'] == false ? 'No' : 'Yes';
          final status = data['status']
              .split(' ')
              .map(
                (word) =>
                    word.isNotEmpty
                        ? word[0].toUpperCase() +
                            word.substring(1).toLowerCase()
                        : '',
              )
              .join(' ');

          return AlertDialog(
            title: Text(
              data['incidentType'] ?? 'Incident',
              style: GoogleFonts.poppins(
                color: Primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildRichText('User: ', data['user'] ?? ''),
                  SizedBox(height: 10.0),
                  buildRichText('Phone: ', data['phone'] ?? ''),
                  SizedBox(height: 10.0),
                  buildRichText('Volunteer: ', volunteer),
                  SizedBox(height: 10.0),
                  buildRichText('Location: ', data['location'] ?? ''),
                  SizedBox(height: 10.0),
                  buildRichText('Address: ', data['address'] ?? ''),
                  SizedBox(height: 10.0),
                  buildRichText('Message: ', data['message'] ?? ''),
                  SizedBox(height: 10.0),
                  RichText(
                    text: TextSpan(
                      text: 'Status: ',
                      style: GoogleFonts.poppins(
                        color: black,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w600,
                      ),
                      children: [
                        TextSpan(
                          text: status,
                          style: GoogleFonts.poppins(
                            color: status == 'Resolved' ? completed : Primary,
                            fontSize: 18.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

Future<String?> showReportDetails(
  BuildContext context, {
  required String incident,
  required String phone,
  required String? location,
  required LatLng latlng,
  required String username,
  required String address,
  required String userId,
}) {
  bool volunteerValue = false;
  final TextEditingController msgController = TextEditingController();
  final FirestoreService _firestore = FirestoreService();
  bool isSubmitting = false;

  return showDialog<String>(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return PopScope(
            canPop: false,
            child: AlertDialog(
              title: Text(
                'Confirm Report',
                style: GoogleFonts.poppins(
                  color: Primary,
                  fontSize: 23.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildRichText('Incident Type: ', incident),
                    SizedBox(height: 8),
                    buildRichText('Phone: ', phone),
                    SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        text: 'Location: ',
                        style: GoogleFonts.poppins(
                          color: black,
                          fontSize: 18.0,
                          fontWeight: FontWeight.w600,
                        ),
                        children: [
                          TextSpan(
                            text: location ?? 'None',
                            style: GoogleFonts.poppins(
                              color: black,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'Volunteer? ',
                          style: GoogleFonts.poppins(
                            color: black,
                            fontWeight: FontWeight.w600,
                            fontSize: 18.0,
                          ),
                        ),
                        Transform.scale(
                          scale: 0.8,
                          child: Switch(
                            value: volunteerValue,
                            onChanged: (val) {
                              setState(() => volunteerValue = val);
                            },
                            activeColor: white,
                            activeTrackColor: Primary,
                            inactiveThumbColor: Colors.white,
                            inactiveTrackColor: Colors.grey,
                          ),
                        ),
                      ],
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 2,
                        vertical: 5,
                      ),
                      child: TextFormField(
                        controller: msgController,
                        maxLength: 50,
                        maxLines: null,
                        expands: false,
                        style: TextStyle(fontSize: 15, color: black),
                        decoration: InputDecoration(
                          label: Text(
                            'Your Message',
                            style: GoogleFonts.poppins(color: black),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Primary, width: 1),
                            borderRadius: BorderRadius.all(
                              Radius.circular(10.0),
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      height: 40,
                      width: Scaler.width(0.25, context),
                      child: TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: selectedText,
                        ),
                        onPressed: () => Navigator.of(context).pop('cancel'),
                        child: Text('Cancel'),
                      ),
                    ),
                    SizedBox(width: 10),
                    SizedBox(
                      height: 40,
                      width: Scaler.width(0.27, context),
                      child: ElevatedButton(
                        onPressed:
                            isSubmitting
                                ? null
                                : () async {
                                  setState(() => isSubmitting = true);

                                  try {
                                    final snapshot =
                                        await FirebaseFirestore.instance
                                            .collection('sos_reports')
                                            .where('user', isEqualTo: username)
                                            .where('userId', isEqualTo: userId)
                                            .where(
                                              'incidentType',
                                              isEqualTo: incident,
                                            )
                                            .where(
                                              'latlng',
                                              isEqualTo: GeoPoint(
                                                latlng.latitude,
                                                latlng.longitude,
                                              ),
                                            )
                                            .limit(1)
                                            .get();
                                    if (snapshot.docs.isNotEmpty) {
                                      await customDialog(
                                        context,
                                        title: 'Duplicate Reports',
                                        content:
                                            'You already submitted this report',
                                      );
                                      Navigator.of(context).pop();
                                      return;
                                    }
                                    DocumentReference docId = await _firestore
                                        .addData(
                                          context: context,
                                          collection: 'sos_reports',
                                          data: {
                                            'incidentType': incident,
                                            'userId': userId,
                                            'user': username,
                                            'phone': phone,
                                            'address': address,
                                            'volunteer': volunteerValue,
                                            'location': location,
                                            'message':
                                                msgController.text
                                                        .trim()
                                                        .isEmpty
                                                    ? 'none'
                                                    : msgController.text.trim(),
                                            'status': 'unread',
                                            'timestamp':
                                                FieldValue.serverTimestamp(),
                                            'latlng': GeoPoint(
                                              latlng.latitude,
                                              latlng.longitude,
                                            ),
                                          },
                                        );
                                    await docId.update({'docId': docId.id});

                                    if (volunteerValue == true) {
                                      await FirestoreService().addData(
                                        context: context,
                                        collection: 'volunteers',
                                        data: {
                                          'volunteerName': username,
                                          'address': address,
                                          'contactInfo': phone,
                                          'assignedIncident': incident,
                                          'date': FieldValue.serverTimestamp(),
                                          'volunteer': volunteerValue,
                                          'volunteerId': userId,
                                          'status': 'unread',
                                          'docId': docId.id,
                                        },
                                      );
                                    }

                                    Navigator.of(context).pop(
                                      volunteerValue
                                          ? 'success_volunteer'
                                          : 'success',
                                    );
                                    setState(() => isSubmitting = false);
                                  } catch (e) {
                                    setState(() => isSubmitting = false);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Failed to Submit Report',
                                        ),
                                      ),
                                    );
                                    Navigator.of(context).pop('error');

                                    print('Error: $e');
                                  }
                                },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Primary,
                          foregroundColor: Colors.white,
                        ),
                        child: Center(
                          child:
                              isSubmitting
                                  ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : Text(
                                    'Okay',
                                    style: GoogleFonts.poppins(color: white),
                                  ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

Widget buildRichText(String label, String value) {
  return RichText(
    text: TextSpan(
      text: label,
      style: GoogleFonts.poppins(
        color: black,
        fontSize: 18.0,
        fontWeight: FontWeight.w600,
      ),
      children: [
        TextSpan(
          text: value,
          style: GoogleFonts.poppins(
            color: black,
            fontSize: 18.0,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    ),
  );
}
