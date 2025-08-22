import 'package:bantay_72_users/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ContactSupportScreen extends StatelessWidget {
  const ContactSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Contact Support',
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
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Email Support Card
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 15.0),
                          child: Text(
                            'Need assistance? Our support team is here to help you 24/7.',
                            style: GoogleFonts.poppins(
                              color: black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Row(
                            children: const [
                              Icon(Icons.email, color: Colors.black54),
                              SizedBox(width: 8),
                              Text(
                                'Email Support',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: white,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text('bantayteam72@gmail.com'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Primary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            child: Row(
                              mainAxisSize:
                                  MainAxisSize.min, // keeps button size tight
                              children: const [
                                Icon(Icons.email, color: white),
                                SizedBox(
                                  width: 8,
                                ), // space between icon and text
                                Text(
                                  'Send Email',
                                  style: TextStyle(color: white),
                                ),
                              ],
                            ),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 18.0),
                          child: Row(
                            children: const [
                              Icon(Icons.phone, color: Colors.black54),
                              SizedBox(width: 8),
                              Text(
                                'Emergency Hotline',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: white,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text('+63 912 345 6789'),
                          ),
                        ),

                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Primary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            child: Row(
                              mainAxisSize:
                                  MainAxisSize.min, // keeps button size tight
                              children: const [
                                Icon(Icons.phone, color: white),
                                SizedBox(
                                  width: 8,
                                ), // space between icon and text
                                Text(
                                  'Call Now',
                                  style: TextStyle(color: white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Operating Hours
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: Row(
                            children: [
                              Icon(Icons.access_time),
                              SizedBox(width: 10.0,),
                              Text(
                                'Operating Hours',
                                style: GoogleFonts.poppins(
                                  color: black,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Text('Monday - Friday: 24 hours', style: GoogleFonts.inter(color: black, fontWeight: FontWeight.w500),),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Text('Saturday - Sunday: 24 hours', style: GoogleFonts.inter(color: black, fontWeight: FontWeight.w500)),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Text('Holidays: 24 hours', style: GoogleFonts.inter(color: black, fontWeight: FontWeight.w500)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
