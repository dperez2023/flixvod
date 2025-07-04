import 'package:flutter/material.dart';
import '../../../localization/localized.dart';
import 'search_bar_widget.dart';
import 'filter_chips_widget.dart';

class CatalogueAppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onRefresh;
  final VoidCallback onUpload;

  const CatalogueAppBarWidget({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.onRefresh,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(Localized.of(context).catalogue),
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      actions: [
        IconButton(
          onPressed: onRefresh,
          icon: const Icon(Icons.refresh),
          tooltip: Localized.of(context).refresh,
        ),
        IconButton(
          onPressed: onUpload,
          icon: const Icon(Icons.add),
          tooltip: Localized.of(context).uploadMedia,
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: Column(
          children: [
            // Search Bar
            SearchBarWidget(
              controller: searchController,
              onChanged: onSearchChanged,
              hintText: Localized.of(context).searchMoviesAndSeries,
            ),
            // Filter Chips
            const FilterChipsWidget(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 120);
}
