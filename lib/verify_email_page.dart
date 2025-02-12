import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_page.dart';

class VerifyEmailPage extends StatefulWidget {
  final String email;
  final String password;
  final String fullName;

  const VerifyEmailPage({
    super.key,
    required this.email,
    required this.password,
    required this.fullName,
  });

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  bool isEmailVerified = false;
  Timer? timer;
  bool canResendEmail = true;

  @override
  void initState() {
    super.initState();
    // Verify email on start
    isEmailVerified = FirebaseAuth.instance.currentUser?.emailVerified ?? false;

    if (!isEmailVerified) {
      // Start timer to check email verification
      timer = Timer.periodic(
        const Duration(seconds: 3),
        (_) => checkEmailVerified(),
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> checkEmailVerified() async {
    try {
      // Sign in temporarily to check verification status
      final UserCredential tempSignIn = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: widget.email, password: widget.password);

      await tempSignIn.user?.reload();
      final isVerified = tempSignIn.user?.emailVerified ?? false;

      if (isVerified && mounted) {
        timer?.cancel();

        // Create Firestore document
        await FirebaseFirestore.instance
            .collection('users')
            .doc(tempSignIn.user?.uid)
            .set({
          'fullName': widget.fullName,
          'email': widget.email,
          'createdAt': FieldValue.serverTimestamp(),
          'emailVerified': true,
        });

        // Show success message and navigate to home
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Email verified! Account created successfully.')),
        );

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()),
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

  Future<void> sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();

      setState(() => canResendEmail = false);
      await Future.delayed(const Duration(seconds: 60));
      if (mounted) setState(() => canResendEmail = true);
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
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20.0),
            const Center(
              child: Text(
                'Verify Email',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            Container(
              height: 180.0,
              width: 180.0,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 233, 232, 232),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color.fromARGB(255, 233, 232, 232),
                  width: 2.0,
                ),
              ),
              child: Center(
                child: Image.asset(
                  'assets/images/email_verification.png',
                  height: 130.0,
                  width: 130.0,
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            const Text(
              'Verification link has been sent to',
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
            const SizedBox(height: 5.0),
            Text(
              widget.email,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20.0),
            const Text(
              'Please check your email and click the verification link to verify your email address.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 30.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Did not receive the email?',
                  style: TextStyle(fontSize: 12, color: Colors.black),
                ),
                const SizedBox(width: 4.0),
                TextButton(
                  onPressed: canResendEmail ? sendVerificationEmail : null,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Resend email',
                    style: TextStyle(
                      fontSize: 12,
                      color: canResendEmail
                          ? const Color(0xFFFE6F5E)
                          : Colors.grey,
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
}
