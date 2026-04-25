// ignore_for_file: file_names
class AdmitCardModel {
  final int studentId;
  final int year;
  final int classId;
  final String className; 
  final int rollNo;
  final String examTitle; 
  final String? photoUrl; 
  final String grNo;
  final String section;
  final int seatNo;
  final String fatherName;
  final String studentName; 
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
      examTitle: json['examTypeDesc'] ?? '', 
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