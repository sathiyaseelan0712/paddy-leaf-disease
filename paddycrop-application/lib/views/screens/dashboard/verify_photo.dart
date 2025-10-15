import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:paddycrop/constants/multi_model_class.dart';
import 'package:paddycrop/constants/route_constants.dart';
import 'package:paddycrop/constants/style_constants.dart';
import 'package:paddycrop/views/widgets/common_components/header_component.dart';
import 'package:paddycrop/views/widgets/custom_widgets/custom_button.dart';
import 'package:paddycrop/views/wrapper_class/gradient_color.dart';
import 'package:paddycrop/views/wrapper_class/responsive_container.dart';
import 'package:paddycrop/views/wrapper_class/responsive_positioned.dart';
import 'package:paddycrop/views/wrapper_class/responsive_sizedbox.dart';
import 'package:paddycrop/views/wrapper_class/responsive_text.dart';
import 'dart:io';

class VerifyPhotoScreen extends StatefulWidget {
  static const String routeName = RouteConstants.verifyImageScreen;
  final String imagePath;
  const VerifyPhotoScreen({super.key, required this.imagePath});
  @override
  State<VerifyPhotoScreen> createState() => _VerifyPhotoScreenState();
}

class _VerifyPhotoScreenState extends State<VerifyPhotoScreen> {
  final _analyzer = SingleModelAnalyzer();
  bool _isAnalyzing = false;

  Future<void> _uploadImage() async {
    setState(() {
      _isAnalyzing = true;
    });

    try {
      const String modelPath = 'assets/models/inceptionv3_model.tflite';

      // Call the analyzer with both the image path and the model path
      final AnalysisResult result = await _analyzer.analyze(
        widget.imagePath,
        modelPath,
      );

      if (!mounted) return;

      setState(() {
        _isAnalyzing = false;
      });
      print('Analysis Result: ${result.finalPrediction}, Confidence: ${result.confidence}, Status Code: ${result.statusCode}');
      final resultData = {
        'imagePath': widget.imagePath,
        'response': result.toMap(),
      };

      context.pop();

      if (result.statusCode == 1) {
        // Disease
        context.push(RouteConstants.diseaseScreen, extra: resultData);
      } else if (result.statusCode == 0) {
        // Healthy
        context.push(RouteConstants.happyScreen, extra: resultData);
      } else {
        // Not Paddy or Low Confidence
        context.push(RouteConstants.notPaddyScreen, extra: widget.imagePath);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isAnalyzing = false;
      });
      _showErrorDialog('An error occurred during analysis: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppGradientBackground(
        child: Stack(
          children: [
            ResponsivePositioned(
              top: 55,
              left: 24,
              child: HeaderComponent(canChangeLanguage: false),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ResponsiveText(
                    "verify_photo.title", // Assuming you use localization
                    style: StyleConstants.customStyle(
                      30,
                      Colors.white,
                      FontWeight.bold,
                    ),
                  ),
                  const ResponsiveSizedBox(height: 40),
                  _buildImagePreview(),
                  const ResponsiveSizedBox(height: 64),
                  CustomButton(
                    bgColor: StyleConstants.lightGreenColor,
                    text: "verify_photo.upload",
                    textColor: Colors.white,
                    onPressed: () {
                      if (!_isAnalyzing) {
                        _uploadImage();
                      }
                    },
                  ),
                  const ResponsiveSizedBox(height: 32),
                  CustomButton(
                    bgColor: StyleConstants.greenColor,
                    text: "verify_photo.retake",
                    textColor: Colors.white,
                    onPressed: () {
                      context.pop();
                      context.pushReplacement(RouteConstants.cameraScreen);
                    },
                  ),
                ],
              ),
            ),
            if (_isAnalyzing) _buildUploadIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadIndicator() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              strokeWidth: 6,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            SizedBox(height: 16),
            Text(
              "Analyzing...",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return ResponsiveContainer(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white, width: 2),
        image: DecorationImage(
          image: FileImage(File(widget.imagePath)),
          fit: BoxFit.cover,
        ),
      ),
      child: const SizedBox(),
    );
  }
}
