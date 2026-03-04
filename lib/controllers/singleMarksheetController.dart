// ignore_for_file: file_names

import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:school_management_system/models/singleMarksheetModel.dart';
import 'package:school_management_system/services/api_service.dart';
import 'package:school_management_system/services/auth_service.dart';

class MarksheetController extends GetxController {
  // Observable variables
  final isLoading = false.obs;
  final isGeneratingPdf = false.obs;
  final isFilterExpanded = false.obs;
  final selectedYear = Rx<FilterOption?>(null);
  final selectedTask = Rx<FilterOption?>(null);
  final selectedSubject = Rx<FilterOption?>(null);
  final marksheet = Rx<MarksheetModel?>(null);
  final errorMessage = ''.obs;

  // Filter options
  final yearOptions = <FilterOption>[].obs;
  final taskOptions = <FilterOption>[].obs;
  final subjectOptions = <FilterOption>[].obs;

  final _api = ApiService();
  final _auth = AuthService();

  @override
  void onInit() {
    super.onInit();
    _initializeFilters();
  }

  /// Initialize filter options from API
  Future<void> _initializeFilters() async {
    // Year options (static for now, could be fetched from API)
    yearOptions.value = [
      FilterOption(id: '1', name: '2024-2025'),
      FilterOption(id: '2', name: '2023-2024'),
      FilterOption(id: '3', name: '2022-2023'),
    ];

    // Fetch task options from API
    try {
      final tasksResponse = await _api.get('/Marksheet/tasks');
      if (tasksResponse is List) {
        taskOptions.value = tasksResponse
            .map(
              (t) => FilterOption(
                id: (t['taskId'] ?? '').toString(),
                name: (t['taskName'] ?? '').toString(),
              ),
            )
            .toList();
      }
    } catch (_) {
      // Fallback to defaults if API fails
      taskOptions.value = [
        FilterOption(id: '1', name: 'Mid Term'),
        FilterOption(id: '2', name: 'Annual Term'),
        FilterOption(id: '3', name: 'Preliminary Test (Fall)'),
        FilterOption(id: '4', name: 'Preliminary Test (Spring)'),
      ];
    }

    // Fetch subject options from API based on student class
    // For now use "All Subjects" as default, subjects loaded per class
    subjectOptions.value = [FilterOption(id: '0', name: 'All Subjects')];
    await _loadSubjects();

    // Set default selections
    if (yearOptions.isNotEmpty) selectedYear.value = yearOptions.first;
    if (taskOptions.isNotEmpty) selectedTask.value = taskOptions.first;
    if (subjectOptions.isNotEmpty) selectedSubject.value = subjectOptions.first;

    // Load initial marksheet
    loadMarksheet();
  }

  /// Load subjects from API
  Future<void> _loadSubjects() async {
    try {
      // Try classId 1 as default — in production this would come from user data
      final response = await _api.get('/Subjects/by-class/1');
      if (response is List) {
        final apiSubjects = response
            .map(
              (s) => FilterOption(
                id: (s['subjectId'] ?? '').toString(),
                name: (s['subjectName'] ?? '').toString(),
              ),
            )
            .toList();

        subjectOptions.value = [
          FilterOption(id: '0', name: 'All Subjects'),
          ...apiSubjects,
        ];
      }
    } catch (_) {
      // Keep the default "All Subjects" if API fails
    }
  }

  /// Load marksheet based on selected filters from API
  Future<void> loadMarksheet() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final studentId = await _auth.getStudentId();
      if (studentId == null || studentId.isEmpty) {
        errorMessage.value = 'Student ID not found. Please login again.';
        marksheet.value = null;
        return;
      }

      final taskId = selectedTask.value?.id;
      if (taskId == null) {
        errorMessage.value = 'Please select a task/exam.';
        return;
      }

      final response = await _api.get(
        '/Marksheet/Get-Marksheet-Single',
        queryParams: {'studentId': studentId, 'taskId': taskId},
      );

      if (response is List && response.isNotEmpty) {
        marksheet.value = _parseMarksheetResponse(
          response.cast<Map<String, dynamic>>(),
        );
      } else if (response is Map<String, dynamic>) {
        marksheet.value = MarksheetModel.fromJson(response);
      } else if (response is String) {
        // API returns plain text errors like "Marksheet not found."
        errorMessage.value = response;
        marksheet.value = null;
      } else {
        errorMessage.value = 'No marksheet data found.';
        marksheet.value = null;
      }
    } on ApiException catch (e) {
      errorMessage.value = e.message;
      marksheet.value = null;
    } catch (e) {
      errorMessage.value = 'Failed to load marksheet: ${e.toString()}';
      marksheet.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  /// Parse the flat List of subject records into a grouped MarksheetModel
  MarksheetModel _parseMarksheetResponse(List<Map<String, dynamic>> records) {
    final first = records.first;

    double totalMax = 0;
    double totalObt = 0;

    final subjects = records.map((json) {
      final maxM = (json['totalMarks'] ?? 0).toDouble();
      final obtM = (json['obtMarks'] ?? 0).toDouble();
      final passingM = (json['passingMarks'] ?? 0).toDouble();

      totalMax += maxM;
      totalObt += obtM;

      return SubjectMark(
        subjectId: json['subjectName'] ?? '',
        subjectName: json['subjectName'] ?? '',
        maximumMarks: maxM,
        passingMarks: passingM,
        obtainedMarks: obtM,
        isPassed: obtM >= passingM,
        grade: _calculateGrade(obtM, maxM),
      );
    }).toList();

    final percentage = totalMax > 0 ? (totalObt / totalMax) * 100 : 0.0;

    return MarksheetModel(
      studentInfo: StudentInfo(
        studentId: (first['studentId'] ?? '').toString(),
        name: (first['name'] ?? '').toString().trim(),
        fatherName: (first['fatherName'] ?? '').toString().trim(),
        rollNumber: (first['rollNo'] ?? '').toString(),
        grade: (first['classDesc'] ?? '').toString(),
        result: percentage >= 40 ? "PASS" : "FAIL",
        resultStatus: percentage >= 40 ? "PASS" : "FAIL",
        totalMarks: totalMax,
        obtainedMarks: totalObt,
        percentage: percentage.toStringAsFixed(2),
        remarks: percentage >= 40 ? "Promoted" : "Needs Improvement",
        remarksGrade: _calculateGrade(totalObt, totalMax),
      ),
      session: selectedYear.value?.name ?? '',
      taskName: selectedTask.value?.name ?? '',
      subjects: subjects,
    );
  }

  String _calculateGrade(double obt, double max) {
    if (max == 0) return '';
    final pct = (obt / max) * 100;
    if (pct >= 80) return "A+";
    if (pct >= 70) return "A";
    if (pct >= 60) return "B";
    if (pct >= 50) return "C";
    if (pct >= 40) return "D";
    return "F";
  }

  /// Handle year filter change
  void onYearChanged(FilterOption? year) {
    if (year != null && selectedYear.value?.id != year.id) {
      selectedYear.value = year;
      loadMarksheet();
    }
  }

  /// Handle task filter change
  void onTaskChanged(FilterOption? task) {
    if (task != null && selectedTask.value?.id != task.id) {
      selectedTask.value = task;
      loadMarksheet();
    }
  }

  /// Handle subject filter change
  void onSubjectChanged(FilterOption? subject) {
    if (subject != null && selectedSubject.value?.id != subject.id) {
      selectedSubject.value = subject;
      // Subject filter is applied client-side if marksheet data is already loaded
      // No need to re-fetch from API
    }
  }

  /// Refresh marksheet data
  Future<void> refreshMarksheet() async {
    await loadMarksheet();
  }

  /// Toggle filter section expansion
  void toggleFilter() {
    isFilterExpanded.value = !isFilterExpanded.value;
  }

  /// Generate PDF from marksheet
  Future<void> generatePdf() async {
    if (marksheet.value == null) {
      Get.snackbar(
        'Error',
        'No marksheet data available to generate PDF',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isGeneratingPdf.value = true;

      final pdf = pw.Document();
      final data = marksheet.value!;

      // Add page to PDF
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (context) => _buildPdfContent(data),
        ),
      );

      // Save and share PDF
      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename:
            'Marksheet_${data.studentInfo.name.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );

      Get.snackbar(
        'Success',
        'PDF generated successfully',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to generate PDF: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isGeneratingPdf.value = false;
    }
  }

  /// Build PDF content
  pw.Widget _buildPdfContent(MarksheetModel data) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildPdfHeader(data),
        pw.SizedBox(height: 20),
        _buildPdfStudentInfo(data.studentInfo),
        pw.SizedBox(height: 20),
        _buildPdfMarksTable(data.subjects),
        pw.SizedBox(height: 20),
        _buildPdfFooter(),
      ],
    );
  }

  pw.Widget _buildPdfHeader(MarksheetModel data) {
    return pw.Container(
      decoration: pw.BoxDecoration(border: pw.Border.all(width: 2)),
      padding: const pw.EdgeInsets.all(16),
      child: pw.Column(
        children: [
          pw.Text(
            data.schoolName ?? 'BENCHMARK School of Leadership',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            data.schoolTagline ?? 'PLAY GROUP TO O\' MATRIC',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            data.taskName,
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Text(data.session, style: const pw.TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  pw.Widget _buildPdfStudentInfo(StudentInfo info) {
    return pw.Table(
      border: pw.TableBorder.all(),
      children: [
        _buildPdfTableRow('Student\'s Name:', info.name, 'Class:', info.grade),
        _buildPdfTableRow(
          'Father\'s Name:',
          info.fatherName,
          'Roll #:',
          info.rollNumber,
        ),
        _buildPdfTableRow(
          'Result:',
          info.result,
          'Max. Marks:',
          info.totalMarks.toStringAsFixed(0),
        ),
        _buildPdfTableRow(
          'Remarks:',
          info.remarks,
          'Obt. Marks:',
          '${info.obtainedMarks.toStringAsFixed(0)} / ${info.totalMarks.toStringAsFixed(0)}',
        ),
        _buildPdfTableRow(
          '',
          '',
          'Percentage:',
          info.percentage,
          'Grade:',
          info.remarksGrade,
        ),
      ],
    );
  }

  pw.TableRow _buildPdfTableRow(
    String label1,
    String value1, [
    String? label2,
    String? value2,
    String? label3,
    String? value3,
  ]) {
    return pw.TableRow(
      children: [
        _buildPdfCell(label1, isBold: true),
        _buildPdfCell(value1),
        if (label2 != null) _buildPdfCell(label2, isBold: true),
        if (value2 != null) _buildPdfCell(value2),
        if (label3 != null) _buildPdfCell(label3, isBold: true),
        if (value3 != null) _buildPdfCell(value3),
      ],
    );
  }

  pw.Widget _buildPdfCell(String text, {bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  pw.Widget _buildPdfMarksTable(List<SubjectMark> subjects) {
    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(2),
        3: const pw.FlexColumnWidth(2),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _buildPdfCell('SUBJECT', isBold: true),
            _buildPdfCell('MAXIMUM MARKS', isBold: true),
            _buildPdfCell('PASSING MARKS', isBold: true),
            _buildPdfCell('OBTAINED MARKS', isBold: true),
          ],
        ),
        ...subjects.map(
          (subject) => pw.TableRow(
            children: [
              _buildPdfCell(subject.subjectName),
              _buildPdfCell(subject.maximumMarks.toStringAsFixed(2)),
              _buildPdfCell(subject.passingMarks.toStringAsFixed(2)),
              _buildPdfCell(subject.obtainedMarks.toStringAsFixed(2)),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildPdfFooter() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(height: 1, width: 150, color: PdfColors.black),
            pw.SizedBox(height: 4),
            pw.Text(
              'SIGN: CLASS TEACHER',
              style: const pw.TextStyle(fontSize: 10),
            ),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(height: 1, width: 150, color: PdfColors.black),
            pw.SizedBox(height: 4),
            pw.Text('SIGN: PRINCIPAL', style: const pw.TextStyle(fontSize: 10)),
          ],
        ),
      ],
    );
  }

}
