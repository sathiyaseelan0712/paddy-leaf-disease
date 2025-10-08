import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:paddycrop/constants/route_constants.dart';
import 'package:paddycrop/constants/style_constants.dart';
import 'package:paddycrop/views/utils/loading_utils.dart';
import 'package:paddycrop/views/widgets/dashboard_components/camera_button.dart';
import 'package:paddycrop/views/wrapper_class/gradient_color.dart';
import 'package:paddycrop/views/wrapper_class/responsive_container.dart';
import 'package:paddycrop/views/wrapper_class/responsive_sizedbox.dart';
import 'package:paddycrop/views/wrapper_class/responsive_text.dart';

class CameraScreen extends StatefulWidget {
  static const String routeName = RouteConstants.cameraScreen;
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => CameraScreenState();
}

class CameraScreenState extends State<CameraScreen> {
  late CameraController controller;
  bool isCameraReady = false;
  bool isFlashOn = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      controller = CameraController(
        cameras[0],
        ResolutionPreset.high,
        enableAudio: false,
      );
      await controller.initialize();
      if (!mounted) return;
      setState(() => isCameraReady = true);
    } catch (e) {
      debugPrint("Error initializing camera: $e");
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isCameraReady) {
      return LoadingScreen();
    }
    return Scaffold(
      body: AppGradientBackground(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ResponsiveSizedBox(height: 50),
            ResponsiveText(
              "camera_screen.take_photo",
              style: StyleConstants.customStyle(
                32,
                Colors.white,
                FontWeight.bold,
              ),
            ),
            ResponsiveSizedBox(height: 32),
            ResponsiveContainer(
              width: 414,
              height: 600,
              child: CameraPreview(controller),
            ),
            ResponsiveSizedBox(height: 32),
            CameraButtonComponents(controller: controller),
          ],
        ),
      ),
    );
  }
}
