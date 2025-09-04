import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

class MySnackbar {
  MySnackbar._();
  static void error(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  static void success(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.lightGreen),
    );
  }
}
