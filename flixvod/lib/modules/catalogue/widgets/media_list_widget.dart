import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/media.dart';
import 'media_card.dart';
import '../../common/section_header.dart';
import '../../../localization/localized.dart';
import '../../../core/app_theme.dart';
import '../bloc/catalogue_bloc.dart';
import '../bloc/catalogue_state.dart';
import '../bloc/catalogue_event.dart';
import 'filter_chips_widget.dart';
import '../../../services/storage/firebase_service.dart';

class MediaListWidget extends StatelessWidget {
  final List<Media> movies;
  final List<Media> series;
  final Future<void> Function() onRefresh;

  const MediaListWidget({
    super.key,
    required this.movies,
    required this.series,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Filter Chips Section
          Container(
            width: double.infinity,
            color: AppTheme.primaryBackgroundColor,
            padding: const EdgeInsets.only(top: AppTheme.smallVerticalSpacerHeight),
            child: Column(
              children: [
                // Filter Chips for Media Types
                BlocBuilder<CatalogueBloc, CatalogueState>(
                  builder: (context, state) {
                    //TODO: Move this to FIR as genre values
                    const availableTypes = [MediaType.movie, MediaType.series];

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
                    return FilterChipsWidget<String>(
                      availableOptions: FirebaseService.availableGenres,
                      selectedOption: state.selectedGenre,
                      onFilterChanged: (genre) {
                        context.read<CatalogueBloc>().add(FilterByGenre(genre));
                      },
                      getOptionLabel: (context, genre) => genre,
                      allLabel: Localized.of(context).allGenres,
                    );
                  },
                ),
                AppTheme.mediumVerticalSpacer,
              ],
            ),
          ),
          
          // Media content with padding
          Padding(
            padding: AppTheme.standardPadding,
            child: Column(
              children: [
                // Movies Section
                if (movies.isNotEmpty) ...[
                  SectionHeader(
                    title: Localized.of(context).movies,
                    count: movies.length,
                    icon: Icons.movie,
                  ),
                  AppTheme.mediumVerticalSpacer,
                  _buildMediaSection(movies),
                  AppTheme.extraLargeVerticalSpacer,
                ],
                
                // Series Section
                if (series.isNotEmpty) ...[
                  SectionHeader(
                    title: Localized.of(context).series,
                    count: series.length,
                    icon: Icons.tv,
                  ),
                  AppTheme.mediumVerticalSpacer,
                  _buildMediaSection(series),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaSection(List<Media> mediaList) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: mediaList.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppTheme.mediumVerticalSpacerHeight),
          child: MediaCard(
            media: mediaList[index],
            onDeleted: () async {
              await onRefresh();
            },
          ),
        );
      },
    );
  }
}
