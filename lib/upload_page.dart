import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'tflite_service.dart';
import 'results_page.dart';

class UploadPage extends StatefulWidget {
  final File imageFile;

  UploadPage({required this.imageFile});

  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final TFLiteService _tfliteService = TFLiteService();

  @override
  void dispose() {
    _tfliteService.close();
    super.dispose();
  }

  Future<void> _predictAndNavigate() async {
    Uint8List imageBytes = await widget.imageFile.readAsBytes();

    var diagnosisResult = _tfliteService.predictDiagnosis(imageBytes);
    var benignMalignantResult = _tfliteService.predictBenignMalignant(imageBytes);

    // Map predictions to labels using the labels defined in TFLiteService
    String diagnosis = _tfliteService.diagnosisLabels[diagnosisResult['diagnosis_pred']];
    dynamic diagnosisConfidence = diagnosisResult['diagnosis_confidence'];
    String benignMalignant = _tfliteService.benignMalignantLabels[benignMalignantResult['benign_malignant_pred']];
    dynamic benignMalignantConfidence = benignMalignantResult['benign_malignant_confidence'];

    // Create a result map similar to the Flask server response
    Map<String, dynamic> resultMap = {
      'diagnosis': diagnosis,
      'diagnosis_confidence': diagnosisConfidence,
      'benign_malignant': benignMalignant,
      'benign_malignant_confidence': benignMalignantConfidence,
    };

    // Convert the map to a JSON string
    String resultJson = json.encode(resultMap);

    // Navigate to the results page with the predictions
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultsPage(result: resultJson),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Image'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.file(widget.imageFile, height: 200, width: 200),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _predictAndNavigate,
              child: Text('Predict and See Results'),
            ),
          ],
        ),
      ),
    );
  }
}
