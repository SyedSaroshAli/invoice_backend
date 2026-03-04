import 'package:flutter/material.dart';
import 'package:school_management_system/dashboard/student_dashboard.dart';
import 'package:school_management_system/services/auth_service.dart';
import 'package:school_management_system/services/api_service.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final TextEditingController userID = TextEditingController();
  final TextEditingController password = TextEditingController();
  bool isPasswordVisible = false;
  bool isLoading = false;

  final AuthService _authService = AuthService();

  Future<void> _handleLogin() async {
    final userName = userID.text.trim();
    final pass = password.text.trim();

    if (userName.isEmpty || pass.isEmpty) {
      _showSnackBar("Please complete all required fields.", isError: true);
      return;
    }

    setState(() => isLoading = true);

    try {
      await _authService.login(userName, pass);

      if (!mounted) return;

      _showSnackBar("Login Successful!", isError: false);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const StudentDashboard()),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      _showSnackBar(e.message, isError: true);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar("Login failed. Please try again.", isError: true);
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Theme.of(context).colorScheme.error
            : Colors.blue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        // LayoutBuilder provides the parent constraints (width and height)
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                // Forces the child to be at least as tall as the screen
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Center(
                    child: Padding(
                      // Responsive horizontal padding based on screen width
                      padding: EdgeInsets.symmetric(
                        horizontal: constraints.maxWidth > 600 ? 40 : 20,
                        vertical: 20,
                      ),
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 500),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          border: Border.all(
                            color: Theme.of(context).dividerColor.withOpacity(0.5),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).shadowColor.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Logo/Icon
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  Icons.school,
                                  size: 48,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Title
                              Text(
                                "Welcome Back",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Sign in to continue",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.6),
                                ),
                              ),
                              const SizedBox(height: 32),

                              // User ID Field
                              TextField(
                                controller: userID,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                                decoration: InputDecoration(
                                  labelText: "User Name",
                                  labelStyle: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.person_outline,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: Theme.of(context).colorScheme.surface,
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Password Field
                              TextField(
                                controller: password,
                                obscureText: !isPasswordVisible,
                                obscuringCharacter: "•",
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                                decoration: InputDecoration(
                                  labelText: "Password",
                                  labelStyle: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.lock_outline,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      isPasswordVisible
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.6),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        isPasswordVisible = !isPasswordVisible;
                                      });
                                    },
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: Theme.of(context).colorScheme.surface,
                                ),
                              ),
                              const SizedBox(height: 32),

                              // Login Button
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(context).colorScheme.primary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 2,
                                  ),
                                  onPressed: isLoading ? null : _handleLogin,
                                  child: isLoading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                      : const Text(
                                          "Login",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}