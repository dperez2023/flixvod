import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../localization/localized.dart';
import '../../../models/media.dart';
import '../bloc/catalogue_bloc.dart';
import '../bloc/catalogue_state.dart';
import '../bloc/catalogue_event.dart';
import 'search_bar_widget.dart';
import 'filter_chips_widget.dart';
import '../../../core/app_theme.dart';
import '../../../core/app_icons.dart';

class CatalogueAppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onUpload;

  const CatalogueAppBarWidget({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(Localized.of(context).catalogue),
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      actions: [
        IconButton(
          onPressed: onUpload,
          icon: AppIcons.add,
          tooltip: Localized.of(context).uploadMedia,
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(160),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Search Bar
            SearchBarWidget(
              controller: searchController,
              onChanged: onSearchChanged,
            ),
            AppTheme.smallVerticalSpacer,
            // Filter Chips for Media Types
            BlocBuilder<CatalogueBloc, CatalogueState>(
              builder: (context, state) {
                // Extract available media types from all media
                final availableTypes = state.allMedia
                    .map((media) => media.type)
                    .toSet()
                    .toList();

                return FilterChipsWidget<MediaType>(
                  availableOptions: availableTypes,
                  selectedOption: state.selectedFilter,
                  onFilterChanged: (type) {
                    context.read<CatalogueBloc>().add(FilterByType(type));
                  },
                  getOptionLabel: (context, type) {
                    switch (type) {
                      case MediaType.movie:
                        return Localized.of(context).movies;
                      case MediaType.series:
                        return Localized.of(context).series;
                    }
                  },
                  allLabel: Localized.of(context).all,
                );
              },
            ),
            AppTheme.tinyVerticalSpacer,
            // Filter Chips for Genres
            BlocBuilder<CatalogueBloc, CatalogueState>(
              builder: (context, state) {
                // Extract available genres from all media
                final availableGenres = state.allMedia
                    .expand((media) => media.genres)
                    .toSet()
                    .toList()
                    ..sort(); // Sort alphabetically

                return FilterChipsWidget<String>(
                  availableOptions: availableGenres,
                  selectedOption: state.selectedGenre,
                  onFilterChanged: (genre) {
                    context.read<CatalogueBloc>().add(FilterByGenre(genre));
                  },
                  getOptionLabel: (context, genre) => genre,
                  allLabel: Localized.of(context).allGenres,
                );
              },
            ),
            AppTheme.specialVerticalSpacer,
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 160);
}
