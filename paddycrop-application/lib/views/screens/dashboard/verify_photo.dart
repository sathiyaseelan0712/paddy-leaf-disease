// ignore_for_file: use_build_context_synchronously, deprecated_member_use

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
  final _analyzer = MultiModelAnalyzer();
  bool _isAnalyzing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppGradientBackground(
        child: Stack(
          children: [
            // Your main UI
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
                    "verify_photo.title",
                    style: StyleConstants.customStyle(
                      30,
                      Colors.white,
                      FontWeight.bold,
                    ),
                  ),
                  ResponsiveSizedBox(height: 40),
                  _buildImagePreview(),
                  ResponsiveSizedBox(height: 64),
                  CustomButton(
                    bgColor: StyleConstants.lightGreenColor,
                    text: "verify_photo.upload",
                    textColor: Colors.white,
                    onPressed: () {
                      if (_isAnalyzing) return;
                      _uploadImage(); // This now calls the local analyzer
                    },
                  ),
                  ResponsiveSizedBox(height: 32),
                  CustomButton(
                    bgColor: StyleConstants.greenColor,
                    text: "verify_photo.retake",
                    textColor: Colors.white,
                    onPressed: () {
                      context.pop();
                      context.push(RouteConstants.cameraScreen);
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
            SizedBox(height: 16),
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

  // --- THIS METHOD IS COMPLETELY REPLACED ---
  Future<void> _uploadImage() async {
    setState(() {
      _isAnalyzing = true;
    });

    try {
      final AnalysisResult result = await _analyzer.analyze(widget.imagePath);
      print(result.toMap());
      setState(() {
        _isAnalyzing = false;
      });

      context.pop();
      if (result.statusCode == 1) {
        // Disease
        context.push(
          RouteConstants.diseaseScreen,
          extra: {'imagePath': widget.imagePath, 'response': result.toMap()},
        );
      } else if (result.statusCode == 0) {
        // Healthy
        context.push(
          RouteConstants.happyScreen,
          extra: {'imagePath': widget.imagePath, 'response': result.toMap()},
        );
      } else {
        // Not Paddy
        context.push(RouteConstants.notPaddyScreen, 
          extra: {'imagePath': widget.imagePath, 'response': result.toMap()},
        );
      }
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
      });
      _showErrorDialog('An error occurred during analysis: $e');
    }
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
