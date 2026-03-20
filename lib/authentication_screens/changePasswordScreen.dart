/* import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:school_management_system/authentication_screens/signin.dart';
import 'package:school_management_system/controllers/changePasswordController.dart';

class ChangePasswordScreen extends StatelessWidget {
  ChangePasswordScreen({super.key});

  final ChangePasswordController controller =
      Get.put(ChangePasswordController());

  final TextEditingController studentIdController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(title: const Text("Change Password"),
      leading: IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () {
     Navigator.of(context).pop();
    },
  ),
      
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: width * 0.05,
            vertical: height * 0.03,
          ),
          child: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                /// Error Message
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

                /// Success Message
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

                /// Student ID
                /*TextField(
                  controller: studentIdController,
                  decoration: const InputDecoration(
                    labelText: "Student ID",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (val) => controller.studentId.value = val,
                ),
*/
                SizedBox(height: height * 0.02),

                /// New Password
                TextField(
                  controller: newPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "New Password",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) => controller.newPassword.value = val,
                ),

                SizedBox(height: height * 0.02),

                /// Confirm Password
                TextField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Confirm Password",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) => controller.confirmPassword.value = val,
                ),

                SizedBox(height: height * 0.04),

                /// Update Button
                SizedBox(
                  height: height * 0.07,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : () async {
                            await controller.changePassword();

                            if (controller.successMessage.isNotEmpty) {

                              await Future.delayed(const Duration(seconds: 1));
                              //studentIdController.clear();
                              newPasswordController.clear();
                              confirmPasswordController.clear();

                            /*  Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => SigninScreen(),
      ),
      (route) => false,
    ); */
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
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
            ),
          ),
        ),
      ),
    );
  }
}  
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// Note: Ensure the following imports match your project structure
//import 'package:school_management_system/authentication_screens/signin.dart';
import 'package:school_management_system/controllers/changePasswordController.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final ChangePasswordController controller =
      Get.put(ChangePasswordController());

  final TextEditingController studentIdController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Change Password"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SafeArea(
        // LayoutBuilder provides the available space for responsiveness
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              // Physics ensures smooth scrolling on all devices
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.05,
                vertical: height * 0.03,
              ),
              child: Center(
                child: ConstrainedBox(
                  // Limits the width on larger screens (Tablets/Web) for readability
                  constraints: const BoxConstraints(maxWidth: 550),
                  child: Obx(
                    () => Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        /// Error Message
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

                        /// Success Message
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

                        /// Student ID
                        /*TextField(
                  controller: studentIdController,
                  decoration: const InputDecoration(
                    labelText: "Student ID",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (val) => controller.studentId.value = val,
                ),
*/
                        SizedBox(height: height * 0.02),

                        /// New Password
                        TextField(
                          controller: newPasswordController,
                          obscureText: !isPasswordVisible,
                                obscuringCharacter: "•",
                         // obscureText: true,
                          decoration: InputDecoration(
                            labelText: "New Password",
                            border: const OutlineInputBorder(),
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
                          ),
                          onChanged: (val) => controller.newPassword.value = val,
                        ),

                        SizedBox(height: height * 0.02),

                        /// Confirm Password
                        TextField(
                          controller: confirmPasswordController,
                           obscureText: !isConfirmPasswordVisible,
                                obscuringCharacter: "•",
                         // obscureText: true,
                          decoration: InputDecoration(
                            labelText: "Confirm Password",
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                                    icon: Icon(
                                      isConfirmPasswordVisible
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.6),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        isConfirmPasswordVisible = !isConfirmPasswordVisible;
                                      });
                                    },
                                  ),
                          ),
                          onChanged: (val) =>
                              controller.confirmPassword.value = val,
                        ),

                        SizedBox(height: height * 0.04),

                        /// Update Button
                        SizedBox(
                          // Clamp ensures the button stays usable on all screen heights
                          height: (height * 0.07).clamp(50.0, 70.0),
                          child: ElevatedButton(
                            onPressed: controller.isLoading.value
                                ? null
                                : () async {
                                    await controller.changePassword();

                                    if (controller.successMessage.isNotEmpty) {
                                      await Future.delayed(
                                          const Duration(seconds: 1));
                                      //studentIdController.clear();
                                      newPasswordController.clear();
                                      confirmPasswordController.clear();

                                      /* Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => SigninScreen(),
                      ),
                      (route) => false,
                    ); */
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
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
} */
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// Note: Ensure the following imports match your project structure
//import 'package:school_management_system/authentication_screens/signin.dart';
import 'package:school_management_system/controllers/changePasswordController.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final ChangePasswordController controller =
      Get.put(ChangePasswordController());

  final TextEditingController studentIdController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  // ── Helper: single validation row ──────────────────────────────────────────
  Widget _buildValidationRow({
    required bool isMet,
    required String label,
    // Only show coloured indicators once the user has started typing
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
        children: [
          Icon(
            hasInput ? icon : Icons.radio_button_unchecked,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Change Password"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SafeArea(
        // LayoutBuilder provides the available space for responsiveness
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              // Physics ensures smooth scrolling on all devices
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.05,
                vertical: height * 0.03,
              ),
              child: Center(
                child: ConstrainedBox(
                  // Limits the width on larger screens (Tablets/Web) for readability
                  constraints: const BoxConstraints(maxWidth: 550),
                  child: Obx(
                    () {
                      // Whether the user has started typing in the new-password field
                      final bool hasPasswordInput =
                          controller.newPassword.value.isNotEmpty;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          /// ── Error Message ────────────────────────────────
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

                          /// ── Success Message ──────────────────────────────
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

                          /// ── Student ID (commented out, kept as-is) ───────
                          /*TextField(
                            controller: studentIdController,
                            decoration: const InputDecoration(
                              labelText: "Student ID",
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (val) => controller.studentId.value = val,
                          ),*/

                          SizedBox(height: height * 0.02),

                          /// ── New Password ─────────────────────────────────
                          TextField(
                            controller: newPasswordController,
                            obscureText: !isPasswordVisible,
                            obscuringCharacter: "•",
                            decoration: InputDecoration(
                              labelText: "New Password",
                              border: const OutlineInputBorder(),
                              // Show a red/green border based on validity once typing starts
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
                            ),
                            onChanged: (val) {
                              controller.newPassword.value = val;
                              // Trigger real-time rule checking
                              controller.validatePasswordRules(val);
                            },
                          ),

                          /// ── Password Validation Checklist ────────────────
                          // Shown as soon as the user starts typing
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
                                  Text(
                                    "Password must contain:",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.7),
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

                          /// ── Confirm Password ─────────────────────────────
                          TextField(
                            controller: confirmPasswordController,
                            obscureText: !isConfirmPasswordVisible,
                            obscuringCharacter: "•",
                            decoration: InputDecoration(
                              labelText: "Confirm Password",
                              border: const OutlineInputBorder(),
                              // Highlight mismatch in real time
                              enabledBorder: controller
                                      .confirmPassword.value.isNotEmpty
                                  ? OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: controller.newPassword.value ==
                                                controller.confirmPassword.value
                                            ? Colors.green
                                            : Colors.red,
                                        width: 1.5,
                                      ),
                                    )
                                  : const OutlineInputBorder(),
                              // Small hint under the field when there's a mismatch
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
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.6),
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

                          /// ── Update Button ────────────────────────────────
                          SizedBox(
                            // Clamp ensures the button stays usable on all screen heights
                            height: (height * 0.07).clamp(50.0, 70.0),
                            child: ElevatedButton(
                              // Disabled when loading OR password rules not satisfied
                              onPressed: controller.isLoading.value ||
                                      !controller.isPasswordValid
                                  ? null
                                  : () async {
                                      await controller.changePassword();

                                      if (controller
                                          .successMessage.isNotEmpty) {
                                        await Future.delayed(
                                            const Duration(seconds: 1));
                                        newPasswordController.clear();
                                        confirmPasswordController.clear();

                                        /* Navigator.of(context).pushAndRemoveUntil(
                                          MaterialPageRoute(
                                            builder: (context) => SigninScreen(),
                                          ),
                                          (route) => false,
                                        ); */
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
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
                    },
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