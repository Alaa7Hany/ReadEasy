import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../../../core/utils/app_assets.dart';

class HomeRepo {
  /// Loads the book content from the asset file.
  Future<String> loadBook() async {
    return await rootBundle.loadString(AppAssets.testBook);
  }

  /// Creates a "Page Map" by analyzing small chunks of text, which is highly performant.
  Stream<List<int>> createPageMap({
    required String text,
    required Size size,
    required TextStyle style,
  }) async* {
    final pageMap = [0];
    int currentIndex = 0;

    // This is a safe chunk size to analyze at a time.
    const int chunk_size = 2000;

    while (currentIndex < text.length) {
      // Yield to the UI thread to keep everything responsive.
      await Future.delayed(Duration.zero);

      // Determine the end of the next chunk to analyze.
      final chunkEnd = (currentIndex + chunk_size > text.length)
          ? text.length
          : currentIndex + chunk_size;
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
      yield List.from(pageMap); // Yield progress.
    }

    // Ensure the last page goes to the end of the book.
    if (pageMap.last != text.length) {
      pageMap.add(text.length);
    }

    yield pageMap; // Yield the final, complete map.
  }
}
