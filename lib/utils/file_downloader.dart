import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';

class FileDownloader {
  static final AuthService _authService = AuthService();

  /// Downloads a file from [url] with proper auth headers.
  /// Returns null and shows a snackbar on failure.
  static Future<({Uint8List bytes, String filename, String mimeType})?> 
      download(String url) async {
    try {
      final token = await _authService.getToken();

      final response = await http.get(
        Uri.parse(url),
        headers: {
          if (token != null) "Authorization": "Bearer $token",
          "Accept": "application/pdf, image/*, application/octet-stream",
          "User-Agent": "SchoolManagementApp/1.0",
        },
      );

      // ── 1. Check HTTP status ──────────────────────────────────────────────
      if (response.statusCode != 200) {
        _showError("Server returned ${response.statusCode}");
        return null;
      }

      final contentType = response.headers['content-type'] ?? '';
      final bytes = response.bodyBytes;

      // ── 2. Validate it's not an HTML/JSON error page ──────────────────────
      if (contentType.contains('text/html') || 
          contentType.contains('application/json')) {
        debugPrint("❌ Server returned non-file content: $contentType");
        debugPrint("   Body preview: ${response.body.substring(0, 200)}");
        _showError("Server returned an error page instead of the file. "
                   "Check authentication.");
        return null;
      }

      // ── 3. Validate magic bytes (file signature) ──────────────────────────
      // This is the MOST reliable check — independent of server headers
      final detectedMime = _detectMimeFromBytes(bytes);
      if (detectedMime == null) {
        debugPrint("❌ Unknown file signature. First 8 bytes: "
                   "${bytes.take(8).map((b) => b.toRadixString(16)).join(' ')}");
        _showError("Downloaded file is not a valid PDF or image.");
        return null;
      }

      // ── 4. Extract clean filename ─────────────────────────────────────────
      final filename = _extractFilename(url, detectedMime);

      return (bytes: bytes, filename: filename, mimeType: detectedMime);

    } on Exception catch (e) {
      debugPrint("❌ Download exception: $e");
      _showError("Download failed: ${e.toString()}");
      return null;
    }
  }

  // ── MAGIC BYTE DETECTION ──────────────────────────────────────────────────
  // Checks the actual file signature — 100% reliable regardless of headers
  static String? _detectMimeFromBytes(Uint8List bytes) {
    if (bytes.length < 4) return null;

    // PDF: starts with %PDF  →  hex 25 50 44 46
    if (bytes[0] == 0x25 && bytes[1] == 0x50 && 
        bytes[2] == 0x44 && bytes[3] == 0x46) {
      return 'application/pdf';
    }

    // PNG:  hex 89 50 4E 47
    if (bytes[0] == 0x89 && bytes[1] == 0x50 && 
        bytes[2] == 0x4E && bytes[3] == 0x47) {
      return 'image/png';
    }

    // JPEG: hex FF D8 FF
    if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
      return 'image/jpeg';
    }

    // WEBP: RIFF....WEBP
    if (bytes.length >= 12 &&
        bytes[0] == 0x52 && bytes[1] == 0x49 && // RI
        bytes[8] == 0x57 && bytes[9] == 0x45) { // WE
      return 'image/webp';
    }

    return null; // Unknown — reject it
  }

  static String _extractFilename(String url, String mimeType) {
    // Remove query params before extracting name
    final cleanUrl = url.split('?').first;
    final name = cleanUrl.split('/').last;

    // Ensure correct extension matches actual content
    if (mimeType == 'application/pdf' && !name.endsWith('.pdf')) {
      return '$name.pdf';
    }
    return name;
  }

  static void _showError(String message) {
    Get.snackbar(
      "Download Failed",
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade700,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
    );
  }
}