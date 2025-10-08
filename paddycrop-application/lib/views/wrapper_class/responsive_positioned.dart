import 'package:flutter/material.dart';

class ResponsivePositioned extends StatelessWidget {
  static const double baseWidth = 414.0;
  static const double baseHeight = 896.0;

  final double? left;
  final double? top;
  final double? right;
  final double? bottom;
  final Widget? child;

  const ResponsivePositioned({
    this.left,
    this.top,
    this.right,
    this.bottom,
    this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    final double? scaledLeft =
        left != null ? (left! / baseWidth) * screenWidth : null;
    final double? scaledTop =
        top != null ? (top! / baseHeight) * screenHeight : null;
    final double? scaledRight =
        right != null ? (right! / baseWidth) * screenWidth : null;
    final double? scaledBottom =
        bottom != null ? (bottom! / baseHeight) * screenHeight : null;

    return Positioned(
      left: scaledLeft,
      top: scaledTop,
      right: scaledRight,
      bottom: scaledBottom,
      child: child ?? SizedBox.shrink(),
    );
  }
}
