
class FeeRecord {
  final int studentId;
  final String year;
  final String month;
  final double fee;
  final String feeDate;
  final int slipNo;
  final String details;

  FeeRecord({
    required this.studentId,
    required this.year,
    required this.month,
    required this.fee,
    required this.feeDate,
    required this.slipNo,
    required this.details,
  });

  factory FeeRecord.fromJson(Map<String, dynamic> json) {
    return FeeRecord(
      studentId: json['studentId'] ?? 0,
      year: (json['year'] ?? '').toString().trim(),
      month: (json['months'] ?? '').toString().trim(),
      fee: (json['fee'] ?? 0).toDouble(),
      feeDate: (json['feeDate'] ?? '').toString().trim(),
      slipNo: json['slipNo'] ?? 0,
      details: (json['details'] ?? 'Monthly Fee').toString().trim(),
    );
  }
}
