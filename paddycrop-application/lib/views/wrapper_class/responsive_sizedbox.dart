import 'package:flutter/material.dart';

class ResponsiveSizedBox extends StatelessWidget {
  static const double baseWidth = 414.0;
  static const double baseHeight = 896.0;

  final double width;
  final double height;
  final Widget? child;

  const ResponsiveSizedBox({
    this.width = 0,
    this.height = 0,
    this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    final double widthScale = screenSize.width / baseWidth;
    final double heightScale = screenSize.height / baseHeight;

    final double scaledWidth = width * widthScale;
    final double scaledHeight = height * heightScale;

    return SizedBox(
      width: scaledWidth,
      height: scaledHeight,
      child: child,
    );
  }
}
