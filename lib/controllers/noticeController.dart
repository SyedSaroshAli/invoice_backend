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

        // Sort descending by date (latest first)
        apiData.sort((a, b) => b.date.compareTo(a.date));

        // Mark top 5 as new
        for (int i = 0; i < apiData.length; i++) {
          apiData[i].isNew = i < 5;
        }

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
} */
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
        List<NoticeModel> apiData = response
            .map((item) => NoticeModel.fromJson(item as Map<String, dynamic>))
            .where((n) => n.title.isNotEmpty || n.description.isNotEmpty)
            .toList();

        // Sort descending by date (latest first)
        apiData.sort((a, b) => b.date.compareTo(a.date));

        // Do NOT set isNew here — it is computed dynamically at render time
        // in NoticesSection so it stays accurate even if the app is left open
        // across midnight or new notices arrive via refresh.

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
