// ignore_for_file: deprecated_member_use
/*
import 'package:flutter/material.dart';
import 'package:school_management_system/authentication_screens/signin.dart';
import 'package:school_management_system/services/auth_service.dart';
import 'package:school_management_system/services/api_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController fatherNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isPasswordVisible = false;
  bool isConfPasswordVisible = false;
  bool isLoading = false;

  final AuthService _authService = AuthService();

  Future<void> _handleSignup() async {
    final name = nameController.text.trim();
    final fatherName = fatherNameController.text.trim();
    final phone = phoneController.text.trim();
    final email = emailController.text.trim();
    final pass = passwordController.text;
    final confirm = confirmPasswordController.text;

    if (name.isEmpty || pass.isEmpty || confirm.isEmpty) {
      _showSnackBar("Please complete all required fields.", isError: true);
      return;
    }

    if (pass != confirm) {
      _showSnackBar("Passwords do not match", isError: true);
      return;
    }

    setState(() => isLoading = true);

    try {
      await _authService.register({
        'name': name,
        'father_Name': fatherName,
        'phone': phone,
        'email': email,
        'password': pass,
        // Defaults for fields the simple form doesn't collect
        'dob': '2000-01-01',
        'admission_Date': DateTime.now().toIso8601String(),
        'dept_Id': 1,
        'class_Id': 1,
        'father_Phone': '',
        'cnic': '',
        'address': '',
        'gender_Desc': '',
        'section': '',
        'year': DateTime.now().year.toString(),
      });

      if (!mounted) return;

      _showSnackBar("Signup successful!", isError: false);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SigninScreen()),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      _showSnackBar(e.message, isError: true);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar("Signup failed. Please try again.", isError: true);
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
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
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
                  children: [
                    // Logo/Icon
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.person_add,
                        size: 48,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title
                    Text(
                      "Create Account",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Sign up to get started",
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Name Field
                    _buildTextField(
                      nameController,
                      "Full Name",
                      Icons.person_outline,
                    ),
                    const SizedBox(height: 16),

                    // Father's Name Field
                    _buildTextField(
                      fatherNameController,
                      "Father's Name",
                      Icons.people_outline,
                    ),
                    const SizedBox(height: 16),

                    // Phone Field
                    _buildTextField(
                      phoneController,
                      "Phone Number",
                      Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),

                    // Email Field
                    _buildTextField(
                      emailController,
                      "Email",
                      Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),

                    // Password Field
                    TextField(
                      controller: passwordController,
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
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.6),
                          ),
                          onPressed: () => setState(
                            () => isPasswordVisible = !isPasswordVisible,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Confirm Password Field
                    TextField(
                      controller: confirmPasswordController,
                      obscureText: !isConfPasswordVisible,
                      obscuringCharacter: "•",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        labelText: "Confirm Password",
                        labelStyle: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        prefixIcon: Icon(
                          Icons.lock_outline,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            isConfPasswordVisible
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.6),
                          ),
                          onPressed: () => setState(
                            () =>
                                isConfPasswordVisible = !isConfPasswordVisible,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Signup Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          shadowColor: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.3),
                        ),
                        onPressed: isLoading ? null : _handleSignup,
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
                                "Sign Up",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Login Redirect
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account?",
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SigninScreen(),
                              ),
                            );
                          },
                          child: Text(
                            "Login",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
        prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
      ),
    );
  }
}
*/