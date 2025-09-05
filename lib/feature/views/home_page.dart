import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:read_easy/feature/logic/home_cubit.dart';
import '../../core/utils/app_colors.dart';
import '../../core/utils/app_text_styles.dart';
import '../data/repo/home_repo.dart';
import '../logic/home_state.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final PageController _pageController;
  // This would be loaded from shared_preferences in a full implementation
  final int _initialPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final textRenderSize = Size(
      screenSize.width * 0.9,
      screenSize.height * 0.7,
    );
    double initialFontSize = (screenSize.width > 600) ? 22.0 : 18.0;

    return BlocProvider(
      create: (context) =>
          HomeCubit(HomeRepo())
            ..prepareBook(pageSize: textRenderSize, fontSize: initialFontSize),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: AppColors.white,
          appBar: AppBar(title: const Text('ReadEasy')),
          body: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenSize.width * 0.05,
              vertical: screenSize.height * 0.02,
            ),
            child: BlocBuilder<HomeCubit, HomeState>(
              builder: (context, state) {
                if (state is HomeLoading) {
                  return Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: state.pagesCalculated > 0 ? null : 0.0,
                          color: AppColors.skyBlue,
                        ),
                        Text(
                          'Preparing book...\n${state.pagesCalculated} pages found',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.mainTextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  );
                } else if (state is HomeLoaded) {
                  return PageView.builder(
                    controller: _pageController,
                    itemCount: state.pageMap.length,
                    itemBuilder: (context, index) {
                      // Get the start and end index for the current page from the map
                      final startIndex = state.pageMap[index];
                      final endIndex = (index + 1 < state.pageMap.length)
                          ? state.pageMap[index + 1]
                          : state.fullText.length;

                      // Extract the text for just this page
                      final pageText = state.fullText.substring(
                        startIndex,
                        endIndex,
                      );

                      return Text(
                        pageText,
                        style: AppTextStyles.mainTextStyle(
                          fontSize: initialFontSize,
                        ),
                      );
                    },
                  );
                } else if (state is HomeError) {
                  return Center(child: Text('Error: ${state.message}'));
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ),
      ),
    );
  }
}
