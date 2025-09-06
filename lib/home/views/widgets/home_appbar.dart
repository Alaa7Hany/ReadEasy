import 'package:flutter/material.dart';
import 'package:read_easy/core/utils/app_colors.dart';
import 'package:read_easy/core/utils/app_text_styles.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String bookTitle;
  final Color backgroundColor;
  final int currentPage;
  final int totalPages;
  final VoidCallback onSettingsPressed;
  final void Function(int) onPageJump;

  const HomeAppBar({
    super.key,
    required this.bookTitle,
    required this.backgroundColor,
    required this.currentPage,
    required this.totalPages,
    required this.onSettingsPressed,
    required this.onPageJump,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: backgroundColor,
      title: Text(
        bookTitle,
        style: AppTextStyles.mainTextStyle(
          fontSize: 18,
        ).copyWith(color: AppColors.charcoal),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
      actions: [
        if (totalPages > 0)
          GestureDetector(
            onTap: () => _showJumpToPageDialog(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Center(
                child: Text(
                  '${currentPage + 1}/$totalPages',
                  style: AppTextStyles.mainTextStyle(
                    fontSize: 16,
                  ).copyWith(color: AppColors.charcoal),
                ),
              ),
            ),
          ),
        IconButton(
          icon: const Icon(Icons.settings, color: AppColors.charcoal),
          onPressed: onSettingsPressed,
        ),
      ],
    );
  }

  void _showJumpToPageDialog(BuildContext context) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: backgroundColor,
          title: const Text('Jump to Page'),
          content: TextField(
            controller: textController,
            keyboardType: TextInputType.number,
            cursorColor: AppColors.skyBlue,
            style: AppTextStyles.mainTextStyle(fontSize: 18),
            decoration: InputDecoration(
              hintText: 'Enter page number (1-$totalPages)',
              hintStyle: AppTextStyles.mainTextStyle(
                fontSize: 14,
              ).copyWith(color: Colors.grey),
              // focusColor: AppColors.skyBlue,
              // hoverColor: AppColors.skyBlue,
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.skyBlue),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: AppTextStyles.mainTextStyle(fontSize: 16),
              ),
            ),
            TextButton(
              onPressed: () {
                final pageNum = int.tryParse(textController.text);
                if (pageNum != null && pageNum > 0 && pageNum <= totalPages) {
                  onPageJump(pageNum - 1);
                  Navigator.pop(context);
                }
              },
              child: Text(
                'Go',
                style: AppTextStyles.mainTextStyle(fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
