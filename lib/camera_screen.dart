import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:io';

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
    // Obtain a list of the available cameras on the device.
    final cameras = await availableCameras();

    // Get a specific camera from the list of available cameras.
    final firstCamera = cameras.first;

    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      firstCamera,
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller!.initialize();

    // Ensure the camera is initialized before displaying the preview.
    // This is done using a FutureBuilder.
    setState(() {});
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // A FutureBuilder is used to display a loading spinner
    // until the camera is initialized.
    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // If the Future is complete, display the preview.
          return Scaffold(
            body: CameraPreview(_controller!), // Display the camera preview
            floatingActionButton: FloatingActionButton(
              child: Icon(Icons.camera),
              // Provide an onPressed callback.
              onPressed: () async {
                try {
                  // Ensure that the camera is initialized.
                  await _initializeControllerFuture;

                  // Attempt to take a picture and get the file.
                  final imageFile = await _controller!.takePicture();

                  // Get the directory to store images.
                  final directory = await getApplicationDocumentsDirectory();

                  // Create a new file path in the app's documents directory.
                  final String fileName = basename(imageFile.path);
                  final String filePath = '${directory.path}/$fileName';

                  // Copy the file to the new path.
                  await imageFile.saveTo(filePath);

                  // TODO: You may want to add the image information to a local database or a list to track all images.

                  // If the picture was taken, display it on a new screen.
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DisplayPictureScreen(imagePath: filePath),
                    ),
                  );
                } catch (e) {
                  // If an error occurs, log the error to the console.
                  print(e);
                }
              },
            ),
          );
        } else {
          // Otherwise, display a loading indicator.
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Display the Picture')),
      body: Image.file(File(imagePath)),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement the functionality to send the image to the server
          print('Send image to the server for analysis');
        },
        tooltip: 'Send for Analysis',
        child: Icon(Icons.send),
      ),
    );
  }
}

class SavedImage {
  final String path;
  final DateTime dateTaken;

  SavedImage({required this.path, required this.dateTaken});
}
