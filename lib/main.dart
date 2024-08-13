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
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: TextTheme(
          headline1: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold, color: Colors.blueAccent),
          headline6: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.blueAccent),
          bodyText2: TextStyle(fontSize: 18.0),
        ),
        buttonTheme: ButtonThemeData(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
          buttonColor: Colors.blueAccent,
        ),
      ),
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatelessWidget {
  Future<void> _pickImageFromGallery() async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final directory = await getApplicationDocumentsDirectory();
        final String fileName = basename(pickedFile.path);
        final String filePath = '${directory.path}/$fileName';
        final file = File(pickedFile.path);
        await file.copy(filePath);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DERMDX Home'),
        centerTitle: true,
      ),
      body: Center(  // Centering the content
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Welcome to DERMDX',
                style: Theme.of(context).textTheme.headline1,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CameraScreen()),
                  );
                },
                icon: Icon(Icons.camera_alt),
                label: Text('Capture Image'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                  textStyle: Theme.of(context).textTheme.headline6,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PhotoLibraryScreen()),
                  );
                },
                icon: Icon(Icons.photo_library),
                label: Text('Select from Library'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                  textStyle: Theme.of(context).textTheme.headline6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
