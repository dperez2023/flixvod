import 'package:flutter/material.dart';
import '../../../localization/localized.dart';
import 'search_bar_widget.dart';
import '../../../core/app_theme.dart';
import '../../../core/app_icons.dart';

class CatalogueAppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onUpload;
  final FocusNode? searchFocusNode;

  const CatalogueAppBarWidget({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.onUpload,
    this.searchFocusNode,
  });  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        Localized.of(context).appTitle,
      ),
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      foregroundColor: AppTheme.primaryForegroundColor,
      actions: [
        IconButton(
          onPressed: onUpload,
          icon: AppIcons.add,
          tooltip: Localized.of(context).uploadMedia,
          color: AppTheme.primaryForegroundColor,
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Search Bar
            SearchBarWidget(
              controller: searchController,
              onChanged: onSearchChanged,
              focusNode: searchFocusNode,
            ),
            AppTheme.smallVerticalSpacer,
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 80);
}
