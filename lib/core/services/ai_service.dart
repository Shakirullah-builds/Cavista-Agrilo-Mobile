import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:impulse_mobile/core/constants/asset_path.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class AiService {
  AiService._();

  static Interpreter? _interpreter;
  static List<String>? _labels;

  static Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset(AssetPath.tfliteModel);
      final labelData = await rootBundle.loadString(AssetPath.modelLabel);

      // split the text files into a list of labels

      _labels = labelData
          .split('\n')
          .where((label) => label.isNotEmpty)
          .toList();
      debugPrint('AI Model & Labels loaded Successfully!');
    } catch (e) {
      debugPrint('Failed to load AI Model: $e');
    }
  }

  // RUN THE SCAN
  static Future<String> analyzeImage(String imagePath) async {
    if (_interpreter == null || _labels == null) {
      return 'Error: Brain not loaded.';
    }

    try {
      // Read the image from the camera
      File file = File(imagePath);
      img.Image? rawImage = img.decodeImage(file.readAsBytesSync());
      if (rawImage == null) return 'Error reading image.';

      // Resize the image to 224x224 (The size Teachable Machine expects)
      img.Image resizedImage = img.copyResize(
        rawImage,
        width: 224,
        height: 224,
      );

      // Convert the image pixels into a 3D mathematical array for the AI
      // TFLite Floating Point models expect values normalized between -1.0 and 1.0

      var input = List.generate(
        1,
        (i) => List.generate(
          224,
          (j) => List.generate(224, (k) => List.filled(3, 0.0)),
        ),
      );

      for (int y = 0; y < 224; y++) {
        for (int x = 0; x < 224; x++) {
          final pixel = resizedImage.getPixel(x, y);
          input[0][y][x][0] = (pixel.r / 127.5) - 1.0; // Red
          input[0][y][x][1] = (pixel.g / 127.5) - 1.0; // Green
          input[0][y][x][2] = (pixel.b / 127.5) - 1.0; // Blue
        }
      }

      // Prepare the output array based on how many labels available
      var output = List.generate(1, (i) => List.filled(_labels!.length, 0.0));

      // RUN INFERENCE!
      _interpreter!.run(input, output);

      // Figure out which label had the highest percentage score
      List<double> probabilities = output[0];
      int highestIndex = 0;
      double highestScore = probabilities[0];

      for (int i = 1; i < probabilities.length; i++) {
        if (probabilities[i] > highestScore) {
          highestScore = probabilities[i];
          highestIndex = i;
        }
      }

      // Clean up the label name
      String resultLabel = _labels![highestIndex].replaceAll(
        RegExp(r'^[0-9]+\s'),
        '',
      );

      return "$resultLabel (${(highestScore * 100).toStringAsFixed(1)}%)";
    } catch (e) {
      debugPrint('Inference error: $e');
      return 'Analysis Failed';
    }
  }
}
