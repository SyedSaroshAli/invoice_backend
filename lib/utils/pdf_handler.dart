import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';

class PdfHandler {
  /// Handles the action of either sharing or downloading the generated PDF.
  static Future<void> handlePdfAction(
    BuildContext context,
    Uint8List bytes,
    String filename, {
    required bool isDownload,
  }) async {
    if (!isDownload) {
      await Printing.sharePdf(bytes: bytes, filename: filename);
      return;
    }

    // Download logic
    try {
      if (Platform.isAndroid && (await _requestAndroidPermissions()) == false) {
        return; // Permissions denied
      }

      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/KI Software Solutions');
        if (!await directory.exists()) {
          try {
            await directory.create(recursive: true);
          } catch (e) {
            // Fallback for Android 11+ restricted storage scopes
            directory = await getExternalStorageDirectory();
            String newPath = "";
            List<String> paths = directory!.path.split("/");
            for (int x = 1; x < paths.length; x++) {
              String folder = paths[x];
              if (folder != "Android") {
                newPath += "/$folder";
              } else {
                break;
              }
            }
            newPath = "$newPath/KI Software Solutions";
            directory = Directory(newPath);
          }
        }
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
        directory = Directory('${directory.path}/KI Software Solutions');
      }

      if (directory != null) {
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }
        final file = File('${directory.path}/$filename');
        await file.writeAsBytes(bytes);
        Get.snackbar(
          "Success",
          "PDF saved to: ${file.path}",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      } else {
        Get.snackbar(
          "Error",
          "Could not get storage directory.",
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to save PDF: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Request permissions on Android.
  static Future<bool> _requestAndroidPermissions() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
      if (!status.isGranted) {
        // Fallback for Android 11+ (API 30+)
        var manageStatus = await Permission.manageExternalStorage.status;
        if (!manageStatus.isGranted) {
          manageStatus = await Permission.manageExternalStorage.request();
        }
        if (!manageStatus.isGranted && !status.isGranted) {
          Get.snackbar(
            "Permission Denied",
            "Storage permission is required to save the PDF.",
            snackPosition: SnackPosition.BOTTOM,
          );
          return false;
        }
      }
    }
    return true;
  }

  /// Builds a standard PopupMenuButton with 'Share PDF' and 'Download PDF' options.
  static Widget buildPdfActionMenu(
    BuildContext context,
    Function(bool isDownload) onAction, {
    bool isLoading = false,
    Widget? customChild,
  }) {
    if (isLoading) {
      return customChild ??
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            ),
          );
    }

    return PopupMenuButton<String>(
      icon: customChild == null ? const Icon(Icons.picture_as_pdf) : null,
      child: customChild,
      tooltip: 'PDF Options',
      onSelected: (value) {
        onAction(value == 'download');
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'share',
          child: Row(
            children: [
              Icon(Icons.share, color: Colors.black54),
              SizedBox(width: 12),
              Text('Share PDF'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'download',
          child: Row(
            children: [
              Icon(Icons.download, color: Colors.black54),
              SizedBox(width: 12),
              Text('Download PDF'),
            ],
          ),
        ),
      ],
    );
  }
}
