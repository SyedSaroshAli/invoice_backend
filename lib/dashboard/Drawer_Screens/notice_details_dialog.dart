import 'package:flutter/material.dart';
import 'package:school_management_system/models/noticesModel.dart';
import 'package:school_management_system/services/notice_file_service.dart';

void showNoticeDetails(BuildContext context, NoticeModel notice) {
  showDialog(
    context: context,
    builder: (_) => _NoticeDetailsDialog(notice: notice),
  );
}

class _NoticeDetailsDialog extends StatelessWidget {
  final NoticeModel notice;

  const _NoticeDetailsDialog({required this.notice});

  @override
  Widget build(BuildContext context) {
    final url = notice.fileUrl ?? '';

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              notice.title,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Text(notice.description),

            const SizedBox(height: 15),

            if (url.isNotEmpty) ...[
              _AttachmentPreview(url: url),
              const SizedBox(height: 10),
              _ActionRow(url: url),
            ],

            const SizedBox(height: 15),

            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttachmentPreview extends StatelessWidget {
  final String url;
  const _AttachmentPreview({required this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.insert_drive_file),
          const SizedBox(width: 10),
          Expanded(child: Text(url.split('/').last)),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final String url;
  const _ActionRow({required this.url});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => NoticeFileService.downloadFile(
              context,
              url: url,
              filename: url.split('/').last,
            ),
            child: const Text("Download"),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            onPressed: () => NoticeFileService.shareFile(
              context,
              url: url,
              filename: url.split('/').last,
            ),
            child: const Text("Share"),
          ),
        ),
      ],
    );
  }
}