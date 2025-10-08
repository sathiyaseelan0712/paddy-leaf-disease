import 'package:flutter/material.dart';
import 'package:paddycrop/constants/style_constants.dart';
import 'package:paddycrop/views/wrapper_class/responsive_container.dart';
import 'package:paddycrop/views/wrapper_class/responsive_sizedbox.dart';
import 'package:paddycrop/views/wrapper_class/responsive_text.dart';

class CustomButton extends StatefulWidget {
  final Color bgColor;
  final String text;
  final Color textColor;
  final VoidCallback onPressed;
  final String iconPath;

  const CustomButton({
    super.key,
    required this.bgColor,
    required this.text,
    required this.textColor,
    required this.onPressed,
    this.iconPath = "",
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onPressed,
        child: ResponsiveContainer(
          width: 366,
          height: 50,
          decoration: BoxDecoration(
            color: widget.bgColor,
            borderRadius: BorderRadius.circular(99),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ResponsiveText(
                  widget.text,
                  style: StyleConstants.customStyle(
                    18,
                    widget.textColor,
                    FontWeight.bold,
                  ),
                ),
                if (widget.iconPath.isNotEmpty) ...[
                  const ResponsiveSizedBox(width: 8),
                  Image.asset(widget.iconPath, width: 24, height: 24),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
