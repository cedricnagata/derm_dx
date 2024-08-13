import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'photo_library_screen.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _controller = CameraController(
      firstCamera,
      ResolutionPreset.medium,
    );

    _initializeControllerFuture = _controller!.initialize();

    setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,  // Set the background to black
      appBar: AppBar(
        title: Text('Capture Image'),
        centerTitle: true,
        backgroundColor: Colors.black,  // Set the AppBar background to black
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: <Widget>[
                Center(
                  child: CameraPreview(_controller!),  // Center the camera preview
                ),
                Positioned(
                  bottom: 30,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: FloatingActionButton(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.camera, color: Colors.black, size: 30),
                      onPressed: () async {
                        try {
                          await _initializeControllerFuture;
                          final image = await _controller!.takePicture();

                          final directory = await getApplicationDocumentsDirectory();
                          final String fileName = basename(image.path);
                          final String filePath = '${directory.path}/$fileName';
                          await image.saveTo(filePath);

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PhotoLibraryScreen(),
                            ),
                          );
                        } catch (e) {
                          print(e);
                        }
                      },
                    ),
                  ),
                ),
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
