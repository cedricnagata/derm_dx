import 'dart:io';

import 'package:flutter/material.dart';
import 'camera_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'photo_library_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DERMDX',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(), // Use HomePage as the main screen
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatelessWidget {
  Future<void> _pickImageFromGallery() async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        // Get the directory to store images.
        final directory = await getApplicationDocumentsDirectory();
  
        // Create a new file path in the app's documents directory.
        final String fileName = basename(pickedFile.path);
        final String filePath = '${directory.path}/$fileName';
  
        // Copy the file to the new path.
        final file = File(pickedFile.path);
        await file.copy(filePath);
  
        // TODO: You may want to add the image information to a local database or a list to track all images.
  
        // You can now display the image or add it to your photo library screen.
      }
    } catch (e) {
      // If an error occurs, log the error to the console.
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DERMDX Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CameraScreen()),
                );
              },
              child: Text('Open Camera'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PhotoLibraryScreen()),
                );
              },
              child: Text('View Photo Library'),
            ),
          ],
        ),
      ),
    );
  }
}
