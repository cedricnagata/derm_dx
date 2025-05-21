import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'photo_library_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DERMDX',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold, color: Colors.blueAccent),
          headlineSmall: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.blueAccent),
          bodyMedium: TextStyle(fontSize: 18.0),
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
  const HomePage({super.key});

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
        title: const Text('DERMDX Home'),
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
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Text(
                'Accurate skin lesion detection at the touch of a button.',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.normal, color: Colors.blueGrey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Text(
                'Trained on 44,033 images of real skin lesions.',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.normal, color: Colors.blueGrey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PhotoLibraryScreen()),
                  );
                },
                icon: const Icon(Icons.photo_library),
                label: const Text('Select Image from Library'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                  textStyle: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
