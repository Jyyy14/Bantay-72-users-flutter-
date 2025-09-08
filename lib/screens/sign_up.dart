// ignore_for_file: unused_local_variable, use_build_context_synchronously, avoid_print, unused_field, unrelated_type_equality_checks, non_constant_identifier_names
import 'dart:io';
import 'package:bantay_72_users/constants.dart';
import 'package:bantay_72_users/firebase_services/firebase_storage.dart';
import 'package:bantay_72_users/firebase_services/firestore.dart';
import 'package:bantay_72_users/screens/login.dart';
import 'package:bantay_72_users/screens/select_address.dart';
import 'package:bantay_72_users/screens/verify.dart';
import 'package:bantay_72_users/screens/verify_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/retry.dart';
import 'package:scaler/scaler.dart';
import '../widgets/button.dart';
import '../widgets/textformfield.dart';
import '../widgets/dialogs.dart';

class UploadedImage {
  final Uint8List bytes;
  final String base64;
  final String name;

  UploadedImage(this.bytes, this.base64, this.name);
}

class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(
      RegExp(r'\D'),
      '',
    ); // keep only digits
    String formatted = '';

    for (int i = 0; i < digits.length && i < 11; i++) {
      formatted += digits[i];

      if (i == 3 || i == 6) {
        formatted += '-'; // add dash after 4th and 7th digit
      }
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final List<UploadedImage> _images = [];
  final FirestoreService _firestore = FirestoreService();
  final FirebaseStorageService _firebase_storage = FirebaseStorageService();
  List<dynamic> suggestions = [];
  String? usernameError;
  String? emailError;
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  bool _isLoading = false;

  TextEditingController usernameController = TextEditingController();
  TextEditingController fullnameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  File? selectedImage;

  @override
  void dispose() {
    super.dispose();
    usernameController.dispose();
    fullnameController.dispose();
    addressController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 30.0),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 250,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              fit: BoxFit.fill,
                              image: AssetImage(
                                "assets/images/Rectangle 6.png",
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Row(
                            children: [
                              Container(
                                width: Scaler.width(0.08, context).toDouble(),
                                height: Scaler.height(0.08, context).toDouble(),
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    fit: BoxFit.fitWidth,
                                    image: AssetImage(
                                      "assets/images/capstoneLogo.png",
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 13.0.w),
                              Text(
                                'Bantay 72',
                                style: GoogleFonts.rubik(
                                  color: white,
                                  fontSize: 25.0.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 130),
                          child: Center(
                            child: Text(
                              'Sign Up',
                              style: GoogleFonts.radioCanada(
                                color: white,
                                fontSize: 45.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 20.0),
                              child: CustomTextFormField(
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
                            ),
                            CustomTextFormField(
                              controller: usernameController,
                              labelText: 'Username',
                              prefixIcon: Icon(
                                Icons.person,
                                color: const Color.fromARGB(144, 0, 0, 0),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Enter your username';
                                }
                                if (usernameError != null) {
                                  return usernameError;
                                }
                                return null;
                              },
                              onSaved:
                                  (value) => usernameController.text = value!,
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
                                PhoneNumberFormatter(),
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
                              onSaved:
                                  (value) => addressController.text = value!,
                              fontSize: 17.0.sp,
                              fontColor: black,
                              height: Scaler.height(0.08, context).toDouble(),
                              width: double.infinity,
                            ),

                            SizedBox(height: 15.0.h),

                            CustomTextFormField(
                              controller: emailController,
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
                              controller: passwordController,
                              labelText: 'Password',
                              isObscure: true,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Enter your password';
                                } else if (value.length < 8) {
                                  return 'Password must be at least 8 characters';
                                } else if (!RegExp(r'[A-Z]').hasMatch(value)) {
                                  return 'Password must contain at least one uppercase letter';
                                }
                                return null;
                              },
                              onSaved:
                                  (value) => passwordController.text = value!,
                              fontSize: 17.0.sp,
                              fontColor: black,
                              height: Scaler.height(0.09, context).toDouble(),
                              width: double.infinity,
                            ),

                            Column(
                              children: [
                                SizedBox(height: 15.0.h),
                                CustomButton(
                                  fontWeight: FontWeight.w600,
                                  onTap: _isSubmitting ? null : _signUpPending,
                                  isLoading: _isSubmitting,
                                  // () {
                                  //   _proceedToVerify();
                                  // },
                                  // () => Navigator.push(
                                  //   context,
                                  //   MaterialPageRoute(builder: (context) => VerificationScreen()),
                                  // ),
                                  height: 55.0.h,
                                  fontSize: 18.0.sp,
                                  width: double.infinity,
                                  buttonName:
                                      _isSubmitting
                                          ? 'Submitting...'
                                          : 'Register',
                                ),

                                SizedBox(height: 6.0.h),
                              ],
                            ),

                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 15.0,
                              ),
                              child: Row(
                                children: [
                                  const Expanded(
                                    child: Divider(
                                      color: Colors.grey,
                                      thickness: 1,
                                      endIndent:
                                          10, // space between line and text
                                    ),
                                  ),
                                  Text(
                                    "or",
                                    style: TextStyle(
                                      color: black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const Expanded(
                                    child: Divider(
                                      color: Colors.grey,
                                      thickness: 1,
                                      indent: 10, // space between text and line
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            CustomButton(
                              bgColor: white,
                              fontColor: black,
                              hasBorder: true,
                              splashColor: Colors.grey[300]!,
                              fontWeight: FontWeight.w500,
                              onTap: () async {
                                final user = await signUpWithGoogle();
                                if (user != null) {
                                  print(
                                    "Signed up: ${user.displayName}, ${user.email}",
                                  );
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => VerifyScreen(
                                            isGoogleSignUp: true,
                                          ),
                                    ),
                                  );
                                  // redirect to verify screen for address + barangay certificate
                                }
                              },

                              hasLeading: true,
                              leading: Image.asset('assets/images/google.png'),
                              // () {
                              //   _proceedToVerify();
                              // },
                              // () => Navigator.push(
                              //   context,
                              //   MaterialPageRoute(builder: (context) => VerificationScreen()),
                              // ),
                              height: 58.0,
                              fontSize: 16.0,
                              width: double.infinity,
                              buttonName: 'Sign up with Google',
                            ),
                          ],
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already a member?',
                            style: GoogleFonts.poppins(
                              color: black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          GestureDetector(
                            onTap:
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LogInScreen(),
                                  ),
                                ),
                            child: Text(
                              '\tLog In',
                              style: GoogleFonts.poppins(
                                color: Primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (_isLoading)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: CircularProgressIndicator(color: Primary),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<User?> signUpWithGoogle() async {
    try {
      await GoogleSignIn().signOut(); // clears cached account
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) return null; // user canceled

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );

      return userCredential.user;
    } catch (e) {
      print("Google Sign-Up error: $e");
      return null;
    }
  }

  Future<void> _proceedToVerify() async {
    if (usernameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.isEmpty ||
        fullnameController.text.trim().isEmpty ||
        addressController.text.trim().isEmpty ||
        _images.isEmpty ||
        phoneController.text.trim().isEmpty) {
      await customDialog(
        context,
        title: 'Error',
        content: 'All fields are required to continue',
      );
      return;
    }
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VerificationScreen(email: emailController.text),
      ),
    );

    if (result == true) {
      await _signUpPending();
    }
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

      final fullname = _extractName(rawText);
      final address = _extractAddress(rawText);

      setState(() {
        if (fullname.isNotEmpty) fullnameController.text = fullname;
        if (address.isNotEmpty) addressController.text = address;
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

  String _extractName(String text) {
    // Looks for "certify" followed immediately by the name, stopping before age
    final regex = RegExp(r'certify\s*([A-Z\s\.]+)\s+\d{1,2}\s*yrs?\.?');
    final match = regex.firstMatch(text);
    return match != null ? match.group(1)!.trim() : "";
  }

  String _extractAddress(String text) {
    final regex = RegExp(
      r'residence and postal address at\s+(.*)',
      caseSensitive: false,
    );
    final match = regex.firstMatch(text);
    return match != null ? match.group(1)!.trim() : "";
  }

  void _showImagePreview(BuildContext context, UploadedImage image) {
    showDialog(
      context: context,
      builder:
          (_) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(10.0),
            child: Stack(
              children: [
                InteractiveViewer(
                  child: Center(
                    child: Image.memory(image.bytes, fit: BoxFit.contain),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const CircleAvatar(
                      backgroundColor: Colors.black54,
                      child: Icon(Icons.close, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  // Future<void> _uploadImage () async{
  //   List<MediaFile>? media = await GalleryPicker.pickMedia(context: context, singleMedia: true);

  //   if (media != null && media.isNotEmpty){
  //     var data = await media.first.getFile();
  //     setState(() {
  //       selectedImage = data;
  //     });
  //   }

  // }

  void removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  Future<void> _signUpPending() async {
    String fullname = fullnameController.text.trim();
    String username = usernameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text;
    String address = addressController.text.trim();
    String phone = phoneController.text.trim();

    final snapshot = await _firestore.fetchWithQuery(
      context: context,
      collection: 'users',
      conditions: [
        {'field': 'username', 'value': username},
      ],
      limit: 1,
    );

    final emailSnapshot = await _firestore.fetchWithQuery(
      context: context,
      collection: 'users',
      conditions: [
        {'field': 'email', 'value': email},
      ],
      limit: 1,
    );

    setState(() {
      usernameError =
          (snapshot != null && snapshot.isNotEmpty)
              ? 'Username is already taken'
              : null;
      emailError =
          (emailSnapshot != null && emailSnapshot.isNotEmpty)
              ? 'Email is already taken'
              : null;
    });

    if (username.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        fullname.isEmpty ||
        address.isEmpty ||
        _images.isEmpty ||
        phone.isEmpty) {
      await customDialog(
        context,
        title: 'Error',
        content: 'All fields are required to continue',
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      // If the form is not valid, stop here.
      return;
    }

    _formKey.currentState!.save();

    if (_isSubmitting) return;
    setState(() {
      _isSubmitting = true;
      _isLoading = true;
    });

    List<Map<String, dynamic>> uploadedImages = [];

    for (final image in _images) {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${image.name}';
      final imageUrl = await _firebase_storage.uploadFile(
        fileBytes: image.bytes,
        fileName: fileName,
        folder: 'pending_users/$username',
      );

      if (imageUrl != null) {
        uploadedImages.add({
          'name': fileName,
          'url': imageUrl,
          'path': 'pending_users/$username/$fileName',
        });
      }
    }

    try {
      DocumentReference docId = await _firestore.addData(
        context: context,
        collection: 'pending-users',
        data: {
          'fullname': fullname,
          'username': username,
          'email': email,
          'phone': phone,
          'password': password,
          'status': 'unchecked',
          'address': address,
          'timestamp': FieldValue.serverTimestamp(),
          'images': uploadedImages,
        },
      );
      await docId.update({'docId': docId.id});
      await customDialog(
        context,
        title: 'Success',
        content:
            'Submitted Successfully! Kindly check your gmail account from time to time. Messages may appear in spam.',
      );

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LogInScreen()),
        );
      }
    } catch (e) {
      await customDialog(
        context,
        title: 'Error',
        content: 'Failed to Submit Information',
      );
      print("Error: $e ");
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _isLoading = false;
        });
      }
    }
  }
}
