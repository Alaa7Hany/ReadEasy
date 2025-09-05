import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:read_easy/core/cache/cache_helper.dart';
import 'package:read_easy/core/cache/cache_keys.dart';

import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this.fontSize, this.backgroundColor) : super(SettingsInitial());

  static SettingsCubit get(BuildContext context) =>
      BlocProvider.of<SettingsCubit>(context);

  double fontSize;
  Color backgroundColor;

  void updateFontSize(double newSize) {
    fontSize = newSize;
    emit(SettingsChange());
  }

  void updateBackgroundColor(Color newColor) {
    backgroundColor = newColor;
    emit(SettingsChange());
  }

  Future<void> applySettings(
    double currentFontSize,
    Color currentBackgroundColor,
  ) async {
    if (fontSize != currentFontSize) {
      await CacheHelper.saveData(
        key: CacheKeys.lastUsedFontSize,
        value: fontSize,
      );
    }
    if (backgroundColor.toARGB32() != currentBackgroundColor.toARGB32()) {
      await CacheHelper.saveData(
        key: CacheKeys.backgroundColor,
        value: backgroundColor.toARGB32(),
      );
    }
  }
}
