/* import 'package:get/get.dart';
import 'package:school_management_system/services/auth_service.dart';

class ChangePasswordController extends GetxController {
  static ChangePasswordController get to => Get.find();

  final AuthService _authService = AuthService();

  // Observables
  var isLoading = false.obs;
  var errorMessage = "".obs;
  var successMessage = "".obs;

  // Password text fields
  var newPassword = "".obs;
  var confirmPassword = "".obs;

  // Change password function
  Future<void> changePassword() async {
    errorMessage.value = "";
    successMessage.value = "";

    // Validation
    if (newPassword.value.isEmpty || confirmPassword.value.isEmpty) {
      errorMessage.value = "Please fill all fields";
      return;
    }

    if (newPassword.value != confirmPassword.value) {
      errorMessage.value = "Passwords do not match";
      return;
    }

    isLoading.value = true;

    try {
      // Get studentId from AuthService
      final studentId = await _authService.getStudentId();

      if (studentId == null || studentId.isEmpty) {
        throw Exception("User not logged in");
      }

      // Call API to update password
      final response = await _authService.updatePassword(
        studentId,
        newPassword.value,
      );

      // Stop loader
      isLoading.value = false;

      // Wait 1 second before showing success message
      await Future.delayed(const Duration(seconds: 1));

      // Show success message
      if (response is Map<String, dynamic>) {
        successMessage.value =
            response["message"] ?? "Password updated successfully";
      } else {
        successMessage.value = "Password updated successfully";
      }

      // Clear fields
      newPassword.value = "";
      confirmPassword.value = "";

      //Logout user so next time app requires login
      await _authService.logout();

    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString();
    }
  }
} */
import 'package:get/get.dart';
import 'package:school_management_system/services/auth_service.dart';

class ChangePasswordController extends GetxController {
  static ChangePasswordController get to => Get.find();

  final AuthService _authService = AuthService();

  // Observables
  var isLoading = false.obs;
  var errorMessage = "".obs;
  var successMessage = "".obs;

  // Password text fields
  var newPassword = "".obs;
  var confirmPassword = "".obs;

  // --- Password Validation Rules (real-time) ---
  var hasUppercase = false.obs;
  var hasLowercase = false.obs;
  var hasDigit = false.obs;
  var hasSpecialChar = false.obs;

  // True only when all 4 rules pass
  bool get isPasswordValid =>
      hasUppercase.value &&
      hasLowercase.value &&
      hasDigit.value &&
      hasSpecialChar.value;

  // Call this from the TextField's onChanged
  void validatePasswordRules(String value) {
    hasUppercase.value = value.contains(RegExp(r'[A-Z]'));
    hasLowercase.value = value.contains(RegExp(r'[a-z]'));
    hasDigit.value = value.contains(RegExp(r'[0-9]'));
    hasSpecialChar.value =
        value.contains(RegExp(r'[!@#\$%^&*()_+\-=\[\]{};:''",.<>?/\\|`~]'));
  }

  // Change password function
  Future<void> changePassword() async {
    errorMessage.value = "";
    successMessage.value = "";

    // Validation: empty fields
    if (newPassword.value.isEmpty || confirmPassword.value.isEmpty) {
      errorMessage.value = "Please fill all fields";
      return;
    }

    // Validation: password rules
    if (!isPasswordValid) {
      errorMessage.value =
          "Password does not meet the required criteria. Please check the hints below.";
      return;
    }

    // Validation: passwords match
    if (newPassword.value != confirmPassword.value) {
      errorMessage.value = "Passwords do not match";
      return;
    }

    isLoading.value = true;

    try {
      // Get studentId from AuthService
      final studentId = await _authService.getStudentId();

      if (studentId == null || studentId.isEmpty) {
        throw Exception("User not logged in");
      }

      // Call API to update password
      final response = await _authService.updatePassword(
        studentId,
        newPassword.value,
      );

      // Stop loader
      isLoading.value = false;

      // Wait 1 second before showing success message
      await Future.delayed(const Duration(seconds: 1));

      // Show success message
      if (response is Map<String, dynamic>) {
        successMessage.value =
            response["message"] ?? "Password updated successfully";
      } else {
        successMessage.value = "Password updated successfully";
      }

      // Clear fields and reset validation state
      newPassword.value = "";
      confirmPassword.value = "";
      hasUppercase.value = false;
      hasLowercase.value = false;
      hasDigit.value = false;
      hasSpecialChar.value = false;

      // Logout user so next time app requires login
      await _authService.logout();
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString();
    }
  }
}