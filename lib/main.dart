import 'package:flutter/material.dart';
import 'camera_screen.dart'; // Ensure this path is correct

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
      home: CameraScreen(), // Set CameraScreen as the home widget
      debugShowCheckedModeBanner: false,
    );
  }
}
