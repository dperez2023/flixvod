import 'package:flutter/material.dart';
import '../../../models/media.dart';
import 'media_list_widget.dart';

class FilteredMediaListWidget extends StatelessWidget {
  final List<Media> movies;
  final List<Media> series;
  final Future<void> Function() onRefresh;

  const FilteredMediaListWidget({
    super.key,
    required this.movies,
    required this.series,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    // Filters are now part of the scrollable MediaListWidget
    return MediaListWidget(
      movies: movies,
      series: series,
      onRefresh: onRefresh,
    );
  }
}
