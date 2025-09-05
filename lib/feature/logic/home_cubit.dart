import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:read_easy/core/helpers/my_logger.dart';
import '../../core/utils/app_text_styles.dart';

import '../data/repo/home_repo.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeRepo _homeRepo;
  HomeCubit(this._homeRepo) : super(HomeInitial());

  Future<void> prepareBook({
    required Size pageSize,
    required double fontSize,
  }) async {
    try {
      emit(HomeLoading(0));
      MyLogger.yellow('Loading book......');
      final bookText = await _homeRepo.loadBook();
      MyLogger.green('Loaded book with: ${bookText.length} Charachters');
      final style = AppTextStyles.mainTextStyle(fontSize: fontSize);

      List<int> finalPageMap = [];

      final pageMapStream = _homeRepo.createPageMap(
        text: bookText,
        size: pageSize,
        style: style,
      );

      await for (final pageMapUpdate in pageMapStream) {
        // MyLogger.magenta(
        //   'rendered page map with ${pageMapUpdate.length} pages',
        // );
        emit(HomeLoading(pageMapUpdate.length));

        finalPageMap = pageMapUpdate;
      }

      emit(HomeLoaded(fullText: bookText, pageMap: finalPageMap));
    } catch (e) {
      emit(HomeError(e.toString()));
      MyLogger.red('Error preparing book: ${e.toString()}');
    }
  }
}
