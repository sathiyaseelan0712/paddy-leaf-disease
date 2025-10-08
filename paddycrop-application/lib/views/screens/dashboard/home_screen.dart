import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:paddycrop/constants/asset_constants.dart';
import 'package:paddycrop/constants/route_constants.dart';
import 'package:paddycrop/constants/style_constants.dart';
import 'package:paddycrop/views/widgets/common_components/header_component.dart';
import 'package:paddycrop/views/widgets/dashboard_components/threeicons_components.dart';
import 'package:paddycrop/views/wrapper_class/gradient_color.dart';
import 'package:paddycrop/views/wrapper_class/responsive_container.dart';
import 'package:paddycrop/views/wrapper_class/responsive_positioned.dart';
import 'package:paddycrop/views/wrapper_class/responsive_sizedbox.dart';
import 'package:paddycrop/views/wrapper_class/responsive_text.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = RouteConstants.homeScreen;
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppGradientBackground(
        child: Stack(
          children: [
            const ResponsivePositioned(
              top: 55,
              left: 24,
              child: HeaderComponent(),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const ResponsiveSizedBox(height: 32),
                  _buildTextGroup(
                    ['home.scan_title1', 'home.scan_title2'],
                    StyleConstants.yellowColor,
                    36,
                    FontWeight.w600,
                  ),
                  const ResponsiveSizedBox(height: 32),
                  _buildTextGroup(
                    ['home.reveal_title1', 'home.reveal_title2'],
                    Colors.black,
                    24,
                    FontWeight.w500,
                  ),
                  const ResponsiveSizedBox(height: 32),
                  const ThreeIconsComponents(),
                  const ResponsiveSizedBox(height: 32),
                  _buildTextGroup(
                    [
                      'home.instruction1',
                      'home.instruction2',
                      'home.instruction3',
                    ],
                    StyleConstants.yellowColor,
                    24,
                    FontWeight.w400,
                  ),
                  InkWell(
                    onTap: () {
                      context.push(RouteConstants.cameraScreen);
                    },
                    child: ResponsiveContainer(
                      width: 180,
                      height: 200,
                      child: Image.asset(
                        IconAssetConstants.scanIcon,
                        fit: BoxFit.fill,
                        width: 90,
                        height: 140,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextGroup(
    List<String> text,
    Color color,
    double fontSize,
    FontWeight fontWeight,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: text.map((line) {
        return ResponsiveText(
          line,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: color,
          ),
        );
      }).toList(),
    );
  }
}
