import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

// --- DATA CLASSES (Unchanged) ---
class AnalysisResult {
  final String finalPrediction;
  final double confidence;
  final bool isPaddyLeaf;
  final int statusCode;
  final String reportPath;
  final ModelPrediction? modelPrediction; // Now holds a single prediction

  AnalysisResult({
    required this.finalPrediction,
    required this.confidence,
    required this.isPaddyLeaf,
    required this.statusCode,
    required this.reportPath,
    this.modelPrediction, // This can be null in case of an error
  });

  // toMap function can be updated if needed, but is omitted for brevity
  Map<String, dynamic> toMap() {
    return {
      'final_prediction': finalPrediction,
      'confidence': confidence,
      'is_paddy_leaf': isPaddyLeaf,
      'status_code': statusCode,
      'report_path': reportPath,
    };
  }
}

class ModelPrediction {
  final String predictedClass;
  final double confidence;
  final List<double> allScores;
  final String? error;

  ModelPrediction({
    required this.predictedClass,
    required this.confidence,
    required this.allScores,
    this.error,
  });

  // toMap function can be updated if needed, but is omitted for brevity
}


// --- NEW SINGLE MODEL ANALYZER CLASS ---
class SingleModelAnalyzer {
  final logger = Logger();

  // Class labels remain the same as they are tied to the model's output layer
  final List<String> classLabels = [
    'Bacterial Leaf Blight', 'Brown Spot', 'Healthy Rice Leaf', 'Leaf Blast',
    'Leaf scald', 'Narrow Brown Leaf Spot', 'Neck_Blast', 'Rice Hispa', 'Sheath Blight',
  ];

  final String healthyClass = "Healthy Rice Leaf";

  /// Analyzes an image using a single specified TensorFlow Lite model.
  ///
  /// - [imagePath]: The file path of the image to analyze.
  /// - [modelAssetPath]: The asset path of the .tflite model file.
  Future<AnalysisResult> analyze(String imagePath, String modelAssetPath) async {
    logger.i('🚀 Starting single-model analysis for image: $imagePath');
    logger.i('📦 Using model: $modelAssetPath');

    try {
      // 1. Run inference using the specified model
      final outputScores = await _runModel(imagePath, modelAssetPath);
      final topPredictionIndex = _argmax(outputScores);
      final confidence = outputScores[topPredictionIndex] * 100;
      final predictedClass = classLabels[topPredictionIndex];

      final modelPrediction = ModelPrediction(
        predictedClass: predictedClass,
        confidence: confidence,
        allScores: outputScores,
      );

      logger.d(
        '✅ Model predicted "$predictedClass" with ${confidence.toStringAsFixed(2)}% confidence.',
      );

      String finalPrediction;
      double finalConfidence;
      bool isPaddyLeaf;
      int statusCode;

      // 2. Apply the confidence threshold logic
      if (confidence > 50.0) {
        logger.i('👍 Confidence is above 50%. Accepting prediction.');
        finalPrediction = predictedClass;
        finalConfidence = confidence;
        isPaddyLeaf = true; // Assumed to be a paddy leaf if confidence is high
        statusCode = (predictedClass == healthyClass) ? 0 : 1; // 0 for Healthy, 1 for Disease
      } else {
        logger.w('👎 Confidence is below 50%. Rejecting prediction.');
        finalPrediction = "Unknown / Low Confidence";
        finalConfidence = confidence; // Report the low confidence
        isPaddyLeaf = false;
        statusCode = 2; // 2 for Unknown/Uncertain
      }

      // 3. Save the report and return the result
      final reportPath = await _saveReport(imagePath, modelPrediction, {
        "final_prediction": finalPrediction,
        "confidence": finalConfidence,
        "status_code": statusCode,
      });
      logger.i('📝 Analysis report saved to: $reportPath');

      return AnalysisResult(
        finalPrediction: finalPrediction,
        confidence: finalConfidence,
        isPaddyLeaf: isPaddyLeaf,
        statusCode: statusCode,
        reportPath: reportPath,
        modelPrediction: modelPrediction,
      );

    } catch (e) {
      logger.e('❌ Critical failure during analysis:', error: e);
      // Return an error result
      return AnalysisResult(
        finalPrediction: "Analysis Error",
        confidence: 0.0,
        isPaddyLeaf: false,
        statusCode: -1, // -1 for Critical Error
        reportPath: '',
        modelPrediction: ModelPrediction(
            predictedClass: "Error",
            confidence: 0.0,
            allScores: [],
            error: e.toString()),
      );
    } finally {
      logger.i('🏁 Single-model analysis finished.');
    }
  }

  // --- HELPER METHODS (Unchanged from original code) ---

  /// Runs inference on a given image file with a TFLite model.
  Future<List<double>> _runModel(String imagePath, String modelPath) async {
    Interpreter? interpreter;
    try {
      interpreter = await Interpreter.fromAsset(modelPath);
      final inputShape = interpreter.getInputTensor(0).shape;
      final imageBytes = await File(imagePath).readAsBytes();
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        throw Exception("Failed to decode image: $imagePath");
      }
      final resized = img.copyResize(image, width: inputShape[1], height: inputShape[2]);
      final input = List.generate(1, (_) =>
        List.generate(inputShape[1], (y) =>
          List.generate(inputShape[2], (x) {
            final pixel = resized.getPixel(x, y);
            // Normalization can be model-specific. This is a common 0-1 scaling.
            return [pixel.r / 255.0, pixel.g / 255.0, pixel.b / 255.0];
          }),
        ),
      );
      final outputShape = interpreter.getOutputTensor(0).shape;
      final output = List.filled(outputShape.reduce((a, b) => a * b), 0.0)
          .reshape([1, outputShape[1]]);
      interpreter.run(input, output);
      return List<double>.from(output[0]);
    } finally {
      interpreter?.close();
    }
  }

  /// Finds the index of the maximum value in a list of doubles.
  int _argmax(List<double> data) {
    if (data.isEmpty) return -1;
    var maxIdx = 0;
    var maxVal = data[0];
    for (int i = 1; i < data.length; i++) {
      if (data[i] > maxVal) {
        maxIdx = i;
        maxVal = data[i];
      }
    }
    return maxIdx;
  }

  /// Saves the analysis result to a text file.
  Future<String> _saveReport(
    String imgPath,
    ModelPrediction pred,
    Map<String, dynamic> result,
  ) async {
    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final reportPath = "${dir.path}/paddy_analysis_$timestamp.txt";
    final buffer = StringBuffer();
    buffer.writeln("SINGLE-MODEL PADDY LEAF ANALYSIS");
    buffer.writeln("=" * 40);
    buffer.writeln("Image: $imgPath");
    buffer.writeln("Analysis Time: ${DateTime.now()}");
    buffer.writeln("");
    buffer.writeln("--- FINAL RESULT ---");
    buffer.writeln("Prediction: ${result["final_prediction"]}");
    buffer.writeln("Confidence: ${result["confidence"].toStringAsFixed(2)}%");
    buffer.writeln("Status Code: ${result["status_code"]}");
    buffer.writeln("");
    buffer.writeln("--- MODEL DETAILS ---");
    buffer.writeln(
        "Raw Prediction: ${pred.predictedClass} (${pred.confidence.toStringAsFixed(2)}%)");
    
    await File(reportPath).writeAsString(buffer.toString());
    return reportPath;
  }
}