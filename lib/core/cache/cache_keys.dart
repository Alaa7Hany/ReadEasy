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

  static String pageMap(String bookId, double fontSize) {
    final sanitizedId = _sanitize(bookId);
    return '${sanitizedId}_pageMap_$fontSize';
  }

  static String _sanitize(String input) {
    return input.replaceAll(RegExp(r'[/\\]'), '_');
  }
}
