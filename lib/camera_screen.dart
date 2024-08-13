import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'dart:ui' as ui;
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
      ResolutionPreset.max,
    );

    _initializeControllerFuture = _controller!.initialize();

    setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<File> _cropToSquare(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final originalImage = await decodeImageFromList(bytes);

    int shortestSide = originalImage.width < originalImage.height
        ? originalImage.width
        : originalImage.height;

    final left = (originalImage.width - shortestSide) / 2;
    final top = (originalImage.height - shortestSide) / 2;

    final croppedImage = await _cropImage(bytes, left.toInt(), top.toInt(), shortestSide, shortestSide);

    final directory = await getApplicationDocumentsDirectory();
    final String croppedFilePath = '${directory.path}/${basename(imageFile.path)}_cropped.jpg';

    final croppedFile = File(croppedFilePath);
    await croppedFile.writeAsBytes(croppedImage);

    return croppedFile;
  }

  Future<Uint8List> _cropImage(Uint8List imageData, int left, int top, int width, int height) async {
    final codec = await ui.instantiateImageCodec(imageData);
    final frame = await codec.getNextFrame();
    final image = frame.image;

    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    final paint = Paint();

    canvas.drawImageRect(
      image,
      Rect.fromLTWH(left.toDouble(), top.toDouble(), width.toDouble(), height.toDouble()),
      Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
      paint,
    );

    final croppedImage = await pictureRecorder
        .endRecording()
        .toImage(width, height);

    final byteData = await croppedImage.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
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
                Positioned.fill(
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          color: Colors.black.withOpacity(0.6), // Darkened top area
                        ),
                      ),
                      AspectRatio(
                        aspectRatio: 1,
                        child: Container(), // Square box in the middle (clear area)
                      ),
                      Expanded(
                        child: Container(
                          color: Colors.black.withOpacity(0.6), // Darkened bottom area
                        ),
                      ),
                    ],
                  ),
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

                          // Crop the image to a square
                          final croppedImage = await _cropToSquare(File(image.path));

                          // Navigate to the PhotoLibraryScreen with the cropped image
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
