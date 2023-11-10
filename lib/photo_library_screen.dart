import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class PhotoLibraryScreen extends StatelessWidget {
  // This function will load images from the app's documents directory
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Photo Library'),
      ),
      body: FutureBuilder<List<File>>(
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
                return Image.file(snapshot.data![index]);
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
    );
  }
}
