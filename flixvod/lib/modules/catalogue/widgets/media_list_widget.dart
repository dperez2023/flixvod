import 'package:flutter/material.dart';
import '../../../models/media.dart';
import 'media_card.dart';
import '../../common/section_header.dart';
import '../../../localization/localized.dart';

class MediaListWidget extends StatelessWidget {
  final List<Media> movies;
  final List<Media> series;
  final VoidCallback onRefresh;

  const MediaListWidget({
    super.key,
    required this.movies,
    required this.series,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Movies Section
        if (movies.isNotEmpty) ...[
          SectionHeader(
            title: Localized.of(context).movies,
            count: movies.length,
            icon: Icons.movie,
          ),
          const SizedBox(height: 16),
          _buildMediaSection(movies),
          const SizedBox(height: 32),
        ],
        
        // Series Section
        if (series.isNotEmpty) ...[
          SectionHeader(
            title: Localized.of(context).series,
            count: series.length,
            icon: Icons.tv,
          ),
          const SizedBox(height: 16),
          _buildMediaSection(series),
        ],
      ],
    );
  }

  Widget _buildMediaSection(List<Media> mediaList) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: mediaList.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: MediaCard(
            media: mediaList[index],
            onDeleted: onRefresh,
          ),
        );
      },
    );
  }
}
