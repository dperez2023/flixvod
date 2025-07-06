import 'package:flutter/material.dart';
import '../../../models/media.dart';
import 'media_card.dart';
import '../../common/section_header.dart';
import '../../../localization/localized.dart';
import '../../../core/app_theme.dart';

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
        padding: AppTheme.standardPadding,
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
