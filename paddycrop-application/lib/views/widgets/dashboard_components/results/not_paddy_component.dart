import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:paddycrop/constants/asset_constants.dart';
import 'package:paddycrop/constants/route_constants.dart';
import 'package:paddycrop/constants/style_constants.dart';
import 'package:paddycrop/views/widgets/custom_widgets/custom_button.dart';
import 'package:paddycrop/views/wrapper_class/responsive_container.dart';
import 'package:paddycrop/views/wrapper_class/responsive_sizedbox.dart';
import 'package:paddycrop/views/wrapper_class/responsive_text.dart';

class NotPaddyComponents extends StatefulWidget {
  const NotPaddyComponents({super.key});

  @override
  State<NotPaddyComponents> createState() => NotPaddyComponentsState();
}

class NotPaddyComponentsState extends State<NotPaddyComponents> {
  @override
  Widget build(BuildContext context) {
    return ResponsiveContainer(
      width: 414,
      height: 448,
      decoration: BoxDecoration(
        color: StyleConstants.sadBgColor,
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
            Image.asset(
              IconAssetConstants.cryingStickerIcon,
              width: 172,
              height: 172,
            ),
            ResponsiveSizedBox(height: 32),
            ResponsiveText(
              "not_paddy.title",
              style: StyleConstants.customStyle(
                24,
                StyleConstants.greenColor,
                FontWeight.w700,
              ),
            ),
            ResponsiveSizedBox(height: 32),
            CustomButton(
              bgColor: StyleConstants.lightGreenColor,
              text: 'not_paddy.scan_again',
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
