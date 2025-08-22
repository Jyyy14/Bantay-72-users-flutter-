import 'package:bantay_72_users/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scaler/scaler.dart';

class EmergencyContactsScreen extends StatelessWidget {
  const EmergencyContactsScreen({super.key});

  final contacts = const [
    {'name': 'Capt. Juan Dela Cruz', 'role': 'Barangay Captain'},
    {'name': 'Maria Santos', 'role': 'Secretary'},
    {'name': 'Roberto Reyes', 'role': 'Treasurer'},
    {'name': 'Elena Garcia', 'role': 'Councilor'},
    {'name': 'Ramon Torres', 'role': 'Councilor'},
    {'name': 'Daniella Marie', 'role': 'Councilor'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Emergency Contacts',
          style: GoogleFonts.poppins(color: white),
        ),
        backgroundColor: Primary,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_sharp),
          color: white, // 1
          onPressed: () {
            Navigator.of(context).maybePop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
        child: Column(
          children: [
            SizedBox(
              width: Scaler.width(0.9, context),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Primary),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          "These are your local Barangay officials' emergency contact numbers.",
                          style: GoogleFonts.poppins(
                            color: black,
                            fontSize: 13.0,
                          ),
                          overflow: TextOverflow.clip,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: contacts.length,
                itemBuilder: (context, index) {
                  final contact = contacts[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: const CircleAvatar(backgroundColor: unread, child: Icon(Icons.person, color: white,)),
                      title: Text(contact['name']!, style: GoogleFonts.inter(color: Primary, fontWeight: FontWeight.w600),),
                      subtitle: Text(contact['role']!),
                      trailing: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(backgroundColor: Primary),
                        child: const Text('Call', style: TextStyle(color: white)),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
