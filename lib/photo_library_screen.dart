import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class PhotoLibraryScreen extends StatefulWidget {
  @override
  _PhotoLibraryScreenState createState() => _PhotoLibraryScreenState();
}

class _PhotoLibraryScreenState extends State<PhotoLibraryScreen> {
  File? _selectedImage;

  Future<List<File>> _loadImages() async {
    final directory = await getApplicationDocumentsDirectory();
    final photoDir = Directory('${directory.path}');
    List<File> files = await photoDir
        .list()
        .where((item) => item.path.endsWith('.png') || item.path.endsWith('.jpg'))
        .map((item) => File(item.path))
        .toList();
    return files;
  }

  void _selectImage(File image) {
    setState(() {
      if (_selectedImage != null && _selectedImage!.path == image.path) {
        // If the same image is tapped again, unselect it
        _selectedImage = null;
      } else {
        // Select the new image
        _selectedImage = image;
      }
    });
  }

  void _deleteSelectedImage() {
    if (_selectedImage != null) {
      setState(() {
        _selectedImage!.deleteSync();
        _selectedImage = null;
      });
    }
  }

  Future<void> _pickImagesFromGallery() async {
    try {
      List<Asset> images = await MultiImagePicker.pickImages(
        maxImages: 10,  // Set your desired max number of images
        enableCamera: true,
        selectedAssets: [], // Pass in a list of selected assets (if you want to maintain the selection)
        materialOptions: MaterialOptions(
          actionBarTitle: "Select Photos",
        ),
      );

      // Now, you can save these images to your app's directory
      for (var asset in images) {
        final byteData = await asset.getByteData();
        final file = File('${(await getApplicationDocumentsDirectory()).path}/${asset.name}');
        await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

        // You may also want to add each saved image to a list or database for your photo library
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _requestAndOpenGallery() async {
    var status = await Permission.photos.status;

    if (status.isGranted) {
      // Permission is already granted; open the gallery
      _pickImagesFromGallery();
    } else if (status.isDenied) {
      // Request permission
      if (await Permission.photos.request().isGranted) {
        // Permission is granted; open the gallery
        _pickImagesFromGallery();
      } else {
        // Permission is denied; handle the denial
        print('Access to photos denied');
      }
    } else if (status.isPermanentlyDenied) {
      // The user opted not to allow your app to access the gallery.
      // You can open app settings for them to change the permission
      openAppSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Photo Library'),
        actions: <Widget>[
          if (_selectedImage != null)
            IconButton(
              icon: Icon(Icons.cloud_upload),
              onPressed: () {
                // TODO: Implement the upload functionality
                print('Upload ${_selectedImage!.path}');
              },
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: _deleteSelectedImage,
            ),
        ],
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _requestAndOpenGallery,
            child: Text('Import from Gallery'),
          ),
          Expanded(
            child: FutureBuilder<List<File>>(
              future: _loadImages(),
              builder: (BuildContext context, AsyncSnapshot<List<File>> snapshot) {
                if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // Number of columns
                      crossAxisSpacing: 4.0, // Horizontal space between cards
                      mainAxisSpacing: 4.0,  // Vertical space between cards
                    ),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (BuildContext context, int index) {
                      return InkWell(
                        onTap: () => _selectImage(snapshot.data![index]),
                        child: Opacity(
                          opacity: _isSelected(snapshot.data![index]) ? 0.5 : 1.0,
                          child: Image.file(snapshot.data![index]),
                        ),
                      );
                    },
                  );
                } else if (snapshot.connectionState == ConnectionState.waiting ||
                           !snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                } else {
                  // In case of an error or no images found
                  return Center(child: Text("No images found."));
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  bool _isSelected(File image) {
    return _selectedImage != null && _selectedImage!.path == image.path;
  }
}
