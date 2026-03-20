import 'package:flutter/material.dart';
import 'package:school_management_system/authentication_screens/signin.dart';
import 'package:school_management_system/dashboard/student_dashboard.dart';
import 'package:school_management_system/services/auth_service.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  Future<bool> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 2));
    return await AuthService().isLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkAuth(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // Navigate after the frame completes to avoid build-phase navigation
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => snapshot.data == true
                      ? const StudentDashboard()
                      : const SigninScreen(),
                ),
              );
            }
          });
        }

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/KI_Logo_Transparent.png',
                  width: 120,
                  height: 120,
                ),
                const SizedBox(height: 20),
                const SizedBox(width: 200, child: LinearProgressIndicator()),
              ],
            ),
          ),
        );
      },
    );
  }
}
