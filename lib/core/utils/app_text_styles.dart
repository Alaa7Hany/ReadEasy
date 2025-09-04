import 'package:flutter/material.dart';
import 'app_colors.dart'; // Assuming you have the AppColors class in this file

class AppTextStyles {
  AppTextStyles._();

  static const String fontFamily = 'Georgia';

  static TextStyle mainTextStyle({required double fontSize}) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      // The text color is charcoal.
      color: AppColors.charcoal,
      // A comfortable line height for readability.
      height: 1.5,
    );
  }
}
