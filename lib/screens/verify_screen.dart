// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:bantay_72_users/constants.dart';
import 'package:bantay_72_users/parse.dart';
import 'package:bantay_72_users/screens/select_address.dart';
import 'package:bantay_72_users/widgets/button.dart';
import 'package:bantay_72_users/widgets/textformfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:scaler/scaler.dart';

class VerifyScreen extends StatefulWidget {
  final bool isGoogleSignUp;
  const VerifyScreen({super.key, required this.isGoogleSignUp});

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController fullnameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  String? usernameError;
  String? emailError;
  final bool _isSubmitting = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    super.dispose();
    fullnameController.dispose();
    addressController.dispose();
    emailController.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.isGoogleSignUp) {
      // Pre-fill full name from Google
      fullnameController.text =
          FirebaseAuth.instance.currentUser?.displayName ?? '';
      emailController.text = FirebaseAuth.instance.currentUser?.email ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Verify Residency',
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
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            children: [
              const SizedBox(height: 20.0),

              Text(
                'Upload or scan your brgy. certificate to verify your residency.',
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                  fontSize: 15.0,
                ),
              ),

              Column(
                children: [
                  const SizedBox(height: 30.0),

                  if (widget.isGoogleSignUp) ...[
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          CustomTextFormField(
                            readonly: true,
                            labelText: 'Full name',
                            controller: fullnameController,
                            prefixIcon: Icon(
                              Icons.badge,
                              color: const Color.fromARGB(144, 0, 0, 0),
                            ),
                            validator:
                                (value) =>
                                    value!.isEmpty
                                        ? 'Enter your fullname'
                                        : null,
                            onSaved:
                                (value) => fullnameController.text = value!,
                            fontSize: 17.0.sp,
                            fontColor: black,
                            height: Scaler.height(0.09, context).toDouble(),
                            width: double.infinity,
                          ),

                          CustomTextFormField(
                            controller: emailController,
                            readonly: true,
                            prefixIcon: Icon(
                              Icons.mail,
                              color: const Color.fromARGB(144, 0, 0, 0),
                            ),
                            labelText: 'Email',
                            isEmail: true,
                            validator: (value) {
                              if (emailError != null) {
                                return emailError;
                              }

                              if (value.indexOf('@') == 0 ||
                                  !value.endsWith('@gmail.com')) {
                                return 'Invalid Email';
                              }
                              return null;
                            },
                            onSaved: (value) => emailController.text = value!,
                            fontSize: 17.0.sp,
                            fontColor: black,
                            height: Scaler.height(0.09, context).toDouble(),
                            width: double.infinity,
                          ),

                          CustomTextFormField(
                            controller: addressController,
                            prefixIcon: IconButton(
                              onPressed: () async {
                                final selectedLocation = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            const ChooseFromMapsScreen(),
                                  ),
                                );

                                if (selectedLocation != null) {
                                  addressController.text =
                                      selectedLocation['address'];
                                }
                              },
                              icon: Icon(
                                FontAwesomeIcons.mapPin,
                                color: Primary,
                              ),
                            ),
                            labelText: 'Address',
                            validator: (value) {
                              if (!value.contains(RegExp(r'[A-Za-z]'))) {
                                return 'Address must contain at least one letter';
                              } else if (!value.contains(RegExp(r'[0-9]'))) {
                                return 'Address must contain at least one number';
                              }
                              return null;
                            },
                            onSaved: (value) => addressController.text = value!,
                            fontSize: 17.0.sp,
                            fontColor: black,
                            height: Scaler.height(0.09, context).toDouble(),
                            width: double.infinity,
                          ),

                          CustomTextFormField(
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(11),
                            ],
                            controller: phoneController,
                            labelText: 'Phone',
                            prefixIcon: Icon(
                              Icons.phone,
                              color: const Color.fromARGB(144, 0, 0, 0),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter your phone number';
                              }
                              return null;
                            },
                            onSaved: (value) => phoneController.text = value!,
                            fontSize: 17.0.sp,
                            fontColor: black,
                            height: Scaler.height(0.09, context).toDouble(),
                            width: double.infinity,
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 20.0),

                  CustomButton(
                    fontColor: white,
                    fontWeight: FontWeight.w600,
                    hasLeading: true,
                    leading: Image.asset(
                      'assets/images/upload.png',
                      color: white,
                    ),
                    onTap: _scanDocument,
                    isLoading: _isSubmitting,
                    // () {
                    //   _proceedToVerify();
                    // },
                    // () => Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => VerificationScreen()),
                    // ),
                    height: 55.0.h,
                    fontSize: 16.0.sp,
                    width: double.infinity,
                    buttonName:
                        _isSubmitting
                            ? 'Submitting...'
                            : 'Upload/Scan Credentials',
                  ),

                  const SizedBox(height: 5.0),

                  Row(
                    children: [
                      Text(
                        '\t(use B/W filter for better accuracy)',
                        style: GoogleFonts.poppins(
                          fontSize: 12.0.sp,
                          color: const Color.fromARGB(226, 0, 0, 0),
                          fontWeight: FontWeight.w400,
                        ),
                        overflow: TextOverflow.clip,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _scanDocument() async {
    final options = DocumentScannerOptions(
      documentFormat: DocumentFormat.jpeg,
      mode: ScannerMode.full,
      isGalleryImport: true,
    );

    final scanner = DocumentScanner(options: options);

    try {
      final result = await scanner.scanDocument();
      if (result.images.isEmpty) return;

      // Use first scanned page (you can loop if multi-page)
      final imagePath = result.images.first;
      final inputImage = InputImage.fromFilePath(imagePath);

      final textRecognizer = TextRecognizer(
        script: TextRecognitionScript.latin,
      );
      final recognizedText = await textRecognizer.processImage(inputImage);

      final rawText = recognizedText.text;
      print("OCR Result:\n$rawText");

      try {
        final parsed = parseID(rawText);

        setState(() {
          if (parsed.address!.isNotEmpty) {
            addressController.text = parsed.address!;
          }
        });

        print("Detected ID Type: ${parsed.idType}");
      } catch (e) {
        print("Could not auto-detect ID type: $e");
        // fallback: let user manually fill in fields
      }

      setState(() {
        // if (fullname.isNotEmpty) fullnameController.text = fullname;
        if (addressController.text.isNotEmpty) {
          addressController.text = addressController.text;
        }
      });

      await textRecognizer.close();
      await scanner.close();
    } catch (e) {
      print("Error scanning document: $e");
    }

    // final result = await FilePicker.platform.pickFiles(
    //   type: FileType.image,
    //   allowMultiple: false,
    // );

    // if (result == null) return;

    // final filepath = result.files.single.path;
    // if (filepath == null) return;

    // final inputImage = InputImage.fromFilePath(filepath);
    // final textRecognizer = TextRecognizer();
    // final RecognizedText recognizedText = await textRecognizer.processImage(
    //   inputImage,
    // );

    // final rawText = recognizedText.text;
    // print("OCR Result:\n$rawText");

    // final fullname = _extractName(rawText);
    // final address = _extractAddress(rawText);

    // setState(() {
    //   if (fullname.isNotEmpty) fullnameController.text = fullname;
    //   if (address.isNotEmpty) addressController.text = address;
    // });

    // if (result != null && result.files.isNotEmpty) {
    //   int added = 0;
    //   bool duplicateShown = false;
    //   bool limitReachedShown = false;

    //   setState(() {
    //     for (var file in result.files) {
    //       if (_images.length >= 3) {
    //         if (!limitReachedShown) {
    //           ScaffoldMessenger.of(context).showSnackBar(
    //             const SnackBar(
    //               content: Text('You can only upload up to 3 images.'),
    //             ),
    //           );
    //           limitReachedShown = true;
    //         }
    //         break;
    //       }

    //       final isDuplicate = _images.any((img) => img.name == file.name);

    //       if (isDuplicate) {
    //         if (!duplicateShown) {
    //           ScaffoldMessenger.of(context).showSnackBar(
    //             const SnackBar(
    //               content: Text('You already uploaded this image'),
    //             ),
    //           );
    //           duplicateShown = true;
    //         }
    //         continue;
    //       }

    //       if (file.bytes != null) {
    //         final base64Str = base64Encode(file.bytes!);
    //         _images.add(UploadedImage(file.bytes!, base64Str, file.name));
    //         added++;
    //       }
    //     }
    //   });

    //   if (added == 0 && !duplicateShown && !limitReachedShown) {
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       const SnackBar(content: Text('No valid images were selected.')),
    //     );
    //   }
    // }
  }

  // String _extractName(String text) {
  //   // Looks for "certify" followed immediately by the name, stopping before age
  //   final regex = RegExp(r'certify\s*([A-Z\s\.]+)\s+\d{1,2}\s*yrs?\.?');
  //   final match = regex.firstMatch(text);
  //   return match != null ? match.group(1)!.trim() : "";
  // }
}
