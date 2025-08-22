import 'package:bantay_72_users/constants.dart';
import 'package:bantay_72_users/screens/data_protection.dart';
import 'package:bantay_72_users/screens/privacy_policy.dart';
import 'package:bantay_72_users/screens/terms_of_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart' show GoogleFonts;

class TermsPrivacyScreen extends StatelessWidget {
  const TermsPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Terms & Privacy Policy',
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
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 45.0),
        child: Column(
          children: [
            Text(
              'Manage your data privacy and security settings',
              style: GoogleFonts.poppins(color: black, fontSize: 13.0),
            ),

            const SizedBox(height: 10.0),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  GestureDetector(
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TermsPrivacyScreen(),
                          ),
                        ),
                    child: ListTile(
                      leading: const Icon(
                        FontAwesomeIcons.shieldHalved,
                        size: 21.0,
                      ),
                      title: Text(
                        'Privacy Policy',
                        style: GoogleFonts.inter(color: black),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PrivacyPolicyScreen(),
                            ),
                          ),
                    ),
                  ),
                  GestureDetector(
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TermsOfServiceScreen(),
                          ),
                        ),
                    child: ListTile(
                      leading: const Icon(
                        FontAwesomeIcons.fileContract,
                        size: 21.0,
                      ),
                      title: Text(
                        'Terms of Service',
                        style: GoogleFonts.inter(color: black),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TermsOfServiceScreen(),
                            ),
                          ),
                    ),
                  ),
                  GestureDetector(
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DataProtectionScreen(),
                          ),
                        ),
                    child: ListTile(
                      leading: const Icon(
                        FontAwesomeIcons.userShield,
                        size: 21.0,
                      ),
                      title: Text(
                        'Data Protection Rights',
                        style: GoogleFonts.inter(color: black),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DataProtectionScreen(),
                            ),
                          ),
                    ),
                  ),

                  const SizedBox(height: 30.0),

                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.info, color: unread),
                          SizedBox(width: 10.0),
                          Expanded(
                            child: Text(
                              'Your privacy matters to us. Review our policies to understand how we protect and manage your data.',
                              overflow: TextOverflow.clip,
                              style: GoogleFonts.inter(
                                color: black,
                                fontSize: 13.0,
                              ),
                            ),
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
      ),
    );
  }
}
