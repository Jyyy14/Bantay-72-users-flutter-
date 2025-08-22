// ignore_for_file: use_build_context_synchronously, unnecessary_cast

import 'package:bantay_72_users/constants.dart';
import 'package:bantay_72_users/screens/status_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttericon/elusive_icons.dart';
import 'package:fluttericon/rpg_awesome_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class ReportStatusBar extends StatelessWidget {
  const ReportStatusBar({super.key});

  static const List<String> statuses = [
    'ongoing',
    'arrived',
    'on the way',
    'validated',
    'unread',
    'completed',
    'resolved',
  ];

  Icon _getEmergencyIcon(String type) {
    switch (type.toLowerCase()) {
      case 'fire':
        return Icon(Elusive.fire, color: white, size: 30);
      case 'accident':
        return Icon(FontAwesomeIcons.carBurst, color: white, size: 30);
      case 'rescue':
        return Icon(Icons.safety_divider_rounded, color: white, size: 30);
      case 'medical':
        return Icon(Icons.medical_services_rounded, color: white, size: 30);
      case 'violence':
        return Icon(RpgAwesome.dripping_knife, color: white, size: 30);
      default:
        return Icon(Icons.flood_rounded, color: white, size: 30);
    }
  }

  Widget _statusBarBuilder(String type, String status) {
    final propercase = status
        .split(' ')
        .map(
          (word) =>
              word.isNotEmpty
                  ? word[0].toUpperCase() + word.substring(1).toLowerCase()
                  : '',
        )
        .join(' ');

    final bgColor =
        status == 'unread'
            ? unread
            : status == 'validated'
            ? Secondary
            : status == 'completed'
            ? completed
            : const Color.fromARGB(255, 243, 141, 39);

    // final iconColor =
    //     (status == 'unread' || status == 'validated') ? white : Primary;

    // final icon = _getEmergencyIcon(type, white);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(7),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          _getEmergencyIcon(type),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              "Report status: $propercase",
              style: GoogleFonts.poppins(
                color: white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: white),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return const SizedBox.shrink();

    return StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('sos_reports')
              .where('userId', isEqualTo: currentUser.uid)
              .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }

        final report = snapshot.data!.docs.where((doc) {
          final status = doc['status'] ?? '';
          return status != 'resolved';
        });

        if (report.isEmpty) return const SizedBox.shrink();
        final firstReport = report.first;
        final status = (firstReport['status'] ?? 'Pending');
        final incidentType = (firstReport['incidentType'] ?? 'unknown');
        final docId = firstReport.id;

        return GestureDetector(
          onTap: () {
            if (report.length >= 2) {
              showModalBottomSheet(
                enableDrag: false,
                useSafeArea: true,
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                isScrollControlled: true,
                builder: (context) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: DraggableScrollableSheet(
                      expand: false,
                      initialChildSize: 0.5,
                      maxChildSize: 1,
                      minChildSize: 0.3,
                      builder: (context, scrollController) {
                        return StreamBuilder<QuerySnapshot>(
                          stream:
                              FirebaseFirestore.instance
                                  .collection('sos_reports')
                                  .where('userId', isEqualTo: currentUser.uid)
                                  .where('status', whereIn: statuses)
                                  .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Center(child: CircularProgressIndicator());
                            }

                            final docs = snapshot.data!.docs;

                            if (docs.length < 2) {
                              // Optional: close sheet if less than 2 reports now
                              Navigator.pop(context);
                              return SizedBox.shrink();
                            }

                            return ListView.builder(
                              controller: scrollController,
                              itemCount: docs.length + 1,
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                      top: 16.0,
                                      bottom: 20.0,
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Reports',
                                        style: GoogleFonts.poppins(
                                          fontSize: 25.0,
                                          fontWeight: FontWeight.w600,
                                          color: Primary,
                                        ),
                                      ),
                                    ),
                                  );
                                }

                                final data =
                                    docs[index - 1].data()
                                        as Map<String, dynamic>;
                                final type = data['incidentType'] ?? 'Unknown';
                                final stat = data['status'] ?? 'Unknown';
                                final docId = docs[index - 1].id;

                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                                StatusScreen(docId: docId),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 15.0,
                                    ),
                                    child: _statusBarBuilder(type, stat),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StatusScreen(docId: docId),
                ),
              );
            }
          },

          child: _statusBarBuilder(incidentType, status),
        );
      },
    );
  }
}
