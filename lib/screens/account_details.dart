import 'package:bantay_72_users/constants.dart';
import 'package:bantay_72_users/widgets/dialogs.dart';
import 'package:bantay_72_users/widgets/textformfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scaler/scaler.dart';

class AccountDetailsScreen extends StatefulWidget {
  const AccountDetailsScreen({super.key});

  @override
  State<AccountDetailsScreen> createState() => _AccountDetailsScreenState();
}

class _AccountDetailsScreenState extends State<AccountDetailsScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  String? usernameError;

  bool isLoading = true;

  @override
  void dispose() {
    super.dispose();
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
  }

  @override
  void initState() {
    super.initState();
    loadUserDetails();
  }

  Future<void> loadUserDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;

    if (uid != null) {
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (userDoc.exists) {
        usernameController.text = userDoc['username'] ?? '';
        emailController.text = userDoc['email'] ?? '';
        // passwordController.text = userDoc['password'] ?? '';
        phoneController.text = userDoc['phone'] ?? '';
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> saveChanges() async {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;

    if (uid == null) return;

    try {
      // Re-authenticate user if needed
      if (passwordController.text.isNotEmpty ||
          emailController.text.trim() != user?.email) {
        final currentEmail = user!.email!;
        final currentPassword =
            await _promptForPassword(); // Ask user to re-enter password
        if (currentPassword == null) return; // User canceled

        final credential = EmailAuthProvider.credential(
          email: currentEmail,
          password: currentPassword,
        );

        await user.reauthenticateWithCredential(credential);
      }
      // Update Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'username': usernameController.text.trim(),
        'email': emailController.text.trim(),
        'password': passwordController.text,
        'phone': phoneController.text.trim(),
      });

      // Update Firebase Auth email
      if (emailController.text.trim() != user?.email) {
        await user?.verifyBeforeUpdateEmail(emailController.text.trim());
      }

      // Update password if filled
      if (passwordController.text.isNotEmpty) {
        await user?.updatePassword(passwordController.text.trim());
      }

      if (mounted) {
        usernameController.clear();
        emailController.clear();
        passwordController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account updated successfully')),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(
        // ignore: use_build_context_synchronously
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  Future<String?> _promptForPassword() async {
    final currentPassword = await reauthenticationDialog(context);
    if (currentPassword == null) return null;
    return currentPassword;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text('Profile', style: GoogleFonts.poppins(color: white)),
        backgroundColor: Primary,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_sharp),
          color: white, // 1
          onPressed: () {
            Navigator.of(context).maybePop();
          },
        ),
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 30.0,
                    vertical: 30.0,
                  ),
                  child: Column(
                    children: [
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            Center(
                              child: Stack(
                                children: [
                                  Icon(
                                    Icons.account_circle,
                                    size: 120.0,
                                    color: Colors.grey,
                                  ),
                                  Positioned(
                                    bottom: 8,
                                    right: 10,
                                    child: CircleAvatar(
                                      radius: 18,
                                      backgroundColor: Color(0xFFFEF7FF),
                                      child: const Icon(
                                        Icons.camera_alt,
                                        size: 18,
                                        color: black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 30),

                            _buildTextField(
                              'Username',
                              usernameController,
                              icon: Icon(
                                Icons.person,
                                color: const Color.fromARGB(144, 0, 0, 0),
                              ),
                            ),

                            _buildTextField(
                              'Mobile Number',
                              phoneController,
                              icon: Icon(
                                Icons.phone,
                                color: const Color.fromARGB(144, 0, 0, 0),
                              ),
                            ),
                            _buildTextField(
                              'Email',
                              emailController,
                              icon: Icon(
                                Icons.mail,
                                color: const Color.fromARGB(144, 0, 0, 0),
                              ),
                            ),
                            _buildTextField(
                              'Change Password',
                              passwordController,
                              obscure: true,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30.0),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => context.pop(),
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: const BorderSide(color: Colors.grey),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(color: Colors.black54),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: saveChanges,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromRGBO(
                                  159,
                                  36,
                                  36,
                                  1,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Save',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool obscure = false,
    Icon? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 6),
          CustomTextFormField(
            keyboardType:
                controller == phoneController
                    ? TextInputType.number
                    : TextInputType.text,
            inputFormatters:
                controller == phoneController
                    ? [FilteringTextInputFormatter.digitsOnly]
                    : [],
            isObscure: label == 'Change Password' ? obscure == true : false,
            prefixIcon: icon,
            controller: controller,
            labelText: label,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Enter your $label';
              }
              if (usernameError != null) {
                return usernameError;
              }
              return null;
            },
            onSaved: (value) => controller.text = value!,
            fontSize: 17.0,
            fontColor: black,
            height: Scaler.height(0.08, context),
            width: double.infinity,
          ),
          // TextField(
          //   controller: controller,
          //   obscureText: obscure,
          //   decoration: InputDecoration(
          //     contentPadding: const EdgeInsets.symmetric(
          //       horizontal: 16,
          //       vertical: 14,
          //     ),
          //     filled: true,
          //     fillColor: Colors.white,
          //     border: OutlineInputBorder(
          //       borderRadius: BorderRadius.circular(12),
          //       borderSide: const BorderSide(color: Colors.grey),
          //     ),
          //     enabledBorder: OutlineInputBorder(
          //       borderRadius: BorderRadius.circular(12),
          //       borderSide: const BorderSide(color: Colors.grey),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
