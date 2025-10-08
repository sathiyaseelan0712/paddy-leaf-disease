import 'package:flutter/material.dart';
import 'package:paddycrop/constants/route_constants.dart';
import 'package:paddycrop/views/widgets/common_components/header_component.dart';
import 'package:paddycrop/views/widgets/common_components/logo_component.dart';
import 'package:paddycrop/views/widgets/dashboard_components/scan_and_get_start.dart';
import 'package:paddycrop/views/widgets/dashboard_components/welcome_component.dart';
import 'package:paddycrop/views/wrapper_class/gradient_color.dart';
import 'package:paddycrop/views/wrapper_class/responsive_positioned.dart';
import 'package:paddycrop/views/wrapper_class/responsive_sizedbox.dart';

class StartingScreen extends StatefulWidget {
  static const String routeName = RouteConstants.startingScreen;
  const StartingScreen({super.key});

  @override
  State<StartingScreen> createState() => _StartingScreenState();
}

class _StartingScreenState extends State<StartingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppGradientBackground(
        child: Stack(
          children: [
            ResponsivePositioned(top: 55, left: 24, child: HeaderComponent(isStartingScreen: true)),
            ResponsivePositioned(
              top: 62,
              left: 17,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  LogoComponent(),
                  ResponsiveSizedBox(height: 42),
                  WelcomeComponent(userName: "Sathiyaseelan"),
                  ResponsiveSizedBox(height: 42),
                  ScanImageComponents(),
                  ResponsiveSizedBox(height: 42),
                  GetStartButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
