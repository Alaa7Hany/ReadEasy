import 'package:flutter/material.dart';

import '../../../core/utils/app_text_styles.dart';

class AnimatedPage extends StatelessWidget {
  const AnimatedPage({
    super.key,
    required this.pageText,
    required this.fontSize,
    required this.index,
    required this.pageController,
  });

  final String pageText;
  final double fontSize;
  final int index;
  final PageController pageController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pageController,
      builder: (context, child) {
        double pageValue = 0.0;
        if (pageController.position.haveDimensions) {
          pageValue = pageController.page ?? 0;
        }

        double value = pageValue - index;

        if (value > 0 && value < 1) {
          double rotationAngle = (value * 3.1415 / 2).clamp(0.0, 3.1415 / 2);

          return Transform(
            alignment: Alignment.centerLeft,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(rotationAngle),
            child: child,
          );
        } else {
          return child!;
        }
      },
      child: Align(
        alignment: Alignment.topLeft,
        child: Text(
          pageText,
          style: AppTextStyles.mainTextStyle(fontSize: fontSize),
        ),
      ),
    );
  }
}
