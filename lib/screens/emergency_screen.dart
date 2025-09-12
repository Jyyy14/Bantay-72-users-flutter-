// ignore_for_file: use_build_context_synchronously

import 'package:bantay_72_users/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scaler/scaler.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Emergency', style: GoogleFonts.rubik(color: white)),
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
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'NATIONAL EMERGENCY HOTLINE',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),

                      SizedBox(height: 15.0),

                      _buildCardContainer(context, '911', false, null),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10.0),

            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  children: [
                    Column(
                      children: [
                        Center(
                          child: Text(
                            'MANILA FIRE DISTRICT',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),

                        SizedBox(height: 15.0),

                        _buildCardContainer(
                          context,
                          '0966-476-9700',
                          true,
                          'Globe: ',
                        ),

                        const SizedBox(height: 15.0),

                        _buildCardContainer(
                          context,
                          '0969-398-9700',
                          true,
                          'Smart: ',
                        ),

                        SizedBox(height: 15.0),

                        Text(
                          'TONDO FIRE STATION',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),

                        SizedBox(height: 15.0),

                        _buildCardContainer(
                          context,
                          '0946-727-0166',
                          false,
                          null,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10.0),

            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      showModalBottomSheet(
                        isDismissible: false,
                        context: context,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        builder: (BuildContext context) {
                          return Padding(
                            padding: const EdgeInsets.all(25.0),
                            child: SizedBox(
                              height: Scaler.height(0.6, context),
                              width: double.infinity,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: 10,
                                      bottom: 25,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Police Stations',
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 20,
                                          ),
                                        ),
                                        IconButton(
                                          onPressed:
                                              () => Navigator.pop(context),
                                          icon: Icon(Icons.close),
                                        ),
                                      ],
                                    ),
                                  ),

                                  Expanded(
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          _buildList(
                                            context,
                                            'Moriones-Tondo Police Station',
                                            'Morga corner Nolasco St., Moriones, Tondo, Manila',
                                            '0998-598-7898',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Add your police station list widgets here
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Icon(Icons.local_police, color: Color(0xFF6040B5)),
                            SizedBox(width: 13.0),
                            Text('Police', style: GoogleFonts.poppins()),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(width: 8.0),

                Expanded(
                  child: InkWell(
                    onTap: () {
                      showModalBottomSheet(
                        isDismissible: false,
                        context: context,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        builder: (BuildContext context) {
                          return Padding(
                            padding: const EdgeInsets.all(25.0),
                            child: SizedBox(
                              height: Scaler.height(0.6, context),
                              width: double.infinity,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: 10,
                                      bottom: 25,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Hospitals',
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 20,
                                          ),
                                        ),
                                        IconButton(
                                          onPressed:
                                              () => Navigator.pop(context),
                                          icon: Icon(Icons.close),
                                        ),
                                      ],
                                    ),
                                  ),

                                  Expanded(
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          _buildList(
                                            context,
                                            'Mary Johnston Hospital',
                                            '1221 J. Nolasco, Tondo, Manila',
                                            '(02)5318-6600',
                                          ),

                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 8.0,
                                            ),
                                            child: Divider(
                                              height: 20,
                                              color: const Color.fromARGB(
                                                108,
                                                158,
                                                158,
                                                158,
                                              ),
                                            ),
                                          ),

                                          _buildList(
                                            context,
                                            'Mother and Child Hospital',
                                            'Numancia Street, Binondo, Manila City, 1006, Metro Manila, Philippines',
                                            '0947-437-7705',
                                          ),

                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 8.0,
                                            ),
                                            child: Divider(
                                              height: 20,
                                              color: const Color.fromARGB(
                                                108,
                                                158,
                                                158,
                                                158,
                                              ),
                                            ),
                                          ),

                                          _buildList(
                                            context,
                                            'Gat Andres Bonifacio Medical Center',
                                            'Dapitan Street, Tondo',
                                            '(02)245-4366',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Add your hospital list widgets here
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Icon(Icons.local_hospital_sharp, color: Primary),
                            SizedBox(width: 13.0),
                            Text('Hospitals', style: GoogleFonts.poppins()),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10.0),
          ],
        ),
      ),
    );
  }

  Widget _buildCardContainer(
    BuildContext context,
    String text,
    bool? isRich,
    String? richText,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            isRich == true
                ? RichText(
                  text: TextSpan(
                    text: richText,
                    style: GoogleFonts.poppins(
                      color: black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    children: [
                      TextSpan(
                        text: text,
                        style: GoogleFonts.poppins(
                          color: black,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                )
                : Text(
                  text,
                  style: GoogleFonts.poppins(
                    color: black,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.transparent,
                  child: IconButton(
                    onPressed: () async {
                      // Launch phone dialer functionality
                      final Uri launchUri = Uri(scheme: 'tel', path: text);
                      try {
                        final launched = await launchUrl(
                          launchUri,
                          mode: LaunchMode.externalApplication,
                        );
                        if (!launched) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Could not launch dialer"),
                            ),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text("Error: $e")));
                      }
                    },
                    icon: Icon(Icons.phone, size: 21, color: Primary),
                  ),
                ),

                CircleAvatar(
                  backgroundColor: Colors.transparent,
                  child: IconButton(
                    icon: Icon(
                      Icons.copy,
                      size: 21,
                      color: const Color.fromARGB(137, 0, 0, 0),
                    ),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: text));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Copied to clipboard")),
                      );
                      // Copy to clipboard functionality
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    String name,
    String address,
    String text, {
    bool isRich = false,
    String? richText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: GoogleFonts.poppins(
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
            color: black,
          ),
        ),

        SizedBox(height: 5.0),

        Text(
          address,
          style: GoogleFonts.poppins(
            fontSize: 14.0,
            fontWeight: FontWeight.w400,
            color: const Color.fromARGB(255, 85, 85, 85),
          ),
          textAlign: TextAlign.start,
        ),

        SizedBox(height: 12.0),

        _buildCardContainer(context, text, isRich, richText),
      ],
    );
  }
}
