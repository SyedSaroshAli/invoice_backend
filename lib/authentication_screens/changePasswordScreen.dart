// ignore_for_file: deprecated_member_use
/*
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:school_management_system/controllers/changePasswordController.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final ChangePasswordController controller = Get.put(
    ChangePasswordController(),
  );

  final TextEditingController studentIdController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  // ✅ FIXED ROW (NO OVERFLOW)
  Widget _buildValidationRow({
    required bool isMet,
    required String label,
    required bool hasInput,
  }) {
    final Color color = !hasInput
        ? Colors.grey
        : isMet
            ? Colors.green
            : Colors.red;

    final IconData icon = isMet ? Icons.check_circle : Icons.cancel;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            hasInput ? icon : Icons.radio_button_unchecked,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 8),

          // ✅ Prevent overflow
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 13, color: color),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Change Password"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.05,
                vertical: height * 0.03,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 550),
                  child: Obx(() {
                    final bool hasPasswordInput =
                        controller.newPassword.value.isNotEmpty;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (controller.errorMessage.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              controller.errorMessage.value,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),

                        if (controller.successMessage.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              controller.successMessage.value,
                              style: const TextStyle(color: Colors.green),
                            ),
                          ),

                        SizedBox(height: height * 0.02),

                        // NEW PASSWORD
                        TextField(
                          controller: newPasswordController,
                          obscureText: !isPasswordVisible,
                          obscuringCharacter: "•",
                          decoration: InputDecoration(
                            labelText: "New Password",
                            border: const OutlineInputBorder(),
                            enabledBorder: hasPasswordInput
                                ? OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: controller.isPasswordValid
                                          ? Colors.green
                                          : Colors.red,
                                      width: 1.5,
                                    ),
                                  )
                                : const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(
                                isPasswordVisible
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () {
                                setState(() {
                                  isPasswordVisible = !isPasswordVisible;
                                });
                              },
                            ),
                          ),
                          onChanged: (val) {
                            controller.newPassword.value = val;
                            controller.validatePasswordRules(val);
                          },
                        ),

                        // VALIDATION BOX
                        if (hasPasswordInput) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceVariant
                                  .withOpacity(0.45),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .outline
                                    .withOpacity(0.35),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Password must contain:",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),

                                _buildValidationRow(
                                  isMet: controller.hasUppercase.value,
                                  label: "At least one uppercase letter (A–Z)",
                                  hasInput: hasPasswordInput,
                                ),
                                _buildValidationRow(
                                  isMet: controller.hasLowercase.value,
                                  label: "At least one lowercase letter (a–z)",
                                  hasInput: hasPasswordInput,
                                ),
                                _buildValidationRow(
                                  isMet: controller.hasDigit.value,
                                  label: "At least one number (0–9)",
                                  hasInput: hasPasswordInput,
                                ),
                                _buildValidationRow(
                                  isMet: controller.hasSpecialChar.value,
                                  label:
                                      "At least one special character (e.g. \$, @, #, !)",
                                  hasInput: hasPasswordInput,
                                ),
                              ],
                            ),
                          ),
                        ],

                        SizedBox(height: height * 0.02),

                        // CONFIRM PASSWORD
                        TextField(
                          controller: confirmPasswordController,
                          obscureText: !isConfirmPasswordVisible,
                          obscuringCharacter: "•",
                          decoration: InputDecoration(
                            labelText: "Confirm Password",
                            border: const OutlineInputBorder(),
                            enabledBorder:
                                controller.confirmPassword.value.isNotEmpty
                                    ? OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: controller.newPassword.value ==
                                                  controller
                                                      .confirmPassword.value
                                              ? Colors.green
                                              : Colors.red,
                                          width: 1.5,
                                        ),
                                      )
                                    : const OutlineInputBorder(),
                            errorText: controller.confirmPassword.value
                                        .isNotEmpty &&
                                    controller.newPassword.value !=
                                        controller.confirmPassword.value
                                ? "Passwords do not match"
                                : null,
                            suffixIcon: IconButton(
                              icon: Icon(
                                isConfirmPasswordVisible
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () {
                                setState(() {
                                  isConfirmPasswordVisible =
                                      !isConfirmPasswordVisible;
                                });
                              },
                            ),
                          ),
                          onChanged: (val) =>
                              controller.confirmPassword.value = val,
                        ),

                        SizedBox(height: height * 0.04),

                        // BUTTON
                        SizedBox(
                          height: (height * 0.07).clamp(50.0, 70.0),
                          child: ElevatedButton(
                            onPressed: controller.isLoading.value ||
                                    !controller.isPasswordValid
                                ? null
                                : () async {
                                    await controller.changePassword();

                                    if (controller
                                        .successMessage.isNotEmpty) {
                                      await Future.delayed(
                                        const Duration(seconds: 1),
                                      );
                                      newPasswordController.clear();
                                      confirmPasswordController.clear();
                                    }
                                  },
                            child: controller.isLoading.value
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    "Update Password",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}*/
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:school_management_system/controllers/changePasswordController.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final ChangePasswordController controller = Get.put(
    ChangePasswordController(),
  );

  // 🔥 NEW: controller for current password field
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();

  // 🔥 NEW: visibility toggle for current password
  bool isCurrentPasswordVisible = false;
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  // ✅ FIXED ROW (NO OVERFLOW)
  Widget _buildValidationRow({
    required bool isMet,
    required String label,
    required bool hasInput,
  }) {
    final Color color =
        !hasInput ? Colors.grey : isMet ? Colors.green : Colors.red;
    final IconData icon = isMet ? Icons.check_circle : Icons.cancel;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            hasInput ? icon : Icons.radio_button_unchecked,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 8),
          // ✅ Prevent overflow
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 13, color: color),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Change Password"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.05,
                vertical: height * 0.03,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 550),
                  child: Obx(() {
                    final bool hasPasswordInput =
                        controller.newPassword.value.isNotEmpty;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (controller.errorMessage.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              controller.errorMessage.value,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),

                        if (controller.successMessage.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              controller.successMessage.value,
                              style: const TextStyle(color: Colors.green),
                            ),
                          ),

                        SizedBox(height: height * 0.02),

                        // 🔥 NEW: CURRENT PASSWORD FIELD
                        TextField(
                          controller: currentPasswordController,
                          obscureText: !isCurrentPasswordVisible,
                          obscuringCharacter: "•",
                          decoration: InputDecoration(
                            labelText: "Current Password",
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(
                                isCurrentPasswordVisible
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () {
                                setState(() {
                                  isCurrentPasswordVisible =
                                      !isCurrentPasswordVisible;
                                });
                              },
                            ),
                          ),
                          onChanged: (val) =>
                              controller.currentPassword.value = val,
                        ),

                        SizedBox(height: height * 0.02),

                        // NEW PASSWORD
                        TextField(
                          controller: newPasswordController,
                          obscureText: !isPasswordVisible,
                          obscuringCharacter: "•",
                          decoration: InputDecoration(
                            labelText: "New Password",
                            border: const OutlineInputBorder(),
                            enabledBorder: hasPasswordInput
                                ? OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: controller.isPasswordValid
                                          ? Colors.green
                                          : Colors.red,
                                      width: 1.5,
                                    ),
                                  )
                                : const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(
                                isPasswordVisible
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () {
                                setState(() {
                                  isPasswordVisible = !isPasswordVisible;
                                });
                              },
                            ),
                          ),
                          onChanged: (val) {
                            controller.newPassword.value = val;
                            controller.validatePasswordRules(val);
                          },
                        ),

                        // VALIDATION BOX
                        if (hasPasswordInput) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceVariant
                                  .withOpacity(0.45),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .outline
                                    .withOpacity(0.35),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Password must contain:",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                _buildValidationRow(
                                  isMet: controller.hasUppercase.value,
                                  label: "At least one uppercase letter (A–Z)",
                                  hasInput: hasPasswordInput,
                                ),
                                _buildValidationRow(
                                  isMet: controller.hasLowercase.value,
                                  label: "At least one lowercase letter (a–z)",
                                  hasInput: hasPasswordInput,
                                ),
                                _buildValidationRow(
                                  isMet: controller.hasDigit.value,
                                  label: "At least one number (0–9)",
                                  hasInput: hasPasswordInput,
                                ),
                                _buildValidationRow(
                                  isMet: controller.hasSpecialChar.value,
                                  label:
                                      r"At least one special character (e.g. $, @, #, !)",
                                  hasInput: hasPasswordInput,
                                ),
                              ],
                            ),
                          ),
                        ],

                        SizedBox(height: height * 0.02),

                        // CONFIRM PASSWORD
                        TextField(
                          controller: confirmPasswordController,
                          obscureText: !isConfirmPasswordVisible,
                          obscuringCharacter: "•",
                          decoration: InputDecoration(
                            labelText: "Confirm Password",
                            border: const OutlineInputBorder(),
                            enabledBorder:
                                controller.confirmPassword.value.isNotEmpty
                                    ? OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: controller.newPassword.value ==
                                                  controller
                                                      .confirmPassword.value
                                              ? Colors.green
                                              : Colors.red,
                                          width: 1.5,
                                        ),
                                      )
                                    : const OutlineInputBorder(),
                            errorText: controller
                                        .confirmPassword.value.isNotEmpty &&
                                    controller.newPassword.value !=
                                        controller.confirmPassword.value
                                ? "Passwords do not match"
                                : null,
                            suffixIcon: IconButton(
                              icon: Icon(
                                isConfirmPasswordVisible
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () {
                                setState(() {
                                  isConfirmPasswordVisible =
                                      !isConfirmPasswordVisible;
                                });
                              },
                            ),
                          ),
                          onChanged: (val) =>
                              controller.confirmPassword.value = val,
                        ),

                        SizedBox(height: height * 0.04),

                        // BUTTON
                        SizedBox(
                          height: (height * 0.07).clamp(50.0, 70.0),
                          child: ElevatedButton(
                            onPressed: controller.isLoading.value ||
                                    !controller.isPasswordValid
                                ? null
                                : () async {
                                    await controller.changePassword();
                                    // 🔥 Clear text fields on success
                                    // (navigation handled inside controller)
                                    if (controller
                                        .successMessage.isNotEmpty) {
                                      currentPasswordController.clear();
                                      newPasswordController.clear();
                                      confirmPasswordController.clear();
                                    }
                                  },
                            child: controller.isLoading.value
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    "Update Password",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}