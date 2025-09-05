import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:read_easy/core/helpers/my_logger.dart';

import 'package:read_easy/feature/logic/home_cubit.dart';
import '../../../core/utils/app_assets.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../core/cache/cache_helper.dart';
import '../../core/cache/cache_keys.dart';
import '../data/repo/home_repo.dart';
import '../logic/home_state.dart';

/// This widget's only job is to create and provide the HomeCubit.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit(HomeRepo()),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  late final PageController _pageController;
  late double _fontSize;
  late int _initialPage;
  final String _bookId = AppAssets.testBook;

  bool _isBookPrepared =
      false; // Flag to ensure prepareBook is called only once.

  @override
  void initState() {
    super.initState();
    _fontSize = CacheHelper.getDouble(key: CacheKeys.lastUsedFontSize) ?? 18.0;

    _initialPage =
        CacheHelper.getInt(key: CacheKeys.lastPageOpen(_bookId)) ?? 0;
    MyLogger.green('Last opened page: $_initialPage');
    _pageController = PageController(initialPage: _initialPage);
    _pageController.addListener(_scrollListener);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // This method is the correct place to call code that uses MediaQuery.
    // We use a flag to make sure it only runs the first time.
    if (!_isBookPrepared) {
      final screenSize = MediaQuery.of(context).size;
      final textRenderSize = Size(
        screenSize.width * 0.9,
        screenSize.height * 0.7,
      );
      context.read<HomeCubit>().prepareBook(
        bookId: _bookId,
        pageSize: textRenderSize,
        fontSize: _fontSize,
      );
      _isBookPrepared = true;
    }
  }

  void _scrollListener() {
    final currentPage = _pageController.page?.round() ?? 0;
    context.read<HomeCubit>().saveLastPage(_bookId, currentPage);
  }

  @override
  void dispose() {
    _pageController.removeListener(_scrollListener);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(title: const Text('ReadEasy')),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenSize.width * 0.05,
          vertical: screenSize.height * 0.02,
        ),
        child: SafeArea(
          child: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              if (state is HomeLoading) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
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
                    final startIndex = state.pageMap[index];
                    final endIndex = (index + 1 < state.pageMap.length)
                        ? state.pageMap[index + 1]
                        : state.fullText.length;
                    final pageText = state.fullText.substring(
                      startIndex,
                      endIndex,
                    );

                    return Text(
                      pageText,
                      style: AppTextStyles.mainTextStyle(
                        fontSize: state.fontSize,
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
    );
  }
}
