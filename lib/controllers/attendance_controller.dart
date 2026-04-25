import 'package:get/get.dart';
import 'package:school_management_system/models/attendance_model.dart';
import 'package:school_management_system/services/api_service.dart';
import 'package:school_management_system/services/auth_service.dart';

class AttendanceController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isGeneratingPdf = false.obs; 
  final RxBool isFilterExpanded = false.obs;
  final RxString errorMessage = ''.obs;

  final RxString selectedMonth = 'January'.obs;
  final RxString selectedYear = ''.obs; 
  final RxList<String> availableYears = <String>[].obs;

  final Rxn<AttendanceResponse> attendanceData = Rxn<AttendanceResponse>();
  final RxList<AttendanceRecord> filteredRecords = <AttendanceRecord>[].obs;
  final RxMap<String, String> studentInfo = <String, String>{}.obs;

  // NEW: Dedicated state for the Dashboard only
  final Rxn<AttendanceResponse> dashboardSummary = Rxn<AttendanceResponse>();
  final RxBool isDashboardLoading = false.obs;

  final _api = ApiService();
  final _auth = AuthService();

  static const List<String> months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  @override
  void onInit() {
    super.onInit();
    _initializeFilters();
    _loadStudentInfo();
    fetchAttendance();
    fetchDashboardSummary();
  }

  Future<void> fetchDashboardSummary() async {
    try {
      isDashboardLoading.value = true;
      final studentId = await _auth.getStudentId();
      if (studentId == null) return;

      final now = DateTime.now();
      final currentMonthShort = months[now.month - 1];
      final currentYearStr = now.year.toString();
      

      final response = await _api.post(
        '/Attendance/GetAttendance',
        body: {
          'studentId': studentId,
          'month': currentMonthShort,
          'year': currentYearStr,
        },
      );

      if (response != null) {
        dashboardSummary.value = AttendanceResponse.fromJson(response);
      }
    } catch (e) {
      print("Dashboard fetch error: $e");
    } finally {
      isDashboardLoading.value = false;
    }
  }

  void _initializeFilters() {
    int currentYear = DateTime.now().year;
    List<String> years = [];
    for (int i = 0; i <= 5; i++) {
      years.add((currentYear - i).toString());
    }
    availableYears.value = years;
    selectedYear.value = years.first;
    selectedMonth.value = months[DateTime.now().month - 1];
  }

  Future<void> _loadStudentInfo() async {
    final name = await _auth.getStudentName() ?? '';
    final userData = await _auth.getUserData();
    studentInfo.value = {
      'name': name,
      'rollNo': userData?['rollNo']?.toString() ?? '',
      'fatherName': userData?['father_Name']?.toString() ?? '',
      'class': userData?['classDesc']?.toString() ?? '',
    };
  }

  void toggleFilter() => isFilterExpanded.value = !isFilterExpanded.value;

  void setMonth(String month) {
    selectedMonth.value = month;
    fetchAttendance();
  }

  void setYear(String year) {
    selectedYear.value = year;
    fetchAttendance();
  }

  int get presentCount => attendanceData.value?.present ?? 0;
  int get absentCount => attendanceData.value?.absent ?? 0;
  int get leaveCount => attendanceData.value?.late ?? 0;

  Future<void> fetchAttendance() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final studentId = await _auth.getStudentId();
      if (studentId == null) return;

      final response = await _api.post(
        '/Attendance/GetAttendance',
        body: {
          'studentId': studentId,
          'month': selectedMonth.value.substring(0, 3),
          'year': selectedYear.value,
        },
      );

      if (response != null) {
        attendanceData.value = AttendanceResponse.fromJson(response);
        filteredRecords.value = attendanceData.value?.records ?? [];
      }
    } catch (e) {
      errorMessage.value = 'Failed to load attendance.';
    } finally {
      isLoading.value = false;
    }
  }

  String normalizeStatus(String rawStatus) {
    final status = rawStatus.toUpperCase().trim();
    if (status.contains('ON TIME') || status == 'P') return 'Present';
    if (status.contains('ABSENT') || status == 'A') return 'Absent';
    return 'Late';
  }
}