
library;

class AttendanceResponse {
  final String studentId;
  final String month;
  final int present;
  final int absent;
  final int late;
  final int total;
  final List<AttendanceRecord> records;

  AttendanceResponse({
    required this.studentId,
    required this.month,
    required this.present,
    required this.absent,
    required this.late,
    required this.total,
    required this.records,
  });

  factory AttendanceResponse.fromJson(Map<String, dynamic> json) {
    return AttendanceResponse(
      studentId: (json['studentId'] ?? '').toString(),
      month: (json['month'] ?? '').toString(),
      present: (json['present'] ?? 0) as int,
      absent: (json['absent'] ?? 0) as int,
      late: (json['late'] ?? 0) as int,
      total: (json['total'] ?? 0) as int,
      records:
          (json['records'] as List<dynamic>?)
              ?.map((r) => AttendanceRecord.fromJson(r))
              .toList() ??
          [],
    );
  }
}

class AttendanceRecord {
  final String date;
  final String status; // "P" = Present, "A" = Absent, "L" = Late, etc.

  AttendanceRecord({required this.date, required this.status});

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      date: (json['date'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
    );
  }
}
