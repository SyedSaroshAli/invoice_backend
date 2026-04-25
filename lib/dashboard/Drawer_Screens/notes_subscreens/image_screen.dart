import 'package:flutter/material.dart';
import 'dart:io';

class ImageScreen extends StatelessWidget {
  final String url;

  const ImageScreen({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Image")),
      body: Center(
        child: Image.network(url),
      ),
    );
  }
}

// 📱 Local Image
class ImageScreenLocal extends StatelessWidget {
  final String path;

  const ImageScreenLocal({super.key, required this.path});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Image")),
      body: Center(
        child: Image.file(File(path)),
      ),
    );
  }
}