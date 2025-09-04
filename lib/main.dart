import 'package:flutter/material.dart';
import 'package:read_easy/core/utils/app_text_styles.dart';
import 'package:read_easy/feature/views/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ReadEasy',
      theme: ThemeData(fontFamily: AppTextStyles.fontFamily),
      home: const HomePage(),
    );
  }
}
