import 'dart:io';

import 'package:flutter/material.dart';
import 'package:paddycrop/constants/route_constants.dart';
import 'package:paddycrop/views/widgets/common_components/header_component.dart';
import 'package:paddycrop/views/widgets/dashboard_components/results/not_paddy_component.dart';
import 'package:paddycrop/views/wrapper_class/gradient_color.dart';
import 'package:paddycrop/views/wrapper_class/responsive_container.dart';
import 'package:paddycrop/views/wrapper_class/responsive_positioned.dart';
import 'package:paddycrop/views/wrapper_class/responsive_sizedbox.dart';

class NotpaddyScreen extends StatefulWidget {
  static const String routeName = RouteConstants.notPaddyScreen;
  final String imagePath;
  final Map<String,dynamic> data;
  const NotpaddyScreen({super.key, required this.imagePath, required this.data});

  @override
  State<NotpaddyScreen> createState() => NotpaddyScreenState();
}

class NotpaddyScreenState extends State<NotpaddyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppGradientBackground(
        child: Stack(
          children: [
            Column(
              children: [
                ResponsiveSizedBox(height: 50),
                _buildImagePreview(widget.imagePath),
              ],
            ),
            ResponsivePositioned(
              top: 55,
              left: 24,
              child: HeaderComponent(canChangeLanguage: false),
            ),

            ResponsivePositioned(bottom: 0, child: NotPaddyComponents()),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(String imagePath) {
    return ResponsiveContainer(
      width: 414,
      height: 435,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: FileImage(File(imagePath)),
          fit: BoxFit.cover,
        ),
      ),
      child: const SizedBox(),
    );
  }
}
