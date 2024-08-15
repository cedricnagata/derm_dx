import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'crop_page.dart'; // Import the CropPage
import 'upload_page.dart';

class PhotoLibraryScreen extends StatefulWidget {
  @override
  _PhotoLibraryScreenState createState() => _PhotoLibraryScreenState();
}

class _PhotoLibraryScreenState extends State<PhotoLibraryScreen> {
  List<File> _images = [];
  final ImagePicker _picker = ImagePicker(); // Create an instance of ImagePicker

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    final directory = await getApplicationDocumentsDirectory();
    final imageDirectory = Directory(directory.path);
    final imageList = imageDirectory.listSync().where((item) => item is File && item.path.endsWith('.jpg'));
    setState(() {
      _images = imageList.map((item) => File(item.path)).toList();
    });
  }

  Future<void> _pickImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery); // Pick an image from the gallery
    if (pickedFile != null) {
      final croppedImage = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CropPage(imageFile: File(pickedFile.path)), // Navigate to CropPage for cropping
        ),
      );

      if (croppedImage != null) {
        final directory = await getApplicationDocumentsDirectory();
        final File newImage = File('${directory.path}/${DateTime.now().toIso8601String()}.jpg');
        await newImage.writeAsBytes(await croppedImage.readAsBytes());

        setState(() {
          _images.add(newImage); // Add the new image to the list
        });
      }
    }
  }

  Future<void> _deleteImage(File image) async {
    try {
      await image.delete();
      setState(() {
        _images.remove(image);
      });
    } catch (e) {
      print('Error deleting image: $e');
      // Handle any errors
    }
  }

  void _confirmDeleteImage(File image) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Image'),
          content: Text('Are you sure you want to delete this image?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteImage(image);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Photo Library'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add_photo_alternate), // Add a button for selecting from the gallery
            onPressed: _pickImageFromGallery, // Open the gallery when pressed
          ),
        ],
      ),
      body: _images.isEmpty
          ? Center(child: Text('No images found', style: TextStyle(fontSize: 18.0)))
          : GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: _images.length,
              itemBuilder: (context, index) {
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UploadPage(imageFile: _images[index]),
                          ),
                        );
                      },
                      child: Image.file(_images[index], fit: BoxFit.cover),
                    ),
                    Positioned(
                      right: 4,
                      top: 4,
                      child: GestureDetector(
                        onTap: () {
                          _confirmDeleteImage(_images[index]); // Trigger delete confirmation
                        },
                        child: Icon(
                          Icons.delete,
                          color: Colors.redAccent.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
