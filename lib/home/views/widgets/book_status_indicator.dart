import 'package:flutter/material.dart';
import 'package:read_easy/core/utils/app_text_styles.dart';
import 'package:read_easy/home/logic/home_cubit/home_state.dart';

class BookStatusIndicator extends StatelessWidget {
  final HomeState state;
  const BookStatusIndicator({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    if (state is HomeLoading) {
      final loadingState = state as HomeLoading;
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Preparing book...\n${loadingState.pagesCalculated} pages found',
              textAlign: TextAlign.center,
              style: AppTextStyles.mainTextStyle(fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (state is HomeError) {
      final errorState = state as HomeError;
      return Center(child: Text('Error: ${errorState.message}'));
    }

    // Default case, can be a loading indicator or an empty container
    return const Center(child: CircularProgressIndicator());
  }
}
