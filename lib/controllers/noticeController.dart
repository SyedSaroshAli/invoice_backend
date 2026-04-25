/* import 'package:get/get.dart';
import 'package:school_management_system/models/noticesModel.dart';
import 'package:school_management_system/services/api_service.dart';

class NoticesController extends GetxController {
  var notices = <NoticeModel>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  final _api = ApiService();

  @override
  void onInit() {
    super.onInit();
    fetchNoticesApi();
  }

  Future<void> fetchNoticesApi() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _api.get('/Notice/Get-Notices');

      if (response is List) {
        List<NoticeModel> apiData = response
            .map((item) => NoticeModel.fromJson(item as Map<String, dynamic>))
            .where((n) => n.title.isNotEmpty || n.description.isNotEmpty)
            .toList();

       
        apiData.sort((a, b) => b.date.compareTo(a.date));

       
        notices.value = apiData;
      } else {
        errorMessage.value = 'No notices available.';
        notices.clear();
      }
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = 'Failed to load notices: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshNotices() async {
    await fetchNoticesApi();
  }
}
*/
// notices_controller.dart

import 'package:get/get.dart';
import 'package:school_management_system/models/noticesModel.dart';
import 'package:school_management_system/services/api_service.dart';

class NoticesController extends GetxController {
  var notices = <NoticeModel>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  final _api = ApiService();

  @override
  void onInit() {
    super.onInit();
    fetchNoticesApi();
  }

  Future<void> fetchNoticesApi() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _api.get('/Notice/Get-Notices');

      if (response is List) {
        final apiData = response
            .map((item) => NoticeModel.fromJson(item as Map<String, dynamic>))
            // Keep notices that have either a title, text body, OR a file
            .where(
              (n) =>
                  n.title.isNotEmpty || n.description.isNotEmpty || n.hasFile,
            )
            .toList();

        // Sort newest first
        apiData.sort((a, b) => b.date.compareTo(a.date));

        notices.value = apiData;
       
        
      } else {
        errorMessage.value = 'No notices available.';
        notices.clear();
      }
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = 'Failed to load notices: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshNotices() async => fetchNoticesApi();
}
