import 'package:get/get.dart';
import 'package:school_management_system/models/admitcardModel.dart';
import 'package:school_management_system/services/api_service.dart';
import 'package:school_management_system/services/auth_service.dart';

class AdmitCardController extends GetxController {
  final isLoading = false.obs;
  final isGeneratingPdf = false.obs;
  final admitCard = Rxn<AdmitCardModel>();
  final errorMessage = ''.obs;

  final _api = ApiService();
  final _auth = AuthService();

  // Filter values
  final selectedTaskId = Rxn<int>();
  final selectedYear = Rxn<int>();

  @override
  void onInit() {
    super.onInit();
    loadAdmitCard();
  }

  Future<void> loadAdmitCard({int? taskId, int? year}) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final studentId = await _auth.getStudentId();
      if (studentId == null || studentId.isEmpty) {
        errorMessage.value = 'Student ID not found.';
        isLoading.value = false;
        return;
      }

      final queryParams = <String, String>{'StudentId': studentId};

      if (taskId != null) queryParams['TaskId'] = taskId.toString();
      if (year != null) queryParams['Year'] = year.toString();

      final response = await _api.get('/AdmitCard', queryParams: queryParams);

      if (response is Map<String, dynamic>) {
        if (response.containsKey('message')) {
          errorMessage.value = response['message'];
          admitCard.value = null;
        } else {
          admitCard.value = AdmitCardModel.fromJson(response);
        }
      } else if (response is List && response.isNotEmpty) {
        admitCard.value = AdmitCardModel.fromJson(
          response.first as Map<String, dynamic>,
        );
      } else {
        errorMessage.value = 'No admit card found.';
        admitCard.value = null;
      }
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = 'Failed to load admit card.';
    } finally {
      isLoading.value = false;
    }
  }
}
