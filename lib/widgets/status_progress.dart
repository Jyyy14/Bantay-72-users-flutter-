import 'package:bantay_72_users/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReportStatusProgress extends StatefulWidget {
  final String docId;
  const ReportStatusProgress({super.key, required this.docId});

  @override
  State<ReportStatusProgress> createState() => _ReportStatusProgressState();
}

class _ReportStatusProgressState extends State<ReportStatusProgress> {
  @override
  Widget build(BuildContext context) {
    const List<String> reportStages = [
      'Validated',
      'On The Way',
      'Arrived',
      'Completed',
    ];

    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('sos_reports')
              .doc(widget.docId)
              .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Center(child: CircularProgressIndicator());
        }

        final status = snapshot.data!['status'] ?? 'unread';
        final propercase = status
            .split(' ')
            .map(
              (word) =>
                  word.isNotEmpty
                      ? word[0].toUpperCase() + word.substring(1).toLowerCase()
                      : '',
            )
            .join(' ');
        final normalizedStatus =
            (propercase == 'Ongoing') ? 'Validated' : propercase;
        final currentIndex = reportStages.indexOf(normalizedStatus);

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: List.generate(reportStages.length, (index) {
              final isCompleted = index < currentIndex;
              final isCurrent = index == currentIndex;

              return Row(
                children: [
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 15,
                        backgroundColor:
                            isCompleted
                                ? Colors.green
                                : isCurrent
                                ? Primary
                                : Colors.grey.shade300,
                        child: Icon(
                          isCompleted
                              ? Icons.check
                              : isCurrent
                              ? Icons.radio_button_checked
                              : Icons.circle,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        reportStages[index],
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              isCurrent || isCompleted
                                  ? black
                                  : Colors.grey.shade500,
                          fontWeight:
                              isCurrent ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  if (index != reportStages.length - 1)
                    Container(
                      width: 40,
                      height: 2,
                      color:
                          index < currentIndex
                              ? Colors.green
                              : Colors.grey.shade300,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                    ),
                ],
              );
            }),
          ),
        );
      },
    );
  }
}
