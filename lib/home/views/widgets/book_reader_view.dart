import 'package:flutter/material.dart';
import 'package:read_easy/home/logic/home_cubit/home_state.dart';
import 'package:read_easy/home/views/widgets/animated_page.dart';

class BookReaderView extends StatelessWidget {
  final HomeLoaded state;
  final PageController pageController;

  const BookReaderView({
    super.key,
    required this.state,
    required this.pageController,
  });

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: pageController,
      itemCount: state.pageMap.length,
      itemBuilder: (context, index) {
        final pageText = state.fullText.substring(
          state.pageMap[index],
          (index + 1 < state.pageMap.length)
              ? state.pageMap[index + 1]
              : state.fullText.length,
        );
        return AnimatedPage(
          pageText: pageText,
          fontSize: state.fontSize,
          index: index,
          pageController: pageController,
        );
      },
    );
  }
}
