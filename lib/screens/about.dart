import 'package:bantay_72_users/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About', style: GoogleFonts.poppins(color: white)),
        backgroundColor: Primary,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_sharp),
          color: white, // 1
          onPressed: () {
            Navigator.of(context).maybePop();
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF0F0F0),
                      shape: BoxShape.circle,
                    ),
                    child: Transform.scale(
                      scale: 1.4,
                      child: Image.asset(
                        'assets/images/bnt.png',
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Bantay 72',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Version 1.0.0',
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16.0),
          _buildInfoCard(
            title: 'Developer Information',
            content: 'Developed by HTeamL group\n© 2025 All rights reserved',
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            title: 'Mission & Purpose',
            content:
                'Bantay 72 is dedicated to providing immediate emergency response and assistance to communities. '
                'Our mission is to create a safer environment through quick, reliable emergency communications and response coordination.',
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            title: 'Acknowledgments',
            content:
                'Special thanks to our partners, supporters, and the emergency response community for their continuous support and collaboration in making this platform possible.',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({required String title, required String content}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(content, style: const TextStyle(color: Colors.black87)),
          ],
        ),
      ),
    );
  }
}
