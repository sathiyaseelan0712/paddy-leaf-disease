import 'package:flutter/material.dart';
import 'package:paddycrop/constants/asset_constants.dart';
import 'package:paddycrop/views/wrapper_class/responsive_container.dart';

class LogoComponent extends StatelessWidget {
  const LogoComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveContainer(
      width: 266,
      height: 170,
      child: Image.asset(ImageAssetConstants.logoImage),
    );
  }
}
