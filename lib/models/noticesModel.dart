class NoticeModel {
  final int noticeId;
  final String title;
  final String description;
  final DateTime date;
  final bool isSelected;

  // ✅ IMPORTANT: FILE FIELD FROM API
  final String? fileUrl;

  NoticeModel({
    this.noticeId = 0,
    required this.title,
    required this.description,
    required this.date,
    this.isSelected = false,
    this.fileUrl,
  });

  // ✅ SAFE FILE CHECK
  bool get hasFile => fileUrl != null && fileUrl!.trim().isNotEmpty;

  // ✅ FILE TYPE HELPERS (VERY USEFUL FOR UI)
  bool get isPdf =>
      hasFile && fileUrl!.toLowerCase().contains('.pdf');

  bool get isImage =>
      hasFile &&
      (fileUrl!.toLowerCase().contains('.png') ||
          fileUrl!.toLowerCase().contains('.jpg') ||
          fileUrl!.toLowerCase().contains('.jpeg'));

  factory NoticeModel.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;

    try {
      parsedDate = DateTime.parse(json['date'] ?? '');
    } catch (_) {
      parsedDate = DateTime.now();
    }

    return NoticeModel(
      noticeId: (json['noticeId'] ?? 0) is int
          ? json['noticeId']
          : int.tryParse(json['noticeId'].toString()) ?? 0,

      title: (json['note'] ?? '').toString().trim(),

      description: (json['notice'] ?? '').toString().trim(),

      date: parsedDate,

      isSelected: json['isSelected'] ?? false,

      // ✅ FIXED: YOUR REAL API FIELD
      fileUrl: json['imagePdf']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'noticeId': noticeId,
      'note': title,
      'notice': description,
      'date': date.toIso8601String(),
      'isSelected': isSelected,
      'imagePdf': fileUrl,
    };
  }
}