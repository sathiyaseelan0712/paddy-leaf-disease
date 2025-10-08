import 'dart:io';
import 'dart:math';
import 'package:image/image.dart' as img;
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

// --- DATA CLASSES (No changes here) ---
class AnalysisResult {
  final String finalPrediction;
  final double confidence;
  final bool isPaddyLeaf;
  final int statusCode;
  final String reportPath;
  final Map<String, ModelPrediction> modelPredictions;

  AnalysisResult({
    required this.finalPrediction,
    required this.confidence,
    required this.isPaddyLeaf,
    required this.statusCode,
    required this.reportPath,
    required this.modelPredictions,
  });

  Map<String, dynamic> toMap() {
    return {
      'final_prediction': finalPrediction,
      'confidence': confidence,
      'is_paddy_leaf': isPaddyLeaf,
      'status_code': statusCode,
      'report_path': reportPath,
      'model_predictions': modelPredictions.map(
        (key, value) => MapEntry(key, value.toMap()),
      ),
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
  
  Map<String, dynamic> toMap() {
    return {
      'predicted_class': predictedClass,
      'confidence': confidence,
      'all_scores': allScores,
      'error': error,
    };
  }
}


// --- ANALYZER CLASS ---
class MultiModelAnalyzer {
  final logger = Logger();

  final Map<String, String> modelPaths = {
    "resnet50": 'assets/models/resnet50_model.tflite',
    "vgg16": 'assets/models/vgg16_model.tflite',
    "inceptionv3": 'assets/models/inceptionv3_model.tflite',
    "xception": 'assets/models/xception_model.tflite',
    "efficientnetb3": 'assets/models/efficientnetb3_model.tflite',
  };

  final List<String> classLabels = [
    'Bacterial Leaf Blight', 'Brown Spot', 'Healthy Rice Leaf', 'Leaf Blast',
    'Leaf scald', 'Narrow Brown Leaf Spot', 'Neck_Blast', 'Rice Hispa', 'Sheath Blight',
  ];

  final List<String> diseaseClasses = [
    'Bacterial Leaf Blight', 'Brown Spot', 'Leaf Blast', 'Leaf scald',
    'Narrow Brown Leaf Spot', 'Neck_Blast', 'Rice Hispa', 'Sheath Blight',
  ];
  final String healthyClass = "Healthy Rice Leaf";

  // --- THIS IS THE ONLY METHOD THAT HAS CHANGED ---
  Map<String, dynamic> _aggregate(Map<String, ModelPrediction> preds) {
    final successfulPredictions = preds.values.where((p) => p.error == null).toList();
    if (successfulPredictions.isEmpty) {
       return {
        "is_paddy_leaf": false, "final_prediction": "Unknown",
        "confidence": 0.0, "status_code": 2,
      };
    }

    // --- Rule #1: Check for a "Corroborated Expert" ---
    // First, count how many models have high confidence in total.
    final highConfidenceCount = successfulPredictions.where((p) => p.confidence >= 90).length;

    // Sort to find the single best prediction.
    successfulPredictions.sort((a, b) => b.confidence.compareTo(a.confidence));
    final bestPrediction = successfulPredictions.first;

    // The rule now requires at least TWO models to be highly confident.
    if (highConfidenceCount >= 2 && bestPrediction.confidence >= 90 && diseaseClasses.contains(bestPrediction.predictedClass)) {
      logger.i('🏆 Corroborated expert model rule triggered. Prediction: "${bestPrediction.predictedClass}"');
      return {
        "is_paddy_leaf": true,
        "final_prediction": bestPrediction.predictedClass,
        "confidence": bestPrediction.confidence,
        "status_code": 1, // Disease status code
      };
    }

    // --- Rule #2: If no expert, check for a high-confidence GROUP agreement ---
    logger.i('No corroborated expert winner. Checking for high-confidence group agreement.');
    final highConfidencePredictions = successfulPredictions.where((p) =>
        p.confidence >= 90 &&
        diseaseClasses.contains(p.predictedClass));

    if (highConfidencePredictions.isNotEmpty) {
      final highConfidenceCounts = <String, int>{};
      for (final pred in highConfidencePredictions) {
        highConfidenceCounts[pred.predictedClass] = (highConfidenceCounts[pred.predictedClass] ?? 0) + 1;
      }
      
      final confidentWinners = highConfidenceCounts.entries.where((e) => e.value >= 2).toList();
      
      if (confidentWinners.isNotEmpty) {
        confidentWinners.sort((a, b) => b.value.compareTo(a.value));
        final winningLabel = confidentWinners.first.key;
        final bestConfidence = highConfidencePredictions
            .where((p) => p.predictedClass == winningLabel)
            .map((p) => p.confidence)
            .fold(0.0, max);

        logger.i('🏆 High-confidence group rule triggered. Prediction: "$winningLabel"');
        return {
          "is_paddy_leaf": true,
          "final_prediction": winningLabel,
          "confidence": bestConfidence,
          "status_code": 1, // Disease status code
        };
      }
    }

    // --- Rule #3: Fallback to majority vote, WITH A NEW CONFIDENCE CHECK ---
    logger.i('No high-confidence group winner. Falling back to confident majority vote.');
    final allCounts = <String, int>{};
    for (final entry in successfulPredictions) {
      allCounts[entry.predictedClass] = (allCounts[entry.predictedClass] ?? 0) + 1;
    }

    final sorted = allCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.first;

    // Check for a majority of 3 or more votes
    if (top.value >= 3) {
      // Check if at least two of these majority predictions are highly confident
      final majorityGroup = successfulPredictions.where((p) => p.predictedClass == top.key);
      final highConfidenceInMajority = majorityGroup.where((p) => p.confidence >= 90).length;

      if (highConfidenceInMajority >= 2) {
        final bestConf = majorityGroup.map((p) => p.confidence).fold(0.0, max);
        final label = top.key;
        final code = label == healthyClass ? 0 : (diseaseClasses.contains(label) ? 1 : 2);
        
        logger.i('🏆 Confident majority rule triggered. Prediction: "$label"');
        return {
          "is_paddy_leaf": true,
          "final_prediction": label,
          "confidence": bestConf,
          "status_code": code,
        };
      } else {
        logger.w('Majority vote found for "${top.key}", but it was rejected due to low confidence (found ${highConfidenceInMajority} of 2 required >90% predictions).');
      }
    }

    // --- Final Fallback ---
    return {
      "is_paddy_leaf": false,
      "final_prediction": "Not a paddy leaf",
      "confidence": 0.0,
      "status_code": 2,
    };
  }


  // --- NO CHANGES TO ANY METHODS BELOW THIS LINE ---

  Future<AnalysisResult> analyze(String imagePath) async {
    logger.i('🚀 Starting multi-model analysis for image: $imagePath');
    final predictions = <String, ModelPrediction>{};
    final analysisFutures = modelPaths.entries.map((entry) async {
      try {
        final output = await _runModel(imagePath, entry.value);
        final predClassIndex = _argmax(output);
        final confidence = output[predClassIndex] * 100;
        final predClassName = classLabels[predClassIndex];
        logger.d(
          '✅ ${entry.key}: Predicted "$predClassName" with ${confidence.toStringAsFixed(2)}% confidence.',
        );
        return MapEntry(entry.key, ModelPrediction(
          predictedClass: predClassName,
          confidence: confidence,
          allScores: output,
        ));
      } catch (e) {
        logger.e('❌ Failed to run model ${entry.key}:', error: e);
        return MapEntry(entry.key, ModelPrediction(
          predictedClass: "Error",
          confidence: 0.0,
          allScores: [],
          error: e.toString(),
        ));
      }
    });
    final results = await Future.wait(analysisFutures);
    predictions.addEntries(results);
    final aggregatedResult = _aggregate(predictions);
    logger.i('🗳️ Aggregation result: "${aggregatedResult["final_prediction"]}" with status code ${aggregatedResult["status_code"]}.');
    final reportPath = await _saveReport(imagePath, predictions, aggregatedResult);
    logger.i('📝 Analysis report saved to: $reportPath');
    logger.i('🏁 Multi-model analysis finished.');
    return AnalysisResult(
      finalPrediction: aggregatedResult["final_prediction"]!,
      confidence: aggregatedResult["confidence"]!,
      isPaddyLeaf: aggregatedResult["is_paddy_leaf"]!,
      statusCode: aggregatedResult["status_code"]!,
      reportPath: reportPath,
      modelPredictions: predictions,
    );
  }

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
            final r = pixel.r / 255.0;
            final g = pixel.g / 255.0;
            final b = pixel.b / 255.0;
            return [r, g, b];
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

  Future<String> _saveReport(
    String imgPath,
    Map<String, ModelPrediction> preds,
    Map<String, dynamic> result,
  ) async {
    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final reportPath = "${dir.path}/paddy_analysis_$timestamp.txt";
    final buffer = StringBuffer();
    buffer.writeln("MULTI-MODEL PADDY LEAF ANALYSIS");
    buffer.writeln("=" * 40);
    buffer.writeln("Image: $imgPath");
    buffer.writeln("Analysis Time: ${DateTime.now()}");
    buffer.writeln("Final Prediction: ${result["final_prediction"]}");
    buffer.writeln("Confidence: ${result["confidence"].toStringAsFixed(2)}%");
    buffer.writeln("Status Code: ${result["status_code"]}");
    buffer.writeln("");
    buffer.writeln("MODEL PREDICTIONS:");
    buffer.writeln("-" * 30);
    for (final e in preds.entries) {
      buffer.writeln(
        "${e.key}: ${e.value.predictedClass} (${e.value.confidence.toStringAsFixed(2)}%)",
      );
    }
    await File(reportPath).writeAsString(buffer.toString());
    return reportPath;
  }
}