import 'package:flutter/material.dart';
import 'package:paddycrop/views/wrapper_class/gradient_color.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppGradientBackground(
        child: Center(child: CircularProgressIndicator(color: Colors.white)),
      ),
    );
  }
}
