import 'package:flutter/material.dart';
import 'package:paddycrop/constants/asset_constants.dart';
import 'package:paddycrop/views/wrapper_class/responsive_container.dart';

class ThreeIconsComponents extends StatelessWidget {
  const ThreeIconsComponents({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveContainer(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildIconContainer(ImageAssetConstants.paddyLeaf2),
          _buildIconContainer(ImageAssetConstants.scanImage2),
          _buildIconContainer(ImageAssetConstants.paddyLeaf1),
        ],
      ),
    );
  }

  Widget _buildIconContainer(String iconPath) {
    return SizedBox(child: Center(child: Image.asset(iconPath)));
  }
}
