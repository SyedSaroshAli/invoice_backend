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
}