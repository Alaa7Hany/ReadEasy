import 'package:flutter/material.dart';
import 'package:read_easy/core/utils/app_colors.dart';
import 'package:read_easy/feature/views/home_page.dart';

void main() {
  runApp(const ReadEasyApp());
}

class ReadEasyApp extends StatelessWidget {
  const ReadEasyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ReadEasy',
      theme: ThemeData(
        progressIndicatorTheme: ProgressIndicatorThemeData(
          color: AppColors.skyBlue,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomePage(),
    );
  }
}
