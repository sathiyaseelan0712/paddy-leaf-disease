import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:paddycrop/constants/asset_constants.dart';
import 'package:paddycrop/constants/route_constants.dart';
import 'package:paddycrop/constants/style_constants.dart';
import 'package:paddycrop/views/widgets/custom_widgets/custom_button.dart';
import 'package:paddycrop/views/wrapper_class/responsive_container.dart';
import 'package:paddycrop/views/wrapper_class/responsive_sizedbox.dart';
import 'package:paddycrop/views/wrapper_class/responsive_text.dart';

class HappyComponents extends StatefulWidget {
  const HappyComponents({super.key});

  @override
  State<HappyComponents> createState() => _HappyComponentsState();
}

class _HappyComponentsState extends State<HappyComponents> {
  @override
  Widget build(BuildContext context) {
    return ResponsiveContainer(
      width: 414,
      height: 448,
      decoration: BoxDecoration(
        color: StyleConstants.happyBgColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(45.0),
          topRight: Radius.circular(45.0),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(IconAssetConstants.smileStickerIcon),
            ResponsiveSizedBox(height: 32),
            ResponsiveText(
              "happy_screen.title",
              style: StyleConstants.customStyle(
                24,
                StyleConstants.greenColor,
                FontWeight.w700,
              ),
            ),
            ResponsiveSizedBox(height: 32),
            CustomButton(
              bgColor: StyleConstants.lightGreenColor,
              text: 'happy_screen.scan_again',
              textColor: Colors.white,
              onPressed: () {
                context.pop();
                context.push(RouteConstants.cameraScreen);
              },
              iconPath: IconAssetConstants.scanIcon2,
            ),
          ],
        ),
      ),
    );
  }
}
