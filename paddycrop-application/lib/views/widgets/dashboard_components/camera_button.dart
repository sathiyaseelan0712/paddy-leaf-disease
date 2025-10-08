import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:paddycrop/constants/route_constants.dart';

class CameraButtonComponents extends StatefulWidget {
  final CameraController controller;

  const CameraButtonComponents({super.key, required this.controller});

  @override
  State<CameraButtonComponents> createState() => _CameraButtonComponentsState();
}

class _CameraButtonComponentsState extends State<CameraButtonComponents> {
  bool isFlashOn = false;

  Future<void> _pickFromGallery() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null && mounted) {
      context.pop();
      context.push(RouteConstants.verifyImageScreen, extra: picked.path);
    }
  }

  Future<void> _takePhoto() async {
    if (!widget.controller.value.isInitialized) return;
    final picture = await widget.controller.takePicture();
    if (mounted) {
      context.pop();
      context.push(RouteConstants.verifyImageScreen, extra: picture.path);
    }
  }

  Future<void> _toggleFlash() async {
    if (!widget.controller.value.isInitialized) return;
    if (isFlashOn) {
      await widget.controller.setFlashMode(FlashMode.off);
    } else {
      await widget.controller.setFlashMode(FlashMode.torch);
    }
    setState(() => isFlashOn = !isFlashOn);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: const Icon(Icons.photo_library, color: Colors.white, size: 32),
          onPressed: _pickFromGallery,
        ),
        GestureDetector(
          onTap: _takePhoto,
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
            ),
          ),
        ),
        IconButton(
          icon: Icon(
            isFlashOn ? Icons.flash_on : Icons.flash_off,
            color: Colors.white,
            size: 32,
          ),
          onPressed: _toggleFlash,
        ),
      ],
    );
  }
}
