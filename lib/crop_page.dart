import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

class CropPage extends StatefulWidget {
  final File imageFile;

  const CropPage({Key? key, required this.imageFile}) : super(key: key);

  @override
  _CropPageState createState() => _CropPageState();
}

class _CropPageState extends State<CropPage> {
  Future<void> _startCropping() async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: widget.imageFile.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1), // Fixed square crop aspect ratio
      aspectRatioPresets: [CropAspectRatioPreset.square], // Only allow square cropping
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Colors.deepOrange,
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: true, // Prevent aspect ratio adjustment
        ),
        IOSUiSettings(
          title: 'Crop Image',
          aspectRatioLockEnabled: true, // Prevent aspect ratio adjustment on iOS
        ),
      ],
    );

    if (croppedFile != null) {
      File file = File(croppedFile.path); // Convert CroppedFile to File
      Navigator.pop(context, file); // Return the cropped image as File
    } else {
      Navigator.pop(context); // If cropping is cancelled
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Instructions'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'CROP IMAGE: ',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18.0, color: Colors.black),
            ),
            const Text(
              'For accurate results, center the lesion in the square and avoid zooming in or scaling the image',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18.0, color: Colors.black),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _startCropping, // Start the cropping process
              child: const Text('Start Cropping'),
            ),
          ],
        ),
      ),
    );
  }
}
