import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:read_easy/core/helpers/my_logger.dart';

import 'package:read_easy/home/logic/home_cubit/home_cubit.dart';
import '../../../core/utils/app_assets.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../core/cache/cache_helper.dart';
import '../../core/cache/cache_keys.dart';
import '../data/repo/home_repo.dart';
import '../logic/home_cubit/home_state.dart';
import 'widgets/settings_panel.dart';

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
  late int _bookMark;
  final String _bookId = AppAssets.testBook;
  late String _bookTitle;
  late Color _backgroundColor;

  bool _isBookPrepared =
      false; // Flag to ensure prepareBook is called only once.

  @override
  void initState() {
    super.initState();

    _bookTitle = _bookId.split('/').last.replaceAll('.txt', '');

    _fontSize = CacheHelper.getDouble(key: CacheKeys.lastUsedFontSize) ?? 18.0;

    _initialPage =
        CacheHelper.getInt(key: CacheKeys.lastPageOpen(_bookId)) ?? 0;
    MyLogger.green('Last opened page: $_initialPage');
    _bookMark = CacheHelper.getInt(key: CacheKeys.bookmark(_bookId)) ?? -1;
    MyLogger.green('bookmark is on Page: $_bookMark');
    _pageController = PageController(initialPage: _initialPage);
    _pageController.addListener(_scrollListener);

    _backgroundColor = Color(
      CacheHelper.getInt(key: CacheKeys.backgroundColor) ?? 0xFFFFFFFF,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
    final homeCubit = context.read<HomeCubit>();

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: _buildAppBar(context, screenSize, homeCubit),
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
                        style: AppTextStyles.mainTextStyle(fontSize: 22),
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

                    return AnimatedBuilder(
                      animation: _pageController,
                      builder: (context, child) {
                        double pageValue = 0.0;
                        // Make sure the controller is attached to the PageView before using it.
                        if (_pageController.position.haveDimensions) {
                          pageValue = _pageController.page ?? 0;
                        }

                        // 2. Calculate how far this page is from the center of the viewport.
                        // `delta` will be 0 for the page in the center, -1 for the page to the left,
                        // and 1 for the page to the right.
                        double delta = pageValue - index;

                        // 3. Use the delta to create a value for scale and opacity.
                        // The clamp() function ensures the value stays between 0.0 and 1.0.
                        double scale = (1 - (delta.abs() * 0.3)).clamp(
                          0.0,
                          1.0,
                        );
                        double opacity = (1 - (delta.abs() * 0.5)).clamp(
                          0.0,
                          1.0,
                        );

                        // 4. Apply the transformations to the child.
                        return Transform.scale(
                          scale: scale,
                          child: Opacity(opacity: opacity, child: child),
                        );
                      },
                      // The child is your original Text widget.
                      // Passing it here is an optimization so it doesn't rebuild on every scroll tick.
                      child: Text(
                        pageText,
                        style: AppTextStyles.mainTextStyle(
                          fontSize: state.fontSize,
                        ),
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

  AppBar _buildAppBar(
    BuildContext context,
    Size screenSize,
    HomeCubit homeCubit,
  ) {
    return AppBar(
      elevation: 0,
      backgroundColor: _backgroundColor,
      title: Text(
        _bookTitle,
        style: AppTextStyles.mainTextStyle(fontSize: 22),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      actions: [
        // Bookmark Button
        IconButton(
          icon: const Icon(
            Icons.bookmark_add_outlined,
            color: AppColors.charcoal,
          ),
          onPressed: () {
            final currentPage = _pageController.page?.round() ?? 0;
            context.read<HomeCubit>().saveBookmark(_bookId, currentPage);
          },
        ),
        // Settings Button
        IconButton(
          icon: const Icon(Icons.settings, color: AppColors.charcoal),
          onPressed: () {
            showModalBottomSheet(
              backgroundColor: _backgroundColor,
              context: context,

              builder: (BuildContext context) {
                // Return the widget that contains your settings controls
                return SettingsPanel(
                  backgroundColor: _backgroundColor,
                  currentFontSize: _fontSize,
                  onApply: (fontSize, backgroundColor) {
                    setState(() {
                      _backgroundColor = backgroundColor;
                      _fontSize = fontSize;
                    });
                    homeCubit.updateFontSize(
                      bookId: _bookId,
                      pageSize: Size(
                        screenSize.width * 0.9,
                        screenSize.height * 0.7,
                      ),
                      newFontSize: fontSize,
                    );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }
}
