import 'package:flutter/material.dart';
import 'dart:convert'; // Import for JSON parsing

class ResultsPage extends StatelessWidget {
  final String result;

  ResultsPage({required this.result});

  @override
  Widget build(BuildContext context) {
    // Parse the result as JSON
    Map<String, dynamic> resultMap = json.decode(result);
    String diagnosis = resultMap['diagnosis'].toString();
    double diagnosisConfidence = resultMap['diagnosis_confidence'] * 100;
    String benignMalignant = resultMap['benign_malignant'].toString();
    double benignMalignantConfidence = resultMap['benign_malignant_confidence'] * 100;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove the back button
        title: Text('Results'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Diagnosis Result',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Diagnosis:',
                      style: TextStyle(fontSize: 24, color: Colors.black87, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      '$diagnosis',
                      style: TextStyle(fontSize: 20, color: diagnosis == 'nevus' ? Colors.green.shade800 : (diagnosis == 'melanoma' ? Colors.red.shade800 : Colors.black87)),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Confidence: ${diagnosisConfidence.toStringAsFixed(2)}%',
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Benign/Malignant:',
                      style: TextStyle(fontSize: 24, color: Colors.black87, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      '$benignMalignant',
                      style: TextStyle(fontSize: 20, color: benignMalignant == 'benign' ? Colors.green.shade800 : Colors.red.shade800),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Confidence: ${benignMalignantConfidence.toStringAsFixed(2)}%',
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst); // Return to HomePage
                },
                child: Text('Return Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
