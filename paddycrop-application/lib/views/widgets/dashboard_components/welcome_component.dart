import 'package:flutter/material.dart';
import 'package:paddycrop/views/wrapper_class/responsive_container.dart';
import 'package:paddycrop/views/wrapper_class/responsive_sizedbox.dart';
import 'package:paddycrop/views/wrapper_class/responsive_text.dart';

class WelcomeComponent extends StatefulWidget {
  final String userName;
  const WelcomeComponent({super.key, required this.userName});

  @override
  State<WelcomeComponent> createState() => _WelcomeComponentState();
}

class _WelcomeComponentState extends State<WelcomeComponent> {
  @override
  Widget build(BuildContext context) {
    return ResponsiveContainer(
      width: 366,
      height: 85,
      padding: [16, 0, 0, 0],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ResponsiveText(
                "starting.welcome_user",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              ResponsiveText(
                widget.userName,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          ResponsiveSizedBox(height: 4),
          ResponsiveText(
            "starting.welcome_back",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
