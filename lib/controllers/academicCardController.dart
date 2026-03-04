/* import 'package:get/get.dart';
import 'package:school_management_system/services/api_service.dart';

class AcademicProgressController extends GetxController {
  final ApiService _apiService = ApiService();

  // Observables for UI
  var isLoading = true.obs;
  var overallPercentage = 0.0.obs;
  var completedExams = 0.obs;
  var totalExpectedExams = 0.obs;
  var isFinalResult = false.obs;


  // These come from your app/session
  final int studentId;

  AcademicProgressController({
    required this.studentId,
  });

  @override
  void onInit() {
    super.onInit();
    fetchAcademicProgress();
  }

  /// Main function to fetch tasks, marksheets, and calculate percentages
  Future<void> fetchAcademicProgress() async {
    try {
      isLoading.value = true;

      // 1️⃣ Fetch all exam tasks
      final tasksResponse = await _apiService.get('/Marksheet/tasks');
      List tasks = [];
      if (tasksResponse is List) tasks = tasksResponse;

      totalExpectedExams.value = tasks.length;

      if (tasks.isEmpty) return;

      // 2️⃣ Fetch all marksheets in parallel for completed tasks
      final futures = tasks.map((task) {
        return _apiService.get(
          '/Marksheet/Get-Marksheet-Single',
          queryParams: {
            'studentId': studentId.toString(),
            'taskId': task['taskId'].toString(),
          },
        );
      }).toList();

      final results = await Future.wait(futures);

      // 3️⃣ Calculate overall percentage
      double totalPercentage = 0;
      int completed = 0;

      for (var marks in results) {
        if (marks is List && marks.isNotEmpty) {
          totalPercentage += _calculateExamPercentage(marks);
          completed++;
        }
      }

      completedExams.value = completed;
      overallPercentage.value =
          completed > 0 ? totalPercentage / completed : 0.0;

      isFinalResult.value =
          completed == totalExpectedExams.value && completed > 0;
    } catch (e) {
      print("AcademicProgressController Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Helper: calculate percentage for a single exam
  double _calculateExamPercentage(List<dynamic> marks) {
    double totalObt = 0;
    double totalMarks = 0;

    for (var m in marks) {
      totalObt += (m['obtMarks'] ?? 0);
      totalMarks += (m['totalMarks'] ?? 0);
    }

    if (totalMarks == 0) return 0;
    return (totalObt / totalMarks) * 100;
  }
}  */
import 'package:get/get.dart';
import 'package:school_management_system/services/api_service.dart';
import 'package:school_management_system/services/auth_service.dart'; // Added

class AcademicProgressController extends GetxController {
  final ApiService _apiService = ApiService();
  final AuthService _auth = AuthService(); // Added

  // Observables for UI
  var isLoading = true.obs;
  var overallPercentage = 0.0.obs;
  var completedExams = 0.obs;
  var totalExpectedExams = 0.obs;
  var isFinalResult = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeAndFetch(); // Fetch ID first, then progress
  }

  /// New: Get studentId from storage before calling API
  Future<void> _initializeAndFetch() async {
    try {
      isLoading.value = true;
      String? sId = await _auth.getStudentId();
      
      if (sId != null && sId.isNotEmpty) {
        await fetchAcademicProgress(int.parse(sId));
      } else {
        print("Error: No Student ID found in storage.");
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Main function to fetch tasks, marksheets, and calculate percentages
  Future<void> fetchAcademicProgress(int sid) async {
    try {
      // 1️⃣ Fetch all exam tasks
      final tasksResponse = await _apiService.get('/Marksheet/tasks');
      List tasks = [];
      if (tasksResponse is List) tasks = tasksResponse;

      totalExpectedExams.value = tasks.length;
      if (tasks.isEmpty) return;

      // 2️⃣ Fetch marksheets in parallel
      final futures = tasks.map((task) {
        return _apiService.get(
          '/Marksheet/Get-Marksheet-Single',
          queryParams: {
            'studentId': sid.toString(),
            'taskId': task['taskId'].toString(),
          },
        ).catchError((e) => null); // Prevent one failed exam from breaking everything
      }).toList();

      final results = await Future.wait(futures);

      // 3️⃣ Calculate overall percentage
      double totalPercentageSum = 0;
      int completed = 0;

      for (var marks in results) {
        if (marks != null && marks is List && marks.isNotEmpty) {
          totalPercentageSum += _calculateExamPercentage(marks);
          completed++;
        }
      }

      completedExams.value = completed;
      overallPercentage.value = completed > 0 ? totalPercentageSum / completed : 0.0;

      // Logic: If all tasks in the system have results, it's a final result
      isFinalResult.value = completed == totalExpectedExams.value && completed > 0;
      
    } catch (e) {
      print("AcademicProgressController Error: $e");
    }
  }

  double _calculateExamPercentage(List<dynamic> marks) {
    double totalObt = 0;
    double totalMarks = 0;

    for (var m in marks) {
      // Convert to double to avoid type errors
      totalObt += (m['obtMarks'] ?? 0).toDouble();
      totalMarks += (m['totalMarks'] ?? 0).toDouble();
    }

    if (totalMarks == 0) return 0;
    return (totalObt / totalMarks) * 100;
  }
}