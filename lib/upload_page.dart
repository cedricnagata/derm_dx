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
  final _formKey = GlobalKey<FormState>();
  String? _age;
  String? _sex;
  String? _diagnosis;

  void _uploadImage() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      print('Age: $_age, Sex: $_sex');  // Debug output

      try {
        var request = http.MultipartRequest('POST', Uri.parse('http://10.0.2.2:5000/predict'));  // Use 10.0.2.2
        request.files.add(await http.MultipartFile.fromPath('file', widget.imageFile.path));
        request.fields['age'] = _age!;
        request.fields['sex'] = _sex!;
        if (_diagnosis != null && _diagnosis!.isNotEmpty) {
          request.fields['diagnosis'] = _diagnosis!;
        }

        print('Sending request to server...');  // Debug output

        var response = await request.send();
        print('Response status: ${response.statusCode}');  // Debug output

        if (response.statusCode == 200) {
          var responseBody = await response.stream.bytesToString();
          print('Response from server: $responseBody');  // Debug output
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
    } else {
      // If the form is not valid, display a snackbar or other error message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill in all required fields')));
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
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Image.file(widget.imageFile, height: 200, width: 200),
              TextFormField(
                decoration: InputDecoration(labelText: 'Age'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your age';
                  }
                  return null;
                },
                onSaved: (value) => _age = value,
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Sex'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your sex';
                  }
                  return null;
                },
                onSaved: (value) => _sex = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Diagnosis (Optional)'),
                onSaved: (value) {
                  _diagnosis = value;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _uploadImage,
                child: Text('Upload'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
