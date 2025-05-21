import 'package:flutter/material.dart';
import 'dart:io';
import 'loading_page.dart'; // Import the LoadingPage

class UploadPage extends StatelessWidget {
  final File imageFile;

  const UploadPage({super.key, required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Image'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.file(imageFile),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoadingPage(imageFile: imageFile), // Navigate to the LoadingPage
                  ),
                );
              },
              child: const Text('Process Image'),
            ),
          ],
        ),
      ),
    );
  }
}
