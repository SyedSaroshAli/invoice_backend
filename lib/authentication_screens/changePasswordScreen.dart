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
}  */
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// Note: Ensure the following imports match your project structure
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
}