import 'package:flutter/material.dart';

class CacheKeys {
  CacheKeys._();

  static const String lastUsedFontSize = 'lastUsedFontSize';
  static const String backgroundColor = 'backgroundColor';

  static String bookmark(String bookId) {
    final sanitizedId = _sanitize(bookId);
    return '${sanitizedId}_bookmark';
  }

  static String lastPageOpen(String bookId) {
    final sanitizedId = _sanitize(bookId);
    return '${sanitizedId}_lastPageOpen';
  }

  static String pageMap(String bookId, double fontSize, Size pageSize) {
    final int width = pageSize.width.round();
    final int height = pageSize.height.round();
    return 'pageMap_${bookId}_fs${fontSize}_w${width}_h${height}';
  }

  static String _sanitize(String input) {
    return input.replaceAll(RegExp(r'[/\\]'), '_');
  }
}
