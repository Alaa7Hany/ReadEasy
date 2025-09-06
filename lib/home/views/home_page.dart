import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:read_easy/core/utils/app_colors.dart';
import 'package:read_easy/home/logic/home_cubit/home_cubit.dart';
import 'package:read_easy/home/views/widgets/book_reader_view.dart';
import 'package:read_easy/home/views/widgets/book_status_indicator.dart';
import 'package:read_easy/home/views/widgets/home_appbar.dart';
import '../../../core/utils/app_assets.dart';
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
    final initialPage =
        CacheHelper.getInt(key: CacheKeys.lastPageOpen(_bookId)) ?? 0;
    _currentPage = initialPage;
    _pageController = PageController(initialPage: initialPage);
    _pageController.addListener(_scrollListener);
    _backgroundColor = Color(
      CacheHelper.getInt(key: CacheKeys.backgroundColor) ??
          AppColors.white.toARGB32(),
    );
  }

  void _scrollListener() {
    final page = _pageController.page?.round() ?? 0;
    if (page != _currentPage) {
      setState(() => _currentPage = page);
      context.read<HomeCubit>().saveLastPage(_bookId, page);
    }
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

  void _onSettingsChanged(double newFontSize, Color newBackgroundColor) {
    setState(() {
      _backgroundColor = newBackgroundColor;
      _fontSize = newFontSize;
      _isBookPreparationTriggered = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: HomeAppBar(
        bookTitle: _bookTitle,
        backgroundColor: _backgroundColor,
        currentPage: _currentPage,
        totalPages: context.select(
          (HomeCubit cubit) => cubit.state is HomeLoaded
              ? (cubit.state as HomeLoaded).pageMap.length
              : 0,
        ),
        onPageJump: (page) => _pageController.jumpToPage(page),
        onSettingsPressed: () {
          showModalBottomSheet(
            backgroundColor: _backgroundColor,
            context: context,
            isScrollControlled: true,
            builder: (_) => SettingsPanel(
              backgroundColor: _backgroundColor,
              currentFontSize: _fontSize,
              onApply: _onSettingsChanged,
            ),
          );
        },
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (!_isBookPreparationTriggered) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  final textStyle = TextStyle(
                    fontSize: _fontSize,
                  ); // Simplified style for measurement
                  final singleLinePainter = TextPainter(
                    text: TextSpan(text: 'a', style: textStyle),
                    textDirection: TextDirection.ltr,
                  )..layout();
                  final singleLineHeight = singleLinePainter.height;
                  const double bottomSafetyMargin = 100.0;

                  final textRenderSize = Size(
                    constraints.maxWidth,
                    constraints.maxHeight -
                        singleLineHeight -
                        bottomSafetyMargin,
                  );
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
                  return BookReaderView(
                    state: state,
                    pageController: _pageController,
                  );
                }
                return BookStatusIndicator(state: state);
              },
            );
          },
        ),
      ),
    );
  }
}
