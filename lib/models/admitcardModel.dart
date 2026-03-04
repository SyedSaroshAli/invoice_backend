// ignore_for_file: file_names
/*
class AdmitCardModel {
  final String schoolName;
  final String schoolTagline;
  final String schoolSubTagline;
  final String examTitle;

  final String studentName;
  final String fatherName;
  final String className;
  final String section;
  final String admissionNo;
  final String grNo;
  final String seatNo;

  final String? logoUrl;
  final String? photoUrl;

  AdmitCardModel({
    required this.schoolName,
    required this.schoolTagline,
    required this.schoolSubTagline,
    required this.examTitle,
    required this.studentName,
    required this.fatherName,
    required this.className,
    required this.section,
    required this.admissionNo,
    required this.grNo,
    required this.seatNo,
    this.logoUrl,
    this.photoUrl,
  });

  /// Parse from API response.
  /// The API may return varied field names — handle common variants.
  factory AdmitCardModel.fromJson(Map<String, dynamic> json) {
    return AdmitCardModel(
      schoolName: (json['schoolName'] ?? json['school_name'] ?? 'BENCHMARK')
          .toString(),
      schoolTagline:
          (json['schoolTagline'] ??
                  json['school_tagline'] ??
                  'School of Leadership')
              .toString(),
      schoolSubTagline:
          (json['schoolSubTagline'] ??
                  json['school_sub_tagline'] ??
                  'PLAY GROUP TO MATRIC')
              .toString(),
      examTitle:
          (json['examTitle'] ?? json['exam_title'] ?? json['taskName'] ?? '')
              .toString(),
      studentName:
          (json['studentName'] ?? json['student_name'] ?? json['name'] ?? '')
              .toString(),
      fatherName:
          (json['fatherName'] ??
                  json['father_name'] ??
                  json['fatherName'] ??
                  '')
              .toString(),
      className:
          (json['className'] ?? json['class_name'] ?? json['classDesc'] ?? '')
              .toString(),
      section: (json['section'] ?? '').toString(),
      admissionNo:
          (json['admissionNo'] ??
                  json['admission_no'] ??
                  json['studentId'] ??
                  '')
              .toString(),
      grNo: (json['grNo'] ?? json['gr_no'] ?? '').toString(),
      seatNo: (json['seatNo'] ?? json['seat_no'] ?? json['rollNo'] ?? '')
          .toString(),
      logoUrl: json['logoUrl'] ?? json['logo_url'],
      photoUrl: json['photoUrl'] ?? json['photo_url'] ?? json['pic'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'schoolName': schoolName,
      'schoolTagline': schoolTagline,
      'schoolSubTagline': schoolSubTagline,
      'examTitle': examTitle,
      'studentName': studentName,
      'fatherName': fatherName,
      'className': className,
      'section': section,
      'admissionNo': admissionNo,
      'grNo': grNo,
      'seatNo': seatNo,
      'logoUrl': logoUrl,
      'photoUrl': photoUrl,
    };
  }
}
*/
class AdmitCardModel {
  final int studentId;
  final int year;
  final int classId;
  final String className; // Maps from Swagger "class"
  final int rollNo;
  final String examTitle; // Maps from Swagger "examTypeDesc"
  final String? photoUrl; // Maps from Swagger "pic"
  final String grNo;
  final String section;
  final int seatNo;
  final String fatherName;
  final String studentName; // Maps from Swagger "name"
  final int taskId;

  AdmitCardModel({
    required this.studentId,
    required this.year,
    required this.classId,
    required this.className,
    required this.rollNo,
    required this.examTitle,
    this.photoUrl,
    required this.grNo,
    required this.section,
    required this.seatNo,
    required this.fatherName,
    required this.studentName,
    required this.taskId,
  });

  factory AdmitCardModel.fromJson(Map<String, dynamic> json) {
    return AdmitCardModel(
      studentId: json['studentId'] ?? 0,
      year: json['year'] ?? 0,
      classId: json['classId'] ?? 0,
      className: json['class'] ?? '',
      rollNo: json['rollNo'] ?? 0,
      examTitle: json['examTypeDesc'] ?? '', // This will capture "Mid Term" from Swagger
      photoUrl: json['pic'],
      grNo: json['grNo']?.toString().trim() ?? '0',
      section: json['section'] ?? '',
      seatNo: json['seatNo'] ?? 0,
      fatherName: (json['fatherName'] ?? '').toString().trim(),
      studentName: (json['name'] ?? '').toString().trim(),
      taskId: json['taskId'] ?? 0,
    );
  }
}