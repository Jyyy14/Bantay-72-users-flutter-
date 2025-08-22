import 'package:bantay_72_users/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Privacy Policy', style: GoogleFonts.poppins(color: white)),
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
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Data Collection',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontSize: 20.0,
                      ),
                    ),
                    const SizedBox(height: 15.0),
                    _buildRow(
                      context,
                      'Location data for emergency response',
                      Icon(Icons.check_circle, color: Primary),
                    ),
                    const SizedBox(height: 8),
                    _buildRow(
                      context,
                      'Personal info for user identification',
                      Icon(Icons.check_circle, color: Primary),
                    ),
                    const SizedBox(height: 8),
                    _buildRow(
                      context,
                      'Emergency contact info',
                      Icon(Icons.check_circle, color: Primary),
                    ),
                    const SizedBox(height: 25.0),
                    Text(
                      'How We Use Your Data',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontSize: 20.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildRow(
                      context,
                      'Provide emergency assistance',
                      Icon(Icons.shield, color: Primary),
                    ),
                    const SizedBox(height: 8),
                    _buildRow(
                      context,
                      'Improve our services',
                      Icon(Icons.shield, color: Primary),
                    ),
                    const SizedBox(height: 8),
                    _buildRow(
                      context,
                      'Contact emergency responders',
                      Icon(Icons.shield, color: Primary),
                    ),

                    const SizedBox(height: 25.0),
                    Text(
                      'Data Security',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontSize: 20.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'We implement industry-standard security measures to protect your personal information from unauthorized access, disclosure or misuse.',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25.0),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contact Us',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontSize: 20.0,
                      ),
                    ),

                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.mail_outline, color: Colors.grey),
                        const SizedBox(width: 8),
                        const Expanded(child: Text('privacy@bantay72.com')),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.phone_outlined, color: Colors.grey),
                        const SizedBox(width: 8),
                        const Expanded(child: Text('+1 (555) 123-4567')),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(BuildContext context, String content, Icon icon) {
    return Row(
      children: [
        icon,
        const SizedBox(width: 8),
        Expanded(child: Text(content)),
      ],
    );
  }
}
