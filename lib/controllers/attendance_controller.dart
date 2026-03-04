import 'package:get/get.dart';
import 'package:school_management_system/models/attendance_model.dart';
import 'package:school_management_system/services/api_service.dart';
import 'package:school_management_system/services/auth_service.dart';
/*
/// Controller for Attendance screen.
/// Handles month filtering, API data fetching, and PDF generation state.
class AttendanceController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isGeneratingPdf = false.obs;
  final RxBool isFilterExpanded = false.obs;
  final RxString errorMessage = ''.obs;

  final RxString selectedMonth = 'January'.obs;
  final Rxn<AttendanceResponse> attendanceData = Rxn<AttendanceResponse>();
  final RxList<AttendanceRecord> filteredRecords = <AttendanceRecord>[].obs;
  

  // Student info for PDF generation
  final RxMap<String, String> studentInfo = <String, String>{}.obs;

  final _api = ApiService();
  final _auth = AuthService();

  static const List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  void onInit() {
    super.onInit();
    selectedMonth.value = months[DateTime.now().month - 1];
    _loadStudentInfo();
    fetchAttendance();
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

  void toggleFilter() {
    isFilterExpanded.value = !isFilterExpanded.value;
  }

  void setMonth(String month) {
    selectedMonth.value = month;
    fetchAttendance();
  }

  int get presentCount => filteredRecords
      .where((r) => r.status.toUpperCase().startsWith('P'))
      .length;

  int get absentCount => filteredRecords
      .where((r) => r.status.toUpperCase().startsWith('A'))
      .length;

  int get leaveCount => filteredRecords
      .where(
        (r) =>
            r.status.toUpperCase().startsWith('L') ||
            r.status.toUpperCase() == 'LEAVE',
      )
      .length;

  /// Fetch attendance from API for the selected month.
  Future<void> fetchAttendance() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final studentId = await _auth.getStudentId();
      if (studentId == null || studentId.isEmpty) {
        errorMessage.value = 'Student ID not found.';
        return;
      }

      final monthIndex = months.indexOf(selectedMonth.value) + 1;
      final monthStr = monthIndex.toString().padLeft(2, '0');

      final response = await _api.post(
        '/Attendance/GetAttendance',
        body: {'studentId': studentId, 'month': monthStr},
      );

      if (response is Map<String, dynamic>) {
        if (response.containsKey('message')) {
          errorMessage.value = response['message'];
          attendanceData.value = null;
          filteredRecords.clear();
        } else {
          attendanceData.value = AttendanceResponse.fromJson(response);
          filteredRecords.value = attendanceData.value?.records ?? [];
        }
      } else if (response is List && response.isNotEmpty) {
        final data = AttendanceResponse.fromJson(
          response.first as Map<String, dynamic>,
        );
        attendanceData.value = data;
        filteredRecords.value = data.records;
      } else if (response is String) {
        errorMessage.value = response;
        attendanceData.value = null;
        filteredRecords.clear();
      } else {
        errorMessage.value = 'No attendance records found.';
        attendanceData.value = null;
        filteredRecords.clear();
      }
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      attendanceData.value = null;
      filteredRecords.clear();
    } catch (e) {
      errorMessage.value = 'Failed to load attendance: ${e.toString()}';
      attendanceData.value = null;
      filteredRecords.clear();
    } finally {
      isLoading.value = false;
    }
  }

  /// Get status display string (normalize API codes)
  String normalizeStatus(String rawStatus) {
    switch (rawStatus.toUpperCase().trim()) {
      case 'P':
      case 'PRESENT':
        return 'Present';
      case 'A':
      case 'ABSENT':
        return 'Absent';
      case 'L':
      case 'LATE':
      case 'LEAVE':
        return 'Late';
      default:
        return rawStatus;
    }
  }
}

/// Controller for Attendance screen.
/// Handles dynamic year/month filtering and API data fetching.
class AttendanceController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isGeneratingPdf = false.obs;
  final RxBool isFilterExpanded = false.obs;
  final RxString errorMessage = ''.obs;

  // Selection State
  final RxString selectedMonth = 'January'.obs;
  final RxString selectedYear = ''.obs; 
  final RxList<String> availableYears = <String>[].obs;

  // Data State
  final Rxn<AttendanceResponse> attendanceData = Rxn<AttendanceResponse>();
  final RxList<AttendanceRecord> filteredRecords = <AttendanceRecord>[].obs;
  final RxMap<String, String> studentInfo = <String, String>{}.obs;

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
  }

  /// Sets up the initial dropdown values
  void _initializeFilters() {
    // 1. Generate Year List (Current + 5 Previous)
    int currentYear = DateTime.now().year;
    List<String> years = [];
    for (int i = 0; i <= 5; i++) {
      years.add((currentYear - i).toString());
    }
    availableYears.value = years;
    selectedYear.value = years.first; // Default to current year

    // 2. Set Default Month
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

  // --- Filter Actions ---

  void toggleFilter() {
    isFilterExpanded.value = !isFilterExpanded.value;
  }

  void setMonth(String month) {
    selectedMonth.value = month;
    fetchAttendance();
  }

  void setYear(String year) {
    selectedYear.value = year;
    fetchAttendance();
  }

  // --- Calculated Totals (Preferring API summary data) ---

  int get presentCount => attendanceData.value?.present ?? 0;
  int get absentCount => attendanceData.value?.absent ?? 0;
  int get leaveCount => attendanceData.value?.late ?? 0;

  // --- API Interaction ---

  /// Fetch attendance from API for the selected month and year.
  Future<void> fetchAttendance() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final studentId = await _auth.getStudentId();
      if (studentId == null || studentId.isEmpty) {
        errorMessage.value = 'Student ID not found.';
        return;
      }

      // Convert "January" -> "Jan" as required by your API
      final monthShortName = selectedMonth.value.substring(0, 3);

      final response = await _api.post(
        '/Attendance/GetAttendance',
        body: {
          'studentId': studentId,
          'month': monthShortName,
          'year': selectedYear.value,
        },
      );

      if (response is Map<String, dynamic>) {
        if (response.containsKey('message') && response['records'] == null) {
          errorMessage.value = response['message'];
          _clearData();
        } else {
          attendanceData.value = AttendanceResponse.fromJson(response);
          filteredRecords.value = attendanceData.value?.records ?? [];
        }
      } else if (response is List && response.isNotEmpty) {
        final data = AttendanceResponse.fromJson(
          response.first as Map<String, dynamic>,
        );
        attendanceData.value = data;
        filteredRecords.value = data.records;
      } else {
        errorMessage.value = 'No attendance records found.';
        _clearData();
      }
    } catch (e) {
      errorMessage.value = 'Failed to load attendance. Please try again.';
      _clearData();
    } finally {
      isLoading.value = false;
    }
  }

  void _clearData() {
    attendanceData.value = null;
    filteredRecords.clear();
  }

  /// Normalizes status for UI consistency
  String normalizeStatus(String rawStatus) {
    final status = rawStatus.toUpperCase().trim();
    if (status.contains('ON TIME') || status == 'P' || status == 'PRESENT') {
      return 'Present';
    } else if (status.contains('ABSENT') || status == 'A') {
      return 'Absent';
    } else if (status.contains('LATE') || status == 'L' || status == 'LEAVE') {
      return 'Late';
    }
    return rawStatus;
  }
} */



class AttendanceController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isGeneratingPdf = false.obs; // Tracks PDF loading state
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
    // 2. NEW: Always fetch current month data (Dashboard)
    fetchDashboardSummary();
  }


  // NEW: Method that ignores user selections and gets real-time data
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