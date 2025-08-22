import 'package:bantay_72_users/constants.dart';
import 'package:bantay_72_users/widgets/dialogs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/elusive_icons.dart';
import 'package:fluttericon/rpg_awesome_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Icon getEmergencyIcon(String type) {
      switch (type.toLowerCase()) {
        case 'fire':
          return Icon(Elusive.fire, color: Primary, size: 40);
        case 'accident':
          return Icon(FontAwesomeIcons.carBurst, color: Primary, size: 40);
        case 'rescue':
          return Icon(Icons.safety_divider_rounded, color: Primary, size: 40);
        case 'medical':
          return Icon(Icons.medical_services_rounded, color: Primary, size: 40);
        case 'violence':
          return Icon(RpgAwesome.dripping_knife, color: Primary, size: 40);
        default:
          return Icon(Icons.flood_rounded, color: Primary, size: 40);
      }
    }

    final User? user = FirebaseAuth.instance.currentUser;
    // print('Current user ID: ${user?.uid}');

    return Scaffold(
      appBar: AppBar(
        title: Text('History', style: GoogleFonts.rubik(color: white)),
        backgroundColor: Primary,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_sharp),
          color: white, // 1
          onPressed: () {
            Navigator.of(context).maybePop();
          },
        ),
      ),

      body:
          user == null
              ? Center(child: Text('Not logged in'))
              : StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('resolved_reports')
                        .where('userId', isEqualTo: user.uid)
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Something went wrong'));
                  }

                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final reports = snapshot.data!.docs;

                  if (reports.isEmpty) {
                    return Center(
                      child: Text(
                        'No reports made',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w400),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: reports.length,
                    itemBuilder: (context, index) {
                      final report =
                          reports[index].data() as Map<String, dynamic>;
                      final incident = report['incidentType']
                          .split(' ')
                          .map(
                            (word) =>
                                word.isNotEmpty
                                    ? word[0].toUpperCase() +
                                        word.substring(1).toLowerCase()
                                    : '',
                          )
                          .join(' ');
                      final timestamp = report['timestamp'];
                      final date = (timestamp as Timestamp).toDate();
                      final formattedDate = DateFormat(
                        'MMMM d, y',
                      ).format(date);
                      final location = report['location'];
                      final docId = reports[index].id;
                      final status = report['status']
                          .split(' ')
                          .map(
                            (word) =>
                                word.isNotEmpty
                                    ? word[0].toUpperCase() +
                                        word.substring(1).toLowerCase()
                                    : '',
                          )
                          .join(' ');
                      return Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 28.0,
                          vertical: 8.0,
                        ),
                        child: GestureDetector(
                          onTap: () => showReportHistory(context, docId),
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      getEmergencyIcon(incident),
                                      SizedBox(width: 20.0),
                                      Text(
                                        '$incident',
                                        style: GoogleFonts.poppins(
                                          color: black,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 17.0,
                                        ),
                                      ),

                                      Spacer(),

                                      Text(
                                        status,
                                        style: GoogleFonts.poppins(
                                          color:
                                              status == 'Resolved'
                                                  ? completed
                                                  : Primary,
                                          fontSize: 13.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: 15.0),

                                  Text(
                                    '$incident emergency at $location',
                                    style: GoogleFonts.poppins(
                                      color: const Color.fromARGB(186, 0, 0, 0),
                                    ),
                                  ),

                                  SizedBox(height: 18.0),

                                  Row(
                                    children: [
                                      Text(
                                        formattedDate,
                                        style: GoogleFonts.poppins(
                                          color: black,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Spacer(),
                                      Icon(
                                        Icons.arrow_forward_sharp,
                                        color: black,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
    );
  }
}
