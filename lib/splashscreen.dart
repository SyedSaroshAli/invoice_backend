/* import 'package:flutter/material.dart';
import 'package:school_management_system/authentication_screens/signin.dart';
import 'package:school_management_system/dashboard/student_dashboard.dart';
import 'package:school_management_system/services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    // Splash delay (for logo display)
    await Future.delayed(const Duration(seconds:190));

    final isLoggedIn = await AuthService().isLoggedIn();

    if (!mounted) return;

    if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const StudentDashboard()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SigninScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/school_logo.png',
              width: 120,
              height: 120,
            ),
            const Text(
              "The Reader's Academy",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const SizedBox(
              width: 200,
              child: LinearProgressIndicator(),
            ),
          ],
        ),
      ),
    );
  }
} */
import 'package:flutter/material.dart';
import 'package:school_management_system/authentication_screens/signin.dart';
import 'package:school_management_system/dashboard/student_dashboard.dart';
import 'package:school_management_system/services/auth_service.dart';
import 'package:url_launcher/url_launcher.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  Future<void> _openWebsite() async {
    final Uri url = Uri.parse("https://www.kisoftwaressolutions.com/");
    if (!await launchUrl(url)) {
      throw "Could not launch $url";
    }
  }

  Future<void> _callNumber() async {
    final Uri url = Uri.parse("tel:+923197617561");
    if (!await launchUrl(url)) {
      throw "Could not launch $url";
    }
  }

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    await Future.delayed(const Duration(seconds: 7));

    final isLoggedIn = await AuthService().isLoggedIn();

    if (!mounted) return;

    if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const StudentDashboard()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SigninScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 MAIN CONTENT (UNCHANGED)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/school_logo.png',
                      width: 120,
                      height: 120,
                    ),
                    const Text(
                      "The Reader's Academy",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const SizedBox(
                      width: 200,
                      child: LinearProgressIndicator(color: Colors.black,backgroundColor: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),

            // 🔻 FOOTER (BOTTOM FIXED)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "Powered By KI Software Solutions",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 7,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: _openWebsite,
                      child: const Text(
                        "Visit our website",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.blue,
                          fontSize: 8,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: _callNumber,
                      child: const Text(
                        "Contact us",
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.blue,
                          fontSize: 8,
                        ),
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