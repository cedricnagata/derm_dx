import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'tflite_service.dart';
import 'results_page.dart';

class LoadingPage extends StatefulWidget {
  final File imageFile;

  LoadingPage({required this.imageFile});

  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  double _progress = 0.0;
  final TFLiteService _tfliteService = TFLiteService();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Start the prediction process after the UI is rendered
      _startPrediction();
    });
  }

  Future<void> _startPrediction() async {
    // Simulate a loading process
    Timer.periodic(Duration(milliseconds: 100), (timer) {
      setState(() {
        _progress += 0.1;
        if (_progress >= 1.0) {
          _progress = 1.0;
          timer.cancel();
        }
      });
    });

    try {
      Uint8List imageBytes = await widget.imageFile.readAsBytes();

      // Run the predictions while the progress bar is updating
      var diagnosisResult = await _delayedPrediction(() {
        return Future.value(_tfliteService.predictDiagnosis(imageBytes));
      });
      var benignMalignantResult = await _delayedPrediction(() {
        return Future.value(_tfliteService.predictBenignMalignant(imageBytes));
      });

      String diagnosis = _tfliteService.diagnosisLabels[diagnosisResult['diagnosis_pred']];
      dynamic diagnosisConfidence = diagnosisResult['diagnosis_confidence'];
      String benignMalignant = _tfliteService.benignMalignantLabels[benignMalignantResult['benign_malignant_pred']];
      dynamic benignMalignantConfidence = benignMalignantResult['benign_malignant_confidence'];

      Map<String, dynamic> resultMap = {
        'diagnosis': diagnosis,
        'diagnosis_confidence': diagnosisConfidence,
        'benign_malignant': benignMalignant,
        'benign_malignant_confidence': benignMalignantConfidence,
      };

      // Ensure the progress bar finishes before transitioning
      await Future.delayed(Duration(milliseconds: 200), () {
        if (_progress < 1.0) {
          setState(() {
            _progress = 1.0;
          });
        }
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultsPage(result: json.encode(resultMap)),
        ),
      );
    } catch (e) {
      print('Error during prediction: $e');
      // Handle any errors
    }
  }

  Future<Map<String, dynamic>> _delayedPrediction(Future<Map<String, dynamic>> Function() predictionTask) async {
    return await Future.delayed(Duration(milliseconds: 500), predictionTask);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove the back button
        title: Text('Processing...'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Analyzing Image...',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Container(
              width: 200,
              height: 10,
              child: LinearProgressIndicator(
                value: _progress,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
