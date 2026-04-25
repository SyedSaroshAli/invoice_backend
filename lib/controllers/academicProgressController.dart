import 'package:get/get.dart';
import 'package:school_management_system/services/api_service.dart';
import 'package:school_management_system/services/auth_service.dart'; // Added

class AcademicProgressController extends GetxController {
  final ApiService _apiService = ApiService();
  final AuthService _auth = AuthService(); // Added


  var isLoading = true.obs;
  var overallPercentage = 0.0.obs;
  var completedExams = 0.obs;
  var totalExpectedExams = 0.obs;
  var isFinalResult = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeAndFetch(); 
  }

  
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

 
  Future<void> fetchAcademicProgress(int sid) async {
    try {
      
      final tasksResponse = await _apiService.get('/Marksheet/tasks');
      List tasks = [];
      if (tasksResponse is List) tasks = tasksResponse;

      totalExpectedExams.value = tasks.length;
      if (tasks.isEmpty) return;

      final futures = tasks.map((task) {
        return _apiService.get(
          '/Marksheet/Get-Marksheet-Single',
          queryParams: {
            'studentId': sid.toString(),
            'taskId': task['taskId'].toString(),
          },
        ).catchError((e) => null); 
      }).toList();

      final results = await Future.wait(futures);

      
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

      
      isFinalResult.value = completed == totalExpectedExams.value && completed > 0;
      
    } catch (e) {
      print("AcademicProgressController Error: $e");
    }
  }

  double _calculateExamPercentage(List<dynamic> marks) {
    double totalObt = 0;
    double totalMarks = 0;

    for (var m in marks) {
      
      totalObt += (m['obtMarks'] ?? 0).toDouble();
      totalMarks += (m['totalMarks'] ?? 0).toDouble();
    }

    if (totalMarks == 0) return 0;
    return (totalObt / totalMarks) * 100;
  }
}