import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/media.dart';
import '../../detail/media_detail_page.dart';
import '../../player/video_player_screen.dart';
import '../../../services/storage/firebase_service.dart';
import '../../../localization/localized.dart';
import '../../common/notification_message_widget.dart';
import '../bloc/catalogue_bloc.dart';

class MediaCard extends StatelessWidget {
  final Media media;
  final VoidCallback? onDeleted;

  const MediaCard({
    super.key,
    required this.media,
    this.onDeleted,
  });

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(Localized.of(context).deleteMedia),
          content: Text(Localized.of(context).deleteConfirmation(media.title)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(Localized.of(context).cancel),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteMedia(context);
              },
              child: Text(Localized.of(context).delete, style: const TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteMedia(BuildContext context) async {
    try {
      await FirebaseService.deleteMedia(media.id);

      //TODO: Change with better UI
      NotificationMessageWidget.showSuccess(
        context, 
        Localized.of(context).deleted(media.title),
      );

      onDeleted?.call();
    } catch (e) {
      NotificationMessageWidget.showError(
        context,
        Localized.of(context).failedToDelete(e.toString()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          final catalogueBloc = context.read<CatalogueBloc>();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => BlocProvider.value(
                value: catalogueBloc,
                child: MediaDetailPage(media: media),
              ),
            ),
          );
        },
        onLongPress: onDeleted != null ? () => _showDeleteDialog(context) : null,
        child: SizedBox(
          height: 150,
          child: Row(
            children: [
              // Media Image
              Container(
                width: 100,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  image: DecorationImage(
                    image: NetworkImage(media.imageUrl),
                    fit: BoxFit.cover,
                    onError: (error, stackTrace) {
                      // Handle image loading error
                    },
                  ),
                ),
                child: Stack(
                  children: [
                    // Type Badge
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: media.isMovie ? Colors.blue : Colors.orange,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          media.isMovie ? Localized.of(context).movie : Localized.of(context).series,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    // Play Button Overlay
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => VideoPlayerScreen(media: media),
                            ),
                          );
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Media Info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and Rating
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              media.title,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 12,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  media.rating.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Year and Duration/Episodes
                      Text(
                        media.isMovie
                            ? '${media.year} • ${media.duration}min'
                            : '${media.year} • ${media.seasons} seasons',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Description
                      Expanded(
                        child: Text(
                          media.description,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Genres
                      Text(
                        media.genres.take(3).join(' • '),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
