import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'results_page.dart';

class UploadPage extends StatefulWidget {
  final File imageFile;

  UploadPage({required this.imageFile});

  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  void _uploadImage() async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('http://10.0.2.2:5000/predict'));  // Use 10.0.2.2 for local server

      // Add the image file to the request
      request.files.add(await http.MultipartFile.fromPath('file', widget.imageFile.path));

      print('Sending request to server...');  // Debug output

      // Send the request
      var response = await request.send();
      print('Response status: ${response.statusCode}');  // Debug output

      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        print('Response from server: $responseBody');  // Debug output

        // Navigate to the results page with the response
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultsPage(result: responseBody),
          ),
        );
      } else {
        var responseBody = await response.stream.bytesToString();
        print('Upload failed with status: ${response.statusCode}, body: $responseBody');  // Debug output
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed')));
      }
    } catch (e) {
      print('Error during upload: $e');  // Debug output
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('An error occurred')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Image'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.file(widget.imageFile, height: 200, width: 200),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadImage,
              child: Text('Upload'),
            ),
          ],
        ),
      ),
    );
  }
}
