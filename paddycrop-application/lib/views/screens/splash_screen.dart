import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:paddycrop/constants/asset_constants.dart';
import 'package:paddycrop/constants/route_constants.dart';
import 'package:paddycrop/views/wrapper_class/gradient_color.dart';
import 'package:paddycrop/views/wrapper_class/responsive_container.dart';

class SplashScreen extends StatefulWidget {
  static const String routeName = RouteConstants.splashScreen;
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 800), () {
      // ignore: use_build_context_synchronously
      context.go(RouteConstants.startingScreen);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppGradientBackground(
        child: ResponsiveContainer(
          width: 376,
          height: 275,
          child: Center(child: Image.asset(ImageAssetConstants.logoImage)),
        ),
      ),
    );
  }
}
