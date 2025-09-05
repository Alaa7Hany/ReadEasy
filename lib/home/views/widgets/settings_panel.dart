import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:read_easy/core/utils/app_colors.dart';

import '../../../core/utils/app_text_styles.dart';
import '../../logic/settings_cubit/settings_cubit.dart';
import '../../logic/settings_cubit/settings_state.dart';

class SettingsPanel extends StatelessWidget {
  final Function(double fontSize, Color backgroundColor) onApply;
  final Color backgroundColor;
  final double currentFontSize;

  const SettingsPanel({
    super.key,
    required this.onApply,
    required this.backgroundColor,
    required this.currentFontSize,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final panelHeight = screenSize.height * 0.5;

    return BlocProvider(
      create: (context) => SettingsCubit(currentFontSize, backgroundColor),
      child: Builder(
        builder: (context) {
          final cubit = SettingsCubit.get(context);
          return BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, state) {
              return Container(
                width: double.infinity,
                // height: panelHeight,
                padding: EdgeInsets.symmetric(
                  vertical: panelHeight * 0.0,
                  horizontal: panelHeight * 0.05,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Settings',
                        style: AppTextStyles.mainTextStyle(fontSize: 18),
                      ),
                      SizedBox(height: panelHeight * 0.02),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Font Size',
                            style: AppTextStyles.mainTextStyle(fontSize: 18),
                          ),
                          Slider(
                            activeColor: AppColors.skyBlue,
                            value: cubit.fontSize,
                            min: 10.0,
                            max: 30.0,
                            divisions: 20,
                            label: cubit.fontSize.round().toString(),

                            onChanged: (double value) {
                              cubit.updateFontSize(value);
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: panelHeight * 0.02),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Test Text',
                          style: AppTextStyles.mainTextStyle(fontSize: 10),
                        ),
                      ),
                      SizedBox(height: panelHeight * 0.02),
                      _buildTestText(cubit, panelHeight),
                      SizedBox(height: panelHeight * 0.04),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Background',
                            style: AppTextStyles.mainTextStyle(fontSize: 18),
                          ),
                          Row(
                            children: [
                              _buildColorChip(
                                cubit,
                                AppColors.white,
                                cubit.backgroundColor,
                                panelHeight,
                              ),
                              SizedBox(width: panelHeight * 0.04),
                              _buildColorChip(
                                cubit,
                                AppColors.cream,
                                cubit.backgroundColor,
                                panelHeight,
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: panelHeight * 0.04),

                      Align(
                        alignment: Alignment.bottomCenter,
                        child: _buildActionsRow(
                          () {
                            {
                              if (cubit.fontSize != currentFontSize) {
                                cubit.updateFontSize(currentFontSize);
                              }
                              if (cubit.backgroundColor.toARGB32() !=
                                  backgroundColor.toARGB32()) {
                                cubit.updateBackgroundColor(backgroundColor);
                              }
                            }
                          },
                          () {
                            {
                              cubit.applySettings(
                                currentFontSize,
                                backgroundColor,
                              );
                              onApply(cubit.fontSize, cubit.backgroundColor);
                              Navigator.of(context).pop();
                            }
                          },
                          panelHeight,
                        ),
                      ),
                      SizedBox(height: panelHeight * 0.02),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildActionsRow(
    void Function()? onReset,
    void Function()? onApply,

    double panelHeight,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          onPressed: onReset,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            padding: EdgeInsets.symmetric(
              horizontal: panelHeight * 0.1,
              vertical: panelHeight * 0.02,
            ),
          ),
          child: Text(
            'Reset',
            style: AppTextStyles.mainTextStyle(
              fontSize: 16,
            ).copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        ElevatedButton(
          onPressed: onApply,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.skyBlue,
            padding: EdgeInsets.symmetric(
              horizontal: panelHeight * 0.1,
              vertical: panelHeight * 0.02,
            ),
          ),
          child: Text(
            'Apply',
            style: AppTextStyles.mainTextStyle(
              fontSize: 16,
            ).copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildColorChip(
    SettingsCubit cubit,
    Color color,
    Color selectedColor,
    double panelHeight,
  ) {
    final bool isSelected = color.toARGB32() == selectedColor.toARGB32();
    return GestureDetector(
      onTap: () => cubit.updateBackgroundColor(color),
      child: Container(
        width: panelHeight * 0.15,
        height: panelHeight * 0.15,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? AppColors.skyBlue : Colors.grey.shade400,
            width: panelHeight * 0.01,
          ),
        ),
        child: isSelected
            ? const Icon(Icons.check, color: AppColors.skyBlue)
            : null,
      ),
    );
  }

  Widget _buildTestText(SettingsCubit cubit, double panelHeight) {
    return Container(
      padding: EdgeInsets.all(panelHeight * 0.02),
      decoration: BoxDecoration(
        color: cubit.backgroundColor,
        border: Border.all(color: Colors.grey, width: panelHeight * 0.01),
      ),
      child: Text(
        'Adjust the font size and background color to see a live preview here.',
        style: AppTextStyles.mainTextStyle(fontSize: cubit.fontSize),
      ),
    );
  }
}
