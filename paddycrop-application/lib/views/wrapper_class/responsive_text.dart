import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle style;

  static const double baseWidth = 414.0;
  static const double baseHeight = 896.0;

  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;

  const ResponsiveText(
    this.text, {
    super.key,
    required this.style,
    this.textAlign,
    this.overflow,
    this.maxLines,
  });

  double _responsiveFontSize(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final widthScale = size.width / baseWidth;
    final heightScale = size.height / baseHeight;
    double scale = math.min(widthScale, heightScale);
    scale = scale.clamp(0.70, 1.30);

    double baseFontSize = (style.fontSize ?? 14) * scale;
    if (context.locale.languageCode == 'ta') {
      baseFontSize *= 0.75;
    }

    return baseFontSize;
  }

  @override 
  Widget build(BuildContext context) {
    return Text(
      text.tr(),
      style: style.copyWith(
        fontSize: _responsiveFontSize(context),
        fontFamily: style.fontFamily ?? 'Sansation',
        color: style.color ?? Colors.black,
        fontWeight: style.fontWeight ?? FontWeight.normal,
      ),
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
    );
  }
}
