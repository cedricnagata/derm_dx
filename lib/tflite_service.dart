import 'dart:typed_data';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class TFLiteService {
  Interpreter? _diagnosisInterpreter;
  Interpreter? _benignMalignantInterpreter;

  final List<String> diagnosisLabels = ['nevus', 'melanoma', 'other'];
  final List<String> benignMalignantLabels = ['benign', 'malignant'];

  TFLiteService() {
    _loadModels();
  }

  Future<void> _loadModels() async {
    _diagnosisInterpreter = await Interpreter.fromAsset('assets/models/diagnosis_model.tflite');
    _benignMalignantInterpreter = await Interpreter.fromAsset('assets/models/benign_malignant_model.tflite');
  }

  Float32List _preprocessImage(Uint8List imageBytes) {
    img.Image image = img.decodeImage(imageBytes)!;

    // Resize the image to 224x224 pixels
    img.Image resizedImage = img.copyResize(image, width: 224, height: 224);

    // Create a Float32List with the correct shape: [224, 224, 3]
    Float32List inputBytes = Float32List(224 * 224 * 3);  // Ensure this matches [224, 224, 3]
    int index = 0;

    // Normalize and fill the inputBytes
    for (int y = 0; y < 224; y++) {
        for (int x = 0; x < 224; x++) {
            int pixel = resizedImage.getPixel(x, y);
            inputBytes[index++] = img.getRed(pixel) / 255.0;    // Normalize to [0, 1]
            inputBytes[index++] = img.getGreen(pixel) / 255.0;  // Normalize to [0, 1]
            inputBytes[index++] = img.getBlue(pixel) / 255.0;   // Normalize to [0, 1]
        }
    }

    return inputBytes;
  }

  Map<String, dynamic> predictDiagnosis(Uint8List imageBytes) {
    Float32List inputBytes = _preprocessImage(imageBytes);
    List<dynamic> input = inputBytes.reshape([1, 224, 224, 3]);

    var output = List.filled(3, 0.0).reshape([1, 3]);

    _diagnosisInterpreter!.allocateTensors();  // Allocate tensors
    _diagnosisInterpreter!.run(input, output);  // Run inference

    // Ensure the output is treated as List<double>
    List<double> predictionList = List<double>.from(output[0]);
    
    // Find the maximum value in the output list
    double diagnosisConfidence = predictionList.reduce((double a, double b) => a > b ? a : b);
    int diagnosisPred = predictionList.indexOf(diagnosisConfidence);

    return {
      'diagnosis_pred': diagnosisPred,
      'diagnosis_confidence': diagnosisConfidence,
    };
  }

  Map<String, dynamic> predictBenignMalignant(Uint8List imageBytes) {
    Float32List inputBytes = _preprocessImage(imageBytes);
    List<dynamic> input = inputBytes.reshape([1, 224, 224, 3]);

    var output = List.filled(1, 0.0).reshape([1, 1]);

    _benignMalignantInterpreter!.allocateTensors();  // Allocate tensors
    _benignMalignantInterpreter!.run(input, output);  // Run inference

    double benignMalignantConfidence = output[0][0] as double;
    int benignMalignantPred = benignMalignantConfidence > 0.5 ? 1 : 0;
    benignMalignantConfidence = benignMalignantPred == 1 ? benignMalignantConfidence : 1 - benignMalignantConfidence;

    return {
      'benign_malignant_pred': benignMalignantPred,
      'benign_malignant_confidence': benignMalignantConfidence,
    };
  }

  void close() {
    _diagnosisInterpreter?.close();
    _benignMalignantInterpreter?.close();
  }
}
