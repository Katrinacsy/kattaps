// ignore: unused_import
import 'package:flutter/material.dart';
import 'verify_email_page.dart'; 
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // Add controllers for form fields
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Add this validation method
  String? _validatePassword(String password) {
    if (password.length < 12) {
      return 'Password must be at least 12 characters long';
    }
    if (!RegExp(r'(?=.*[A-Z])').hasMatch(password)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'(?=.*[a-z])').hasMatch(password)) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!RegExp(r'(?=.*[0-9])').hasMatch(password)) {
      return 'Password must contain at least one number';
    }
    if (!RegExp(r'(?=.*[!@#\$%^&*(),.?":{}|<>])').hasMatch(password)) {
      return 'Password must contain at least one special character';
    }
    return null;
  }

  // Update sign up method
  Future<void> _signUp() async {
    // Validate password
    String? passwordValidation = _validatePassword(_passwordController.text);
    if (passwordValidation != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(passwordValidation)),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match!')),
      );
      return;
    }

    try {
      // Create temporary user for verification
      final UserCredential tempUser =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Send verification email
      await tempUser.user!.sendEmailVerification();

      // Navigate to verify email page
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => VerifyEmailPage(
              email: _emailController.text.trim(),
              password: _passwordController.text, 
              fullName: _fullNameController.text, 
            ),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = 'An error occurred';
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'An account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        message = 'Please provide a valid email address.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous page
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 0.0),
            const Center(
              child: Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 35.0),
            // Full Name Field
            _buildFieldWithLabel(
              label: 'Full Name',
              hintText: 'Enter name here...',
              controller: _fullNameController,
            ),
            const SizedBox(height: 20.0),
            // Email Field
            _buildFieldWithLabel(
              label: 'Email',
              hintText: 'yourname@gmail.com',
              controller: _emailController,
            ),
            const SizedBox(height: 20.0),
            // Password Field
            _buildFieldWithLabel(
              label: 'Password',
              hintText: '************',
              obscureText: !_isPasswordVisible,
              controller: _passwordController,
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
            ),
            const SizedBox(height: 20.0),
            // Confirm Password Field
            _buildFieldWithLabel(
              label: 'Confirm Password',
              hintText: '************',
              obscureText: !_isConfirmPasswordVisible,
              controller: _confirmPasswordController,
              suffixIcon: IconButton(
                icon: Icon(
                  _isConfirmPasswordVisible
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                  });
                },
              ),
            ),
            const SizedBox(height: 20.0),
            SizedBox(
              width: 330.0, 
              child: ElevatedButton(
                onPressed: _signUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFE6F5E),
                  minimumSize: const Size(330.0, 42), 
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17.0),
                  ),
                ),
                child: const Text(
                  'Sign Up',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
            const SizedBox(height: 12.0),
            const Text(
              'Or',
              style:
                  TextStyle(fontSize: 12.0, color: Colors.grey), 
            ),
            const SizedBox(height: 12.0),
            // Social Icons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSocialIcon('assets/images/apple_icon.png'),
                const SizedBox(width: 20.0),
                _buildSocialIcon('assets/images/google_icon.png'),
                const SizedBox(width: 20.0),
                _buildSocialIcon('assets/images/facebook_icon.png'),
              ],
            ),
            const SizedBox(height: 12.0),
            // Already have an account
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Already have an account?',
                  style: TextStyle(
                    fontSize: 12.0, // Smaller font size
                    color: Colors.grey,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Navigate back to Login page
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero, 
                    minimumSize: Size.zero, 
                    tapTargetSize:
                        MaterialTapTargetSize.shrinkWrap, 
                  ),
                  child: const Text(
                    ' Log in.',
                    style: TextStyle(
                      fontSize: 12.0, 
                      color: Color(0xFFFE6F5E),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build a field with its label
  Widget _buildFieldWithLabel({
    required String label,
    required String hintText,
    bool obscureText = false,
    Widget? suffixIcon,
    TextEditingController? controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12.0,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 6.0),
        SizedBox(
          width: 330.0,
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            cursorColor: const Color(0xFFFE6F5E),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 13,
                color: Color.fromARGB(255, 115, 114, 114),
              ),
              fillColor: Colors.grey.shade200,
              filled: true,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 10.0,
                horizontal: 12.0,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(17.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(17.0),
                borderSide: BorderSide(color: Colors.grey.shade200, width: 2.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(17.0),
                borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5),
              ),
              suffixIcon: suffixIcon,
            ),
          ),
        ),
      ],
    );
  }

  // Helper method for social icons
  Widget _buildSocialIcon(String assetPath) {
    return GestureDetector(
      onTap: () {
        // Handle social login
      },
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Image.asset(
          assetPath,
          height: 32,
          width: 32,
        ),
      ),
    );
  }
}
