import 'package:flutter/material.dart';

class StyleConstants {
  static TextStyle customStyle(
    double fontSize,
    Color? color,
    FontWeight? fontWeight,
  ) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight ?? FontWeight.w500,
      fontFamily: 'Sansation',
      color: color ?? Colors.white,
      height: 1.21,
    );
  }

  static const Color greenColor = Color(0xFF012626);
  static const Color lightGreenColor = Color(0xFF61AF2B);
  static const Color yellowColor = Color(0xFFDCECA1);
  static const Color happyBgColor = Color(0xFFE0F8D7);
  static const Color sadBgColor = Color(0xFFF8D5D5);
  static const Color treatmentBgColor = Color(0xFFF2F6C5);
  static const Color darkRed = Color(0xFFD44848);
}
