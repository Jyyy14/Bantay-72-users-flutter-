// ignore_for_file: unused_local_variable, use_build_context_synchronously, avoid_print, unused_field, unrelated_type_equality_checks, non_constant_identifier_names
import 'dart:convert';
import 'dart:typed_data';
import 'package:bantay_72_users/constants.dart';
import 'package:bantay_72_users/firebase_services/firebase_storage.dart';
import 'package:bantay_72_users/firebase_services/firestore.dart';
import 'package:bantay_72_users/screens/login.dart';
import 'package:bantay_72_users/screens/select_address.dart';
import 'package:bantay_72_users/screens/verify.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
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
                              SizedBox(width: 13.0),
                              Text(
                                'Bantay 72',
                                style: GoogleFonts.rubik(
                                  color: white,
                                  fontSize: 25.0,
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
                      padding: const EdgeInsets.symmetric(horizontal: 28.0),
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
                                fontSize: 17.0,
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
                              fontSize: 17.0,
                              fontColor: black,
                              height: Scaler.height(0.09, context).toDouble(),
                              width: Scaler.width(0.9, context).toDouble(),
                            ),

                            CustomTextFormField(
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
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
                              fontSize: 17.0,
                              fontColor: black,
                              height: Scaler.height(0.09, context).toDouble(),
                              width: Scaler.width(0.9, context).toDouble(),
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
                              fontSize: 17.0,
                              fontColor: black,
                              height: Scaler.height(0.08, context).toDouble(),
                              width: Scaler.width(0.9, context).toDouble(),
                            ),

                            SizedBox(height: 15.0),

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
                              fontSize: 17.0,
                              fontColor: black,
                              height: Scaler.height(0.09, context).toDouble(),
                              width: Scaler.width(0.9, context).toDouble(),
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
                              fontSize: 17.0,
                              fontColor: black,
                              height: Scaler.height(0.09, context).toDouble(),
                              width: Scaler.width(0.9, context).toDouble(),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28.0),
                      child: Column(
                        children: [
                          Container(
                            height: 160.0,
                            padding: const EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            width: double.infinity,
                            child:
                                _images.isNotEmpty
                                    ? GridView.builder(
                                      itemCount: _images.length + 1,
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 3,
                                            crossAxisSpacing: 8.0,
                                            mainAxisSpacing: 8.0,
                                          ),
                                      itemBuilder: (context, index) {
                                        if (index == _images.length) {
                                          return GestureDetector(
                                            onTap: _pickFiles,
                                            child: const Icon(
                                              Icons.add,
                                              size: 40.0,
                                              color: Primary,
                                            ),
                                          );
                                        } else {
                                          final file = _images[index];
                                          return Stack(
                                            children: [
                                              GestureDetector(
                                                onTap:
                                                    () => _showImagePreview(
                                                      context,
                                                      _images[index],
                                                    ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        8.0,
                                                      ),
                                                  child: Image.memory(
                                                    file.bytes,
                                                    width: double.infinity,
                                                    height: double.infinity,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                top: 4,
                                                right: 4,
                                                child: GestureDetector(
                                                  onTap:
                                                      () => removeImage(index),
                                                  child: Container(
                                                    decoration:
                                                        const BoxDecoration(
                                                          color: Colors.black54,
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                    padding:
                                                        const EdgeInsets.all(4),
                                                    child: const Icon(
                                                      Icons.close,
                                                      size: 16,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        }
                                      },
                                    )
                                    : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.upload_sharp,
                                          size: 50.0,
                                          color: Primary,
                                        ),
                                        const SizedBox(height: 10.0),
                                        CustomButton(
                                          onTap: _pickFiles,
                                          height: 40,
                                          width: 100,
                                          fontSize: 13.0,
                                          buttonName: 'Browse',
                                        ),
                                      ],
                                    ),
                          ),

                          SizedBox(height: 15.0),

                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "any valid proof of residency e.g. voter's id, etc. (img files only) ",
                                  style: GoogleFonts.poppins(
                                    color: black,
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  overflow: TextOverflow.clip,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 15.0),

                          CustomButton(
                            onTap: _isSubmitting ? null : _signUpPending,
                            isLoading: _isSubmitting,
                            // () {
                            //   _proceedToVerify();
                            // },
                            // () => Navigator.push(
                            //   context,
                            //   MaterialPageRoute(builder: (context) => VerificationScreen()),
                            // ),
                            height: 45.0,
                            fontSize: 18.0,
                            width: double.infinity,
                            buttonName:
                                _isSubmitting
                                    ? 'Submitting...'
                                    : 'Submit for Verification',
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 8.0),
                    Row(
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
                  ],
                ),
              ),
            ),

            if (_isLoading)
              Container(
                color: Colors.black54,
                child: const Center(child: CircularProgressIndicator(color: Primary,)),
              ),
          ],
        ),
      ),
    );
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

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      withData: true,
      type: FileType.image,
      allowMultiple: true,
    );

    if (result != null && result.files.isNotEmpty) {
      int added = 0;
      bool duplicateShown = false;
      bool limitReachedShown = false;

      setState(() {
        for (var file in result.files) {
          if (_images.length >= 3) {
            if (!limitReachedShown) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('You can only upload up to 3 images.'),
                ),
              );
              limitReachedShown = true;
            }
            break;
          }

          final isDuplicate = _images.any((img) => img.name == file.name);

          if (isDuplicate) {
            if (!duplicateShown) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('You already uploaded this image'),
                ),
              );
              duplicateShown = true;
            }
            continue;
          }

          if (file.bytes != null) {
            final base64Str = base64Encode(file.bytes!);
            _images.add(UploadedImage(file.bytes!, base64Str, file.name));
            added++;
          }
        }
      });

      if (added == 0 && !duplicateShown && !limitReachedShown) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No valid images were selected.')),
        );
      }
    }
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
