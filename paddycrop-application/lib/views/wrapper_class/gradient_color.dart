import 'package:flutter/material.dart';
import 'package:paddycrop/views/wrapper_class/responsive_container.dart';

class AppGradientBackground extends StatefulWidget {
  final Widget child;
  final Color colorUp;
  final Color colorDown;

  const AppGradientBackground({
    super.key,
    required this.child,
    this.colorUp = const Color(0xFFB2ECC2), 
    this.colorDown = const Color(0xFF014546), 
  });

  @override
  State<AppGradientBackground> createState() => _AppGradientBackgroundState();
}

class _AppGradientBackgroundState extends State<AppGradientBackground> {
  @override
  Widget build(BuildContext context) {
    return ResponsiveContainer(
      width: 414,
      height: 896,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.colorUp,
            widget.colorDown,
          ],
        ),
      ),
      child: widget.child,
    );
  }
}
