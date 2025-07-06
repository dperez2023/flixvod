import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/media.dart';
import '../../detail/media_detail_page.dart';
import '../../player/video_player_screen.dart';
import '../../../services/storage/firebase_service.dart';
import '../../../localization/localized.dart';
import '../../common/notification_message_widget.dart';
import '../bloc/catalogue_bloc.dart';
import '../../../core/app_theme.dart';
import '../../../core/app_icons.dart';

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
              child: Text(Localized.of(context).delete, style: AppTheme.errorTextStyle),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteMedia(BuildContext context) async {
    final l10n = Localized.of(context);
    final successMessage = l10n.deleted(media.title);
    
    try {
      await FirebaseService.deleteMedia(media.id);
      if (context.mounted) {
        NotificationMessageWidget.showSuccess(
          context, 
          successMessage,
        );
      }

      onDeleted?.call();
    } catch (e) {
      if (context.mounted) {
        NotificationMessageWidget.showError(
          context,
          l10n.failedToDelete(e.toString()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.largeBorderRadius),
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
                decoration: AppTheme.createCardDecoration().copyWith(
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
                        padding: AppTheme.badgePadding,
                        decoration: AppTheme.createBadgeDecoration(
                          AppTheme.getMediaTypeColor(media.isMovie),
                        ),
                        child: Text(
                          media.isMovie ? Localized.of(context).movie : Localized.of(context).series,
                          style: AppTheme.badgeTextStyle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    if (media.isMovie)
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
                            width: AppTheme.playButtonSize,
                            height: AppTheme.playButtonSize,
                            decoration: AppTheme.createPlayButtonDecoration(),
                            child: AppIcons.playCard,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Media Info
              Expanded(
                child: Padding(
                  padding: AppTheme.standardPadding,
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
                          AppTheme.mediumHorizontalSpacer,
                          Container(
                            padding: AppTheme.badgePadding,
                            decoration: AppTheme.createBadgeDecoration(AppTheme.ratingBadgeColor),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star,
                                  color: AppTheme.starColor,
                                  size: AppTheme.smallIconSize,
                                ),
                                AppTheme.tinyHorizontalSpacer,
                                Text(
                                  media.rating.toString(),
                                  style: AppTheme.ratingBadgeTextStyle,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      AppTheme.smallVerticalSpacer,
                      // Year and Duration/Episodes
                      Text(
                        media.isMovie
                            ? '${media.year} • ${media.duration}min'
                            : media.episodeCount > 0
                                ? '${media.year} • ${media.episodeCount} episodes'
                                : '${media.year} • ${media.seasons} seasons',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.mutedForegroundColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      AppTheme.smallVerticalSpacer,
                      // Description
                      Expanded(
                        child: Text(
                          media.description,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      AppTheme.smallVerticalSpacer,
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
