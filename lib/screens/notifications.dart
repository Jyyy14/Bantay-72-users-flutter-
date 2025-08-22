import 'package:bantay_72_users/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications', style: GoogleFonts.rubik(color: white)),
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
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Notification 1: Fire Warning
            NotificationCard(
              title: 'Fire Warning!',
              message:
                  'A fire has been detected in your area. Please evacuate immediately.',
              timestamp: '10 mins ago',
            ),
            // Notification 2: Flood Warning
            NotificationCard(
              title: 'Flood Warning!',
              message:
                  'Heavy rain is expected. Flooding may occur. Stay alert.',
              timestamp: '1 hour ago',
            ),
            // Notification 3: Earthquake Alert
            NotificationCard(
              title: 'Earthquake Alert!',
              message: 'A 6.5 magnitude earthquake has occurred in the area.',
              timestamp: '2 hours ago',
            ),
            // Add more notifications as needed
          ],
        ),
      ),
    );
  }
}

// A custom widget for displaying notifications
class NotificationCard extends StatelessWidget {
  final String title;
  final String message;
  final String timestamp;

  const NotificationCard({
    super.key,
    required this.title,
    required this.message,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Primary, // Red for emergency notifications
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 4),
            Text(
              timestamp,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
