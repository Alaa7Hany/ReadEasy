import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class HomeRepo {
  /// Loads the book content from the asset file using its ID (path).
  Future<String> loadBook({required String bookId}) async {
    return await rootBundle.loadString(bookId);
  }

  /// Creates a "Page Map" by analyzing small chunks of text
  Stream<List<int>> createPageMap({
    required String text,
    required Size size,
    required TextStyle style,
  }) async* {
    final pageMap = [0];
    int currentIndex = 0;

    // This is a safe chunk size to analyze at a time.
    const int chunkSize = 2000;

    while (currentIndex < text.length) {
      // Yield to the UI thread to keep everything responsive.
      await Future.delayed(Duration.zero);

      // Determine the end of the next chunk to analyze.
      final chunkEnd = (currentIndex + chunkSize > text.length)
          ? text.length
          : currentIndex + chunkSize;
      final textChunk = text.substring(currentIndex, chunkEnd);

      // Create a painter FOR THE SMALL CHUNK ONLY.
      final textPainter = TextPainter(
        text: TextSpan(text: textChunk, style: style),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(maxWidth: size.width);

      // Find the page break within this small chunk.
      final breakIndex = textPainter
          .getPositionForOffset(Offset(size.width, size.height))
          .offset;

      // If we couldn't fit any text from the chunk, break to avoid an infinite loop.
      if (breakIndex == 0) break;

      // Add the actual character index to our map.
      currentIndex += breakIndex;
      pageMap.add(currentIndex);
      yield List.from(pageMap);
    }

    // Ensure the last page goes to the end of the book.
    if (pageMap.last != text.length) {
      pageMap.add(text.length);
    }

    yield pageMap;
  }
}
