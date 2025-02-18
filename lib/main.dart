import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'sign_up_page.dart';
import 'home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await GoogleSignIn().signInSilently();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomePage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  bool _isPasswordVisible = false; // Track the visibility state of the password
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    // First validate email format
    String email = _emailController.text.trim();
    if (!_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address'),
        ),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: _passwordController.text,
      );

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error Code: ${e.code}');
      print('Firebase Auth Error Message: ${e.message}');

      String message;
      switch (e.code) {
        case 'user-not-found':
        case 'invalid-email':
        case 'INVALID_LOGIN_CREDENTIALS':
        case 'channel-error':
          message =
              'No account found with this email. Please check your email or sign up.';
          break;
        case 'wrong-password':
        case 'invalid-credential':
          message =
              'Incorrect password. Please try again or use "Forgot Password".';
          break;
        case 'user-disabled':
          message = 'This account has been disabled.';
          break;
        default:
          message = 'An error occurred. Please try again. (${e.code})';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
          ),
        );
      }
    }
  }

  // Add email validation helper method
  bool _isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+').hasMatch(email);
  }

  Future<void> _resetPassword() async {
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email address')),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset email sent! Check your inbox.'),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'An error occurred')),
      );
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      // Begin interactive sign-in process
      final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

      if (gUser == null) return;

      // Obtain auth details from request
      final GoogleSignInAuthentication gAuth = await gUser.authentication;

      // Create a new credential for user
      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      // Finally, sign in
      await FirebaseAuth.instance.signInWithCredential(credential);

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 90.0), // Add space at the top
            const Text(
              'Welcome!',
              style: TextStyle(
                fontSize: 35, // Font size for the title
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6.0),
            const Text(
              'Sign in or create a new account',
              style: TextStyle(
                fontSize: 13, // Font size for subtitle
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10.0),
            Image.asset(
              'assets/images/image.png',
              height: 250, // Larger image size
              width: 250,
            ),
            const SizedBox(height: 15.0),
            // Email TextField
            SizedBox(
              width: 330.0, // Adjust field width
              child: TextField(
                cursorColor: const Color(0xFFFE6F5E), // Caret color
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: const TextStyle(
                    fontSize: 13.0, // Smaller label font size
                    color: Colors.grey,
                  ),
                  floatingLabelStyle: const TextStyle(
                    fontSize: 13.0, // Smaller floating label font size
                    color: Color(0xFFFE6F5E),
                    fontWeight: FontWeight.bold,
                  ),
                  hintText: 'yourname@gmail.com',
                  hintStyle: const TextStyle(
                    fontSize: 12.0, // Smaller hint font size
                    color: Colors.grey,
                  ),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(17.0), // Adjusted border
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(17.0),
                    borderSide: const BorderSide(
                      color: Color(0xFFFE6F5E),
                      width: 2.0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(17.0),
                    borderSide:
                        const BorderSide(color: Colors.grey, width: 1.5),
                  ),
                ),
                controller: _emailController,
              ),
            ),
            const SizedBox(height: 15.0),
            // Password TextField
            SizedBox(
              width: 330.0, // Adjust field width
              child: TextField(
                obscureText: !_isPasswordVisible,
                cursorColor: const Color(0xFFFE6F5E), // Caret color
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: const TextStyle(
                    fontSize: 13.0, // Smaller label font size
                    color: Colors.grey,
                  ),
                  floatingLabelStyle: const TextStyle(
                    fontSize: 13.0, // Smaller floating label font size
                    color: Color(0xFFFE6F5E),
                    fontWeight: FontWeight.bold,
                  ),
                  hintText: '********',
                  hintStyle: const TextStyle(
                    fontSize: 12.0, // Smaller hint font size
                    color: Colors.grey,
                  ),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(17.0), // Adjusted border
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(17.0),
                    borderSide: const BorderSide(
                      color: Color(0xFFFE6F5E),
                      width: 2.0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(17.0),
                    borderSide:
                        const BorderSide(color: Colors.grey, width: 1.5),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
                controller: _passwordController,
              ),
            ),
            const SizedBox(height: 15.0),
            Padding(
              padding: const EdgeInsets.only(right: 25.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _resetPassword,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25.0),
            SizedBox(
              width: 330.0, // Adjust button width to match fields
              child: ElevatedButton(
                onPressed: _signIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFE6F5E),
                  minimumSize:
                      const Size(330.0, 42), // Button size matches fields
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(17.0), // Adjusted border
                  ),
                ),
                child: const Text(
                  'Sign In',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
            const SizedBox(height: 12.0),
            const Text(
              'Or',
              style:
                  TextStyle(fontSize: 12.0, color: Colors.grey), // Smaller text
            ),
            const SizedBox(height: 12.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSocialIcon('assets/images/apple_icon.png'),
                const SizedBox(width: 20.0), // Reduced spacing
                _buildSocialIcon('assets/images/google_icon.png',
                    onTap: _signInWithGoogle),
                const SizedBox(width: 20.0), // Reduced spacing
                _buildSocialIcon('assets/images/facebook_icon.png'),
              ],
            ),
            const SizedBox(height: 12.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Don't have an account?",
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.grey,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SignUpPage()),
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    ' Sign up.',
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

  // Helper method for social icons
  Widget _buildSocialIcon(String assetPath, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Image.asset(
          assetPath,
          height: 32, // Slightly smaller icon size
          width: 32,
        ),
      ),
    );
  }
}
