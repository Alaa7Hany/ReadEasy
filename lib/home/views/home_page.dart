import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:read_easy/core/helpers/my_logger.dart';
import 'package:read_easy/home/logic/home_cubit/home_cubit.dart';
import 'package:read_easy/home/views/widgets/animated_page.dart';
import '../../../core/utils/app_assets.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../core/cache/cache_helper.dart';
import '../../core/cache/cache_keys.dart';
import '../data/repo/home_repo.dart';
import '../logic/home_cubit/home_state.dart';
import 'widgets/settings_panel.dart';

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
  late String _bookTitle;
  late Color _backgroundColor;
  int _currentPage = 0;
  bool _isBookPreparationTriggered = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _bookTitle = _bookId.split('/').last.replaceAll('.txt', '');
    _fontSize = CacheHelper.getDouble(key: CacheKeys.lastUsedFontSize) ?? 18.0;
    _initialPage =
        CacheHelper.getInt(key: CacheKeys.lastPageOpen(_bookId)) ?? 0;
    _currentPage = _initialPage;
    _pageController = PageController(initialPage: _initialPage);
    _pageController.addListener(_scrollListener);
    _backgroundColor = Color(
      CacheHelper.getInt(key: 'backgroundColor') ?? 0xFFFAF3E0,
    );
  }

  void _scrollListener() {
    final page = _pageController.page?.round() ?? 0;
    if (page != _currentPage) {
      setState(() {
        _currentPage = page;
      });
    }
    context.read<HomeCubit>().saveLastPage(_bookId, page);
  }

  @override
  void dispose() {
    _pageController.removeListener(_scrollListener);
    _pageController.dispose();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: _buildAppBar(context),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Define the text style that will be used for rendering.
            final textStyle = AppTextStyles.mainTextStyle(fontSize: _fontSize);

            // Create a temporary TextPainter to measure a single line.
            final singleLinePainter = TextPainter(
              text: TextSpan(text: 'a', style: textStyle),
              textDirection: TextDirection.ltr,
            )..layout();

            // Get the precise height of one line for overflow prevention.
            final singleLineHeight = singleLinePainter.height;

            // ===================== THE CHANGE =====================
            // Define your desired bottom margin in logical pixels.
            const double bottomSafetyMargin = 100.0;

            // Calculate the final rendering size, subtracting BOTH the line height
            // for overflow correction and your new safety margin for padding.
            final textRenderSize = Size(
              constraints.maxWidth,
              constraints.maxHeight - singleLineHeight - bottomSafetyMargin,
            );
            // ================= END OF THE CHANGE ===================
            if (!_isBookPreparationTriggered) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  context.read<HomeCubit>().prepareBook(
                    bookId: _bookId,
                    pageSize: textRenderSize,
                    fontSize: _fontSize,
                  );
                  _isBookPreparationTriggered = true;
                }
              });
            }

            return BlocBuilder<HomeCubit, HomeState>(
              builder: (context, state) {
                if (state is HomeLoaded) {
                  return PageView.builder(
                    controller: _pageController,
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
                        pageController: _pageController,
                      );
                    },
                  );
                } else if (state is HomeLoading) {
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
                } else if (state is HomeError) {
                  return Center(child: Text('Error: ${state.message}'));
                }
                return const Center(child: CircularProgressIndicator());
              },
            );
          },
        ),
      ),
      bottomNavigationBar: null,
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: _backgroundColor,
      title: Text(
        _bookTitle,
        style: AppTextStyles.mainTextStyle(
          fontSize: 22,
        ).copyWith(color: AppColors.charcoal),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      actions: [
        BlocBuilder<HomeCubit, HomeState>(
          builder: (context, state) {
            if (state is HomeLoaded) {
              return GestureDetector(
                onTap: () =>
                    _showJumpToPageDialog(context, state.pageMap.length),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Center(
                    child: Text(
                      '${_currentPage + 1}/${state.pageMap.length}',
                      style: AppTextStyles.mainTextStyle(
                        fontSize: 16,
                      ).copyWith(color: AppColors.charcoal),
                    ),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        IconButton(
          icon: const Icon(Icons.settings, color: AppColors.charcoal),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) {
                return SettingsPanel(
                  backgroundColor: _backgroundColor,
                  currentFontSize: _fontSize,
                  onApply: (newFontSize, newBackgroundColor) {
                    setState(() {
                      _backgroundColor = newBackgroundColor;
                      _fontSize = newFontSize;
                      _isBookPreparationTriggered = false;
                    });
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }

  void _showJumpToPageDialog(BuildContext context, int totalPages) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: _backgroundColor,
          title: const Text('Jump to Page'),
          content: TextField(
            controller: textController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Enter page number (1-$totalPages)',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final pageNum = int.tryParse(textController.text);
                if (pageNum != null && pageNum > 0 && pageNum <= totalPages) {
                  _pageController.jumpToPage(pageNum - 1);
                  Navigator.pop(context);
                }
              },
              child: const Text('Go'),
            ),
          ],
        );
      },
    );
  }
}
