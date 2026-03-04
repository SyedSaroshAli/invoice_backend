/// Composite Marksheet Model
/// Shows all exams/assessments for a complete academic year
library;
// ignore_for_file: file_names

class CompositeMarksheetModel {
  final String academicYear;
  final StudentInfo studentInfo;
  final List<SubjectAssessment> subjectAssessments;
  final DateTime? createdAt;

  CompositeMarksheetModel({
    required this.academicYear,
    required this.studentInfo,
    required this.subjectAssessments,
    this.createdAt,
  });

  factory CompositeMarksheetModel.fromJson(Map<String, dynamic> json) {
    return CompositeMarksheetModel(
      academicYear: json['academicYear'] ?? '',
      studentInfo: StudentInfo.fromJson(json['studentInfo'] ?? {}),
      subjectAssessments: (json['subjectAssessments'] as List<dynamic>?)
              ?.map((item) => SubjectAssessment.fromJson(item))
              .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'academicYear': academicYear,
      'studentInfo': studentInfo.toJson(),
      'subjectAssessments':
          subjectAssessments.map((item) => item.toJson()).toList(),
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  // Calculate totals
  double get totalMaxMarks =>
      subjectAssessments.fold(0.0, (sum, item) => sum + item.aggregateMaxMarks);

  double get totalObtainedMarks => subjectAssessments.fold(
      0.0, (sum, item) => sum + item.aggregateObtainedMarks);

  double get percentage =>
      totalMaxMarks > 0 ? (totalObtainedMarks / totalMaxMarks * 100) : 0;
}

/// Student Information for Composite Marksheet
class StudentInfo {
  final String studentId;
  final String studentName;
  final String fatherName;
  final String rollNo;
  final String className;
  final String position;
  final String result;
  final String grade;
  final String? photoUrl;
  final double totalMaxMarks;
  final double totalObtainedMarks;
  final double percentage;

  StudentInfo({
    required this.studentId,
    required this.studentName,
    required this.fatherName,
    required this.rollNo,
    required this.className,
    required this.position,
    required this.result,
    required this.grade,
    this.photoUrl,
    required this.totalMaxMarks,
    required this.totalObtainedMarks,
    required this.percentage,
  });

  factory StudentInfo.fromJson(Map<String, dynamic> json) {
    return StudentInfo(
      studentId: json['studentId'] ?? '',
      studentName: json['studentName'] ?? '',
      fatherName: json['fatherName'] ?? '',
      rollNo: json['rollNo'] ?? '',
      className: json['className'] ?? '',
      position: json['position'] ?? '',
      result: json['result'] ?? '',
      grade: json['grade'] ?? '',
      photoUrl: json['photoUrl'],
      totalMaxMarks: (json['totalMaxMarks'] ?? 0).toDouble(),
      totalObtainedMarks: (json['totalObtainedMarks'] ?? 0).toDouble(),
      percentage: (json['percentage'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'fatherName': fatherName,
      'rollNo': rollNo,
      'className': className,
      'position': position,
      'result': result,
      'grade': grade,
      'photoUrl': photoUrl,
      'totalMaxMarks': totalMaxMarks,
      'totalObtainedMarks': totalObtainedMarks,
      'percentage': percentage,
    };
  }

  String get tryAgain => result.toLowerCase().contains('try again') ? 'Yes' : 'No';
}

/// Subject Assessment - Contains multiple exams for one subject
class SubjectAssessment {
  final String learningArea;
  final String subject;
  final List<Assessment> assessments;
  final double aggregateMaxMarks;
  final double aggregateObtainedMarks;

  SubjectAssessment({
    required this.learningArea,
    required this.subject,
    required this.assessments,
    required this.aggregateMaxMarks,
    required this.aggregateObtainedMarks,
  });

  factory SubjectAssessment.fromJson(Map<String, dynamic> json) {
    return SubjectAssessment(
      learningArea: json['learningArea'] ?? '',
      subject: json['subject'] ?? '',
      assessments: (json['assessments'] as List<dynamic>?)
              ?.map((item) => Assessment.fromJson(item))
              .toList() ??
          [],
      aggregateMaxMarks: (json['aggregateMaxMarks'] ?? 0).toDouble(),
      aggregateObtainedMarks: (json['aggregateObtainedMarks'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'learningArea': learningArea,
      'subject': subject,
      'assessments': assessments.map((item) => item.toJson()).toList(),
      'aggregateMaxMarks': aggregateMaxMarks,
      'aggregateObtainedMarks': aggregateObtainedMarks,
    };
  }

  double get percentage =>
      aggregateMaxMarks > 0 ? (aggregateObtainedMarks / aggregateMaxMarks * 100) : 0;
}

/// Individual Assessment/Exam
class Assessment {
  final String assessmentId;
  final String assessmentTitle;
  final double maxMarks;
  final double passingMarks;
  final double obtainedMarks;
  final bool isPassed;

  Assessment({
    required this.assessmentId,
    required this.assessmentTitle,
    required this.maxMarks,
    required this.passingMarks,
    required this.obtainedMarks,
    bool? isPassed,
  }) : isPassed = isPassed ?? (obtainedMarks >= passingMarks);

  factory Assessment.fromJson(Map<String, dynamic> json) {
    final obtainedMarks = (json['obtainedMarks'] ?? 0).toDouble();
    final passingMarks = (json['passingMarks'] ?? 0).toDouble();

    return Assessment(
      assessmentId: json['assessmentId'] ?? '',
      assessmentTitle: json['assessmentTitle'] ?? '',
      maxMarks: (json['maxMarks'] ?? 0).toDouble(),
      passingMarks: passingMarks,
      obtainedMarks: obtainedMarks,
      isPassed: json['isPassed'] ?? (obtainedMarks >= passingMarks),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'assessmentId': assessmentId,
      'assessmentTitle': assessmentTitle,
      'maxMarks': maxMarks,
      'passingMarks': passingMarks,
      'obtainedMarks': obtainedMarks,
      'isPassed': isPassed,
    };
  }

  double get percentage => maxMarks > 0 ? (obtainedMarks / maxMarks * 100) : 0;
}