import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:read_easy/core/utils/app_colors.dart';
import 'package:read_easy/home/views/home_page.dart';

import 'core/cache/cache_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CacheHelper.init();
  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => const ReadEasyApp(),
    ),
  );
  // runApp(const ReadEasyApp());
}

class ReadEasyApp extends StatelessWidget {
  const ReadEasyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
