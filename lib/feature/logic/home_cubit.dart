import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:read_easy/core/helpers/my_logger.dart';
import '../../core/cache/cache_helper.dart';
import '../../core/cache/cache_keys.dart';
import '../../core/utils/app_text_styles.dart';
import '../data/repo/home_repo.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepo _homeRepo;
  HomeCubit(this._homeRepo) : super(HomeInitial());

  /// Prepares the book for reading. It first checks for a cached page map.
  /// If not found, it generates a new one, shows progress, and saves it.
  Future<void> prepareBook({
    required String bookId,
    required Size pageSize,
    required double fontSize,
  }) async {
    try {
      emit(HomeLoading(0));
      MyLogger.yellow('Preparing book: $bookId with font size: $fontSize');

      // Generate a unique key for the page map based on the book and font size.
      final String pageMapKey = CacheKeys.pageMap(bookId, fontSize);

      // Load the full book text.
      final bookText = await _homeRepo.loadBook(bookId: bookId);

      // Check if a Page Map is already cached for this font size.
      final cachedMap = CacheHelper.getStringList(key: pageMapKey);

      if (cachedMap != null && cachedMap.isNotEmpty) {
        MyLogger.cyan('Found cached Page Map for font size $fontSize!');
        final pageMap = cachedMap.map((i) => int.parse(i)).toList();
        emit(
          HomeLoaded(fullText: bookText, pageMap: pageMap, fontSize: fontSize),
        );
      } else {
        MyLogger.magenta('No cached map found. Generating new Page Map...');
        // If not cached, generate it now.
        final style = AppTextStyles.mainTextStyle(fontSize: fontSize);
        List<int> finalPageMap = [];

        final pageMapStream = _homeRepo.createPageMap(
          text: bookText,
          size: pageSize,
          style: style,
        );

        await for (final pageMapUpdate in pageMapStream) {
          emit(HomeLoading(pageMapUpdate.length));
          finalPageMap = pageMapUpdate;
        }

        // Save the newly generated map to the cache.
        final pageMapAsString = finalPageMap.map((i) => i.toString()).toList();
        await CacheHelper.saveData(key: pageMapKey, value: pageMapAsString);
        MyLogger.cyan('New Page Map saved to cache!');

        emit(
          HomeLoaded(
            fullText: bookText,
            pageMap: finalPageMap,
            fontSize: fontSize,
          ),
        );
      }
    } catch (e) {
      emit(HomeError(e.toString()));
      MyLogger.red('Error preparing book: ${e.toString()}');
    }
  }

  /// Saves the last page the user was on for a specific book.
  Future<void> saveLastPage(String bookId, int page) async {
    final key = CacheKeys.lastPageOpen(bookId);
    await CacheHelper.saveData(key: key, value: page);
  }

  /// Saves a bookmarked page for a specific book.
  Future<void> saveBookmark(String bookId, int page) async {
    final key = CacheKeys.bookmark(bookId);
    await CacheHelper.saveData(key: key, value: page);
    MyLogger.green('Bookmarked page $page for book: $bookId');
  }

  /// Updates the font size, saves it, and triggers a full book preparation.
  Future<void> updateFontSize({
    required String bookId,
    required Size pageSize,
    required double newFontSize,
  }) async {
    // Save the new font size as the default for the next app launch.
    await CacheHelper.saveData(
      key: CacheKeys.lastUsedFontSize,
      value: newFontSize,
    );
    // Re-prepare the book with the new font size.
    await prepareBook(
      bookId: bookId,
      pageSize: pageSize,
      fontSize: newFontSize,
    );
  }
}
