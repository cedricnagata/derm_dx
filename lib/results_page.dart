import 'package:flutter/material.dart';
import 'dart:convert'; // Import for JSON parsing
import 'main.dart';

class ResultsPage extends StatelessWidget {
  final String result;

  ResultsPage({required this.result});

  @override
  Widget build(BuildContext context) {
    // Parse the result as JSON
    Map<String, dynamic> resultMap = json.decode(result);
    String prediction = resultMap['prediction'].toString();

    double confidenceVal = resultMap['confidence'] * 100;
    String confidence = "${confidenceVal.toStringAsFixed(2)}%";

    return Scaffold(
      appBar: AppBar(
        title: Text('Results'),
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
                      'Prediction:',
                      style: TextStyle(fontSize: 24, color: Colors.black87, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      prediction,
                      style: TextStyle(fontSize: 24, color: Colors.black87),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Confidence:',
                      style: TextStyle(fontSize: 24, color: Colors.black87, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      confidence,
                      style: TextStyle(fontSize: 24, color: Colors.black87),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                    (Route<dynamic> route) => false,
                  );
                },
                child: Text('Return Home'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
