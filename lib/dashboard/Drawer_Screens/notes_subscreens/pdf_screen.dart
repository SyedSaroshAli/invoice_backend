import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'dart:io';

class PDFScreen extends StatelessWidget {
  final String url;

  const PDFScreen({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: SfPdfViewer.network(url),
    );
  }
}

// 📱 Local PDF
class PDFScreenLocal extends StatelessWidget {
  final String path;

  const PDFScreenLocal({super.key, required this.path});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("PDF Viewer")),
      body: SfPdfViewer.file(File(path)),
    );
  }
}