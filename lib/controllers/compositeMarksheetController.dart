// ignore_for_file: file_names, avoid_print, unnecessary_overrides

import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:school_management_system/models/compositeMarksheetModel.dart';
import 'package:school_management_system/services/api_service.dart';
import 'package:school_management_system/services/auth_service.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class CompositeMarksheetController extends GetxController {
  // Observable variables
  final isLoading = false.obs;
  final isFilterExpanded = false.obs;
  final errorMessage = ''.obs;
  final yearlyMarks = <CompositeMarksheetModel>[].obs;
  final selectedMarksheet = Rx<CompositeMarksheetModel?>(null);
  final marksheetData = Rxn<CompositeMarksheetModel>();
  final isGeneratingPdf = false.obs;

  // Filters
  final selectedYear = Rx<String?>(null);
  final availableYears = <String>[].obs;

  final _api = ApiService();
  final _auth = AuthService();

  @override
  void onInit() {
    super.onInit();
    loadYearlyData();
  }

  /// Load yearly composite marksheet data from API.
  /// The API returns a flat list of per-subject-per-task records.
  /// We group them into a nested CompositeMarksheetModel structure.
  Future<void> loadYearlyData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final studentId = await _auth.getStudentId();
      if (studentId == null || studentId.isEmpty) {
        errorMessage.value = 'Student ID not found.';
        return;
      }

      // API expects plain year like '2025', '2024', etc. — not '2025-2026'
      final currentYear = DateTime.now().year;
      final years = [
        currentYear.toString(),
        (currentYear - 1).toString(),
        (currentYear - 2).toString(),
      ];
      List<CompositeMarksheetModel> allMarksheets = [];

      for (final year in years) {
        try {
          final response = await _api.get(
            '/Composite/Get-CompositeMarksheet',
            queryParams: {'StudentId': studentId, 'Year': year},
          );

          // API may return a plain string like "No Record Found"
          if (response is String) continue;

          if (response is List && response.isNotEmpty) {
            final grouped = _groupApiResponse(
              response.cast<Map<String, dynamic>>(),
              year,
            );
            if (grouped != null) {
              allMarksheets.add(grouped);
            }
          }
        } catch (_) {
          // Skip years with no data
        }
      }

      if (allMarksheets.isEmpty) {
        errorMessage.value = 'No composite marksheet data found.';
        return;
      }

      yearlyMarks.value = allMarksheets;

      // Extract available years
      availableYears.value =
          yearlyMarks.map((m) => m.academicYear).toSet().toList()
            ..sort((a, b) => b.compareTo(a));

      if (availableYears.isNotEmpty) {
        selectedYear.value = availableYears.first;
        _setCurrentMarksheetForSelectedYear();
      }
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = 'Failed to load marksheets: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  /// Group flat API response into nested CompositeMarksheetModel.
  ///
  /// API returns: [{subjectName, taskName, totalMarks, passingMarks, obtMarks, learningArea, ...}]
  /// We group by subject → list of assessments (tasks)
  CompositeMarksheetModel? _groupApiResponse(
    List<Map<String, dynamic>> records,
    String year,
  ) {
    if (records.isEmpty) return null;

    // Extract student info from first record
    final first = records.first;
    final studentId = (first['studentId'] ?? '').toString();
    final studentName = (first['name'] ?? '').toString();
    final fatherName = (first['fatherName'] ?? '').toString();
    final rollNo = (first['rollNo'] ?? '').toString();
    final classDesc = (first['classDesc'] ?? '').toString();

    // Group records by subject
    final Map<String, List<Map<String, dynamic>>> bySubject = {};
    for (final record in records) {
      final subjectName = (record['subjectName'] ?? '').toString();
      bySubject.putIfAbsent(subjectName, () => []).add(record);
    }

    // Build SubjectAssessments
    final subjectAssessments = <SubjectAssessment>[];
    double totalMaxAll = 0;
    double totalObtAll = 0;

    for (final entry in bySubject.entries) {
      final assessments = <Assessment>[];
      double aggMax = 0;
      double aggObt = 0;

      for (final r in entry.value) {
        final maxM = (r['totalMarks'] ?? 0).toDouble();
        final passM = (r['passingMarks'] ?? 0).toDouble();
        final obtM = (r['obtMarks'] ?? 0).toDouble();

        assessments.add(
          Assessment(
            assessmentId: (r['id'] ?? '').toString(),
            assessmentTitle: (r['taskName'] ?? '').toString(),
            maxMarks: maxM,
            passingMarks: passM,
            obtainedMarks: obtM,
          ),
        );

        aggMax += maxM;
        aggObt += obtM;
      }

      totalMaxAll += aggMax;
      totalObtAll += aggObt;

      subjectAssessments.add(
        SubjectAssessment(
          learningArea: (entry.value.first['learningArea'] ?? '').toString(),
          subject: entry.key,
          assessments: assessments,
          aggregateMaxMarks: aggMax,
          aggregateObtainedMarks: aggObt,
        ),
      );
    }

    final percentage = totalMaxAll > 0
        ? (totalObtAll / totalMaxAll * 100).toDouble()
        : 0.0;
    final grade = _calculateGrade(percentage);

    return CompositeMarksheetModel(
      academicYear: year,
      studentInfo: StudentInfo(
        studentId: studentId,
        studentName: studentName,
        fatherName: fatherName,
        rollNo: rollNo,
        className: classDesc,
        position: '',
        result: percentage >= 40 ? 'PASS' : 'TRY AGAIN',
        grade: grade,
        totalMaxMarks: totalMaxAll,
        totalObtainedMarks: totalObtAll,
        percentage: percentage.toDouble(),
      ),
      subjectAssessments: subjectAssessments,
      createdAt: DateTime.now(),
    );
  }

  String _calculateGrade(double percentage) {
    if (percentage >= 90) return 'A+';
    if (percentage >= 80) return 'A';
    if (percentage >= 70) return 'B';
    if (percentage >= 60) return 'C';
    if (percentage >= 50) return 'D';
    if (percentage >= 40) return 'E';
    return 'F';
  }

  /// Select a marksheet to view details
  void selectMarksheet(CompositeMarksheetModel marksheet) {
    selectedMarksheet.value = marksheet;
    marksheetData.value = marksheet;
  }

  /// Filter by year
  void filterByYear(String year) {
    selectedYear.value = year;
    _setCurrentMarksheetForSelectedYear();
  }

  /// Get filtered marksheets
  List<CompositeMarksheetModel> get filteredMarksheets {
    if (selectedYear.value == null) return yearlyMarks;
    return yearlyMarks
        .where((m) => m.academicYear == selectedYear.value)
        .toList();
  }

  void _setCurrentMarksheetForSelectedYear() {
    final year = selectedYear.value;
    if (year == null) return;

    final byYear = yearlyMarks.where((m) => m.academicYear == year).toList();
    if (byYear.isEmpty) {
      selectedMarksheet.value = null;
      marksheetData.value = null;
      return;
    }

    byYear.sort((a, b) {
      final aTs = a.createdAt?.millisecondsSinceEpoch ?? 0;
      final bTs = b.createdAt?.millisecondsSinceEpoch ?? 0;
      return bTs.compareTo(aTs);
    });

    selectMarksheet(byYear.first);
  }

  void toggleFilter() {
    isFilterExpanded.value = !isFilterExpanded.value;
  }

  /// Generate PDF for selected marksheet
  Future<void> generatePdf() async {
    if (selectedMarksheet.value == null) {
      Get.snackbar(
        'Error',
        'No marksheet selected',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isGeneratingPdf.value = true;

      final pdf = pw.Document();
      final marksheet = selectedMarksheet.value!;

      // Load fonts
      final robotoRegular = await PdfGoogleFonts.robotoRegular();
      final robotoBold = await PdfGoogleFonts.robotoBold();

      // Load student photo if available
      pw.ImageProvider? studentPhoto;
      if (marksheet.studentInfo.photoUrl != null &&
          marksheet.studentInfo.photoUrl!.isNotEmpty) {
        try {
          studentPhoto = await networkImage(marksheet.studentInfo.photoUrl!);
        } catch (e) {
          // Photo load failure — silently continue without photo
        }
      }

      // Add page to PDF
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(30),
          build: (context) => [
            _buildPdfHeader(marksheet, studentPhoto, robotoBold),
            pw.SizedBox(height: 16),
            _buildPdfStudentInfo(
              marksheet.studentInfo,
              robotoRegular,
              robotoBold,
            ),
            pw.SizedBox(height: 16),
            _buildPdfTable(marksheet, robotoRegular, robotoBold),
            pw.SizedBox(height: 30),
            _buildPdfFooter(robotoRegular),
          ],
        ),
      );

      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename:
            'Transcript_${marksheet.studentInfo.studentName.replaceAll(' ', '_')}_${marksheet.academicYear}.pdf',
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

  // ─── PDF Building Helpers (unchanged) ──────────────────

  pw.Widget _buildPdfHeader(
    CompositeMarksheetModel marksheet,
    pw.ImageProvider? photo,
    pw.Font boldFont,
  ) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Expanded(flex: 1, child: pw.SizedBox()),
        pw.Expanded(
          flex: 4,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(
                'TRANSCRIPT',
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 26,
                  color: PdfColors.black,
                ),
              ),
              pw.SizedBox(height: 12),
              pw.Text(
                'FOR THE ACADEMIC YEAR ${marksheet.academicYear}',
                style: pw.TextStyle(
                  font: boldFont,
                  fontSize: 16,
                  color: PdfColors.black,
                ),
              ),
            ],
          ),
        ),
        pw.Expanded(
          flex: 1,
          child: pw.Align(
            alignment: pw.Alignment.topRight,
            child: pw.Container(
              width: 80,
              height: 100,
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.black, width: 1.5),
              ),
              child: photo != null
                  ? pw.Image(photo, fit: pw.BoxFit.cover)
                  : pw.SizedBox(),
            ),
          ),
        ),
      ],
    );
  }

  pw.Widget _buildPdfStudentInfo(
    StudentInfo info,
    pw.Font regFont,
    pw.Font boldFont,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(width: 1),
      columnWidths: {
        0: const pw.FlexColumnWidth(1.2),
        1: const pw.FlexColumnWidth(3),
        2: const pw.FlexColumnWidth(0.8),
        3: const pw.FlexColumnWidth(0.8),
        4: const pw.FlexColumnWidth(2),
      },
      children: [
        pw.TableRow(
          children: [
            _tableInfoCell('Student\'s\nName', boldFont, alignLeft: true),
            _tableInfoCell(info.studentName.toUpperCase(), regFont),
            _tableInfoCell('Std. Id', boldFont),
            _tableInfoCell('Class', boldFont),
            _tableInfoCell(info.className.toUpperCase(), regFont),
          ],
        ),
        pw.TableRow(
          children: [
            _tableInfoCell('Father\'s\nName', boldFont, alignLeft: true),
            _tableInfoCell(info.fatherName.toUpperCase(), regFont),
            _tableInfoCell(info.studentId, regFont),
            _tableInfoCell('Roll #', boldFont),
            _tableInfoCell(info.rollNo, regFont),
          ],
        ),
        pw.TableRow(
          children: [
            _tableInfoCell('Result', boldFont, alignLeft: true),
            _tableInfoCell(info.result.toUpperCase(), regFont),
            _tableInfoCell('Max.\nMarks', boldFont),
            _tableInfoCell(info.totalMaxMarks.toStringAsFixed(0), regFont),
            _tableInfoCell('Percentage', boldFont),
            _tableInfoCell('${info.percentage.toStringAsFixed(2)} %', regFont),
          ],
        ),
        pw.TableRow(
          children: [
            _tableInfoCell('Position', boldFont, alignLeft: true),
            _tableInfoCell(
              info.position.isEmpty ? " " : info.position.toUpperCase(),
              regFont,
            ),
            _tableInfoCell('Obt.\nMarks', boldFont),
            _tableInfoCell(info.totalObtainedMarks.toStringAsFixed(0), regFont),
            _tableInfoCell('Grade', boldFont),
            _tableInfoCell(info.grade.toUpperCase(), regFont),
          ],
        ),
      ],
    );
  }

  pw.Widget _tableInfoCell(
    String text,
    pw.Font font, {
    bool alignLeft = false,
  }) {
    return pw.Container(
      alignment: alignLeft ? pw.Alignment.centerLeft : pw.Alignment.center,
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        textAlign: alignLeft ? pw.TextAlign.left : pw.TextAlign.center,
        style: pw.TextStyle(font: font, fontSize: 8.5),
      ),
    );
  }

  pw.Widget _buildPdfTable(
    CompositeMarksheetModel marksheet,
    pw.Font regFont,
    pw.Font boldFont,
  ) {
    return pw.Table(
      border: pw.TableBorder.all(width: 1),
      columnWidths: {
        0: const pw.FlexColumnWidth(1.8),
        1: const pw.FlexColumnWidth(1.8),
        2: const pw.FlexColumnWidth(4.9),
        3: const pw.FlexColumnWidth(1.2),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _headerCell('Learning Area', boldFont),
            _headerCell('Subject', boldFont),
            pw.Table(
              border: pw.TableBorder.all(width: 1),
              columnWidths: {
                0: const pw.FlexColumnWidth(2.5),
                1: const pw.FlexColumnWidth(0.8),
                2: const pw.FlexColumnWidth(0.8),
                3: const pw.FlexColumnWidth(0.8),
              },
              children: [
                pw.TableRow(
                  children: [
                    _headerCell('Assessment Title', boldFont),
                    _headerCell('Max\nMarks', boldFont),
                    _headerCell('Passing\nMarks', boldFont),
                    _headerCell('Obt\nMarks', boldFont),
                  ],
                ),
              ],
            ),
            _headerCell('Agg.\nMarks', boldFont),
          ],
        ),
        ...marksheet.subjectAssessments.map((sa) {
          return pw.TableRow(
            children: [
              _dataCell(sa.learningArea.toUpperCase(), regFont),
              _dataCell(sa.subject.toUpperCase(), boldFont),
              pw.Table(
                border: pw.TableBorder.all(width: 1),
                columnWidths: {
                  0: const pw.FlexColumnWidth(2.5),
                  1: const pw.FlexColumnWidth(0.8),
                  2: const pw.FlexColumnWidth(0.8),
                  3: const pw.FlexColumnWidth(0.8),
                },
                children: sa.assessments.map((a) {
                  return pw.TableRow(
                    children: [
                      _dataCell(a.assessmentTitle, regFont, alignLeft: true),
                      _dataCell(a.maxMarks.toStringAsFixed(0), regFont),
                      _dataCell(a.passingMarks.toStringAsFixed(0), regFont),
                      _dataCell(a.obtainedMarks.toStringAsFixed(0), regFont),
                    ],
                  );
                }).toList(),
              ),
              _dataCell(
                sa.aggregateObtainedMarks.toStringAsFixed(0),
                boldFont,
                background: PdfColors.blue50,
              ),
            ],
          );
        }),
      ],
    );
  }

  pw.Widget _headerCell(String text, pw.Font font) {
    return pw.Container(
      alignment: pw.Alignment.center,
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(font: font, fontSize: 9),
      ),
    );
  }

  pw.Widget _dataCell(
    String text,
    pw.Font font, {
    bool alignLeft = false,
    PdfColor? background,
  }) {
    return pw.Container(
      color: background,
      alignment: alignLeft ? pw.Alignment.centerLeft : pw.Alignment.center,
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        textAlign: alignLeft ? pw.TextAlign.left : pw.TextAlign.center,
        style: pw.TextStyle(font: font, fontSize: 8.5),
      ),
    );
  }

  pw.Widget _buildPdfFooter(pw.Font regFont) {
    return pw.Column(
      children: [
        pw.SizedBox(height: 40),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            _buildSignature('Class Teacher', regFont),
            _buildSignature('Principal', regFont),
            _buildSignature('Parent/Guardian', regFont),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildSignature(String label, pw.Font regFont) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(width: 120, height: 1.5, color: PdfColors.black),
        pw.SizedBox(height: 4),
        pw.Text(label, style: pw.TextStyle(font: regFont, fontSize: 9)),
      ],
    );
  }
}
