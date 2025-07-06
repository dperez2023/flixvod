import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/media.dart';
import '../../localization/localized.dart';
import '../../services/storage/firebase_service.dart';
import '../../utils/logger.dart';
import '../player/video_player_screen.dart';
import '../common/notification_message_widget.dart';
import '../catalogue/bloc/catalogue_bloc.dart';
import '../catalogue/bloc/catalogue_event.dart';
import '../create/upload_page.dart';
import '../../core/app_theme.dart';
import '../../core/app_icons.dart';

class MediaDetailPage extends StatefulWidget {
  final Media media;

  const MediaDetailPage({
    super.key,
    required this.media,
  });

  @override
  State<MediaDetailPage> createState() => _MediaDetailPageState();
}

class _MediaDetailPageState extends State<MediaDetailPage> {
  late Media currentMedia;

  @override
  void initState() {
    super.initState();
    currentMedia = widget.media;
  }

  @override
  Widget build(BuildContext context) {    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with media image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  image: currentMedia.hasValidImageUrl 
                    ? DecorationImage(
                        image: NetworkImage(currentMedia.imageUrl),
                        fit: BoxFit.cover,
                        onError: (exception, stackTrace) {
                          // Handle image loading errors
                          debugPrint('Error loading image: $exception');
                        },
                      )
                    : null,
                  color: currentMedia.hasValidImageUrl ? null : AppTheme.cardBackgroundColor,
                ),
                child: Stack(
                  children: [
                    // Show placeholder when no image URL
                    if (!currentMedia.hasValidImageUrl)
                      Container(
                        decoration: AppTheme.createGradientOverlayDecoration(),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AppIcons.videoLibraryMedium,
                              AppTheme.smallVerticalSpacer,
                              Text(
                                'No Image Available',
                                style: AppTheme.whiteTextStyle,
                              ),
                            ],
                          ),
                        ),
                      ),
                    // Gradient overlay
                    Container(
                      decoration: AppTheme.createGradientOverlayDecoration(),
                    ),

                    if (currentMedia.isMovie) 
                      Center(
                        child: Container(
                          width: AppTheme.largePlayButtonSize,
                          height: AppTheme.largePlayButtonSize,
                          decoration: AppTheme.createPlayButtonDecoration(),
                          child: IconButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => VideoPlayerScreen(media: currentMedia),
                                ),
                              );
                            },
                            icon: AppIcons.playCard,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: AppTheme.standardPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and type badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          currentMedia.title,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: AppTheme.largeBadgePadding,
                        decoration: AppTheme.createLargeBadgeDecoration(
                          AppTheme.getMediaTypeColor(currentMedia.isMovie),
                        ),
                        child: Text(
                          currentMedia.isMovie ? Localized.of(context).movie : Localized.of(context).series,
                          style: AppTheme.mediaTypeBadgeStyle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  
                  AppTheme.mediumVerticalSpacer,
                  
                  // Rating and year
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppIcons.starFilled,
                          AppTheme.smallHorizontalSpacer,
                          Text(
                            currentMedia.rating.toString(),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        currentMedia.year.toString(),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (currentMedia.isMovie)
                        Text(
                          '${currentMedia.duration} ${Localized.of(context).min}',
                          style: Theme.of(context).textTheme.titleMedium,
                        )
                      else ...[
                        Text(
                          '${currentMedia.seasons} ${Localized.of(context).seasons}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          '${currentMedia.totalEpisodes} ${Localized.of(context).episodes}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ],
                  ),
                  
                  AppTheme.mediumVerticalSpacer,
                  
                  // Genres
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: currentMedia.genres.map((genre) => Chip(
                      label: Text(genre),
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    )).toList(),
                  ),
                  
                  AppTheme.largeVerticalSpacer,
                  
                  // Description
                  Text(
                    Localized.of(context).description,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  AppTheme.smallVerticalSpacer,
                  Text(
                    currentMedia.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.justify,
                    maxLines: 10,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  AppTheme.extraLargeVerticalSpacer,
                  
                  // Episodes section (only for series)
                  if (currentMedia.isSeries && currentMedia.episodes.isNotEmpty) ...[
                    Text(
                      Localized.of(context).episodes,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    AppTheme.mediumVerticalSpacer,
                    _buildEpisodesSection(),
                    AppTheme.extraLargeVerticalSpacer,
                  ],
                  
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _navigateToEditPage(context),
                          icon: AppIcons.edit,
                          label: Text(Localized.of(context).editMedia),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: AppTheme.secondaryForegroundColor,
                            padding: AppTheme.buttonPadding,
                          ),
                        ),
                      ),
                      AppTheme.extraLargeHorizontalSpacer,
                      
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showDeleteConfirmation(context),
                          icon: AppIcons.delete,
                          label: Text(Localized.of(context).deleteMedia),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.errorColor,
                            foregroundColor: AppTheme.secondaryForegroundColor,
                            padding: AppTheme.buttonPadding,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  AppTheme.extraLargeVerticalSpacer,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Shows a confirmation dialog before deleting the media
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(Localized.of(context).deleteMedia),
          content: Text(
            Localized.of(context).deleteConfirmation(currentMedia.title),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(Localized.of(context).cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _deleteMedia(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorColor,
                foregroundColor: AppTheme.whiteForegroundColor,
              ),
              child: Text(Localized.of(context).delete),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteMedia(BuildContext context) async {
    final catalogueBloc = context.read<CatalogueBloc>();
    final successMessage = Localized.of(context).deleted(currentMedia.title);
    final l10n = Localized.of(context);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Delete media from Firebase
      await FirebaseService.deleteMedia(currentMedia.id);
      
      // Verify deletion
      final stillExists = await FirebaseService.mediaExists(currentMedia.id);
      if (stillExists) {
        logger.w('Media still exists after deletion attempt');
      }
      
      // Close loading dialog
      if (context.mounted) Navigator.of(context).pop();
      
      // Refresh catalogue with catalogueBloc
      catalogueBloc.add(RefreshCatalogue());
      
      // Show success message using pre-captured string
      if (context.mounted) {
        NotificationMessageWidget.showSuccess(
          context,
          successMessage,
        );
      }
      
      // Navigate back to catalogue
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      logger.e('Delete error: $e');
      
      // Close loading dialog
      if (context.mounted) Navigator.of(context).pop();
      
      // Show error message
      if (context.mounted) {
        NotificationMessageWidget.showError(
          context,
          l10n.failedToDelete(e.toString()),
        );
      }
    }
  }

  void _navigateToEditPage(BuildContext context) async {
    final catalogueBloc = context.read<CatalogueBloc>();
    
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: catalogueBloc,
          child: UploadPage(mediaToEdit: currentMedia),
        ),
      ),
    );
    
    if (result == true && context.mounted) {
      // Use the captured bloc reference instead of accessing context again
      catalogueBloc.add(RefreshCatalogue());
      
      // Reload the current media data to show updated values
      await _reloadMediaData();
      
    }
  }

  /// Reloads the media data from Firebase to show updated values
  Future<void> _reloadMediaData() async {
    try {
      final updatedMedia = await FirebaseService.getMediaById(currentMedia.id);
      if (updatedMedia != null && mounted) {
        setState(() {
          currentMedia = updatedMedia;
        });
        logger.i('✅ Media data reloaded successfully');
      }
    } catch (e) {
      logger.e('Failed to reload media data: $e');
      // The old data is still displayed (But failed)
    }
  }

  Widget _buildEpisodesSection() {
    return Column(
      children: currentMedia.episodes.asMap().entries.map((entry) {
        final index = entry.key;
        final episode = entry.value;
        final isFirst = index == 0;
        
        return Card(
          margin: const EdgeInsets.only(bottom: AppTheme.smallVerticalSpacerHeight),
          child: ExpansionTile(
            //First episode is expanded by default whereas others are collapsed
            initiallyExpanded: isFirst,
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  episode.episodeNumber.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            title: Text(
              'Episode ${episode.episodeNumber}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            children: [
              Padding(
                padding: AppTheme.standardPadding,
                child: Column(
                  children: [
                    // Episode thumbnail (using same image as series)
                    Container(
                      width: double.infinity,
                      height: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: currentMedia.hasValidImageUrl 
                          ? DecorationImage(
                              image: NetworkImage(currentMedia.imageUrl),
                              fit: BoxFit.cover,
                              onError: (exception, stackTrace) {
                                debugPrint('Error loading episode image: $exception');
                              },
                            )
                          : null,
                        color: currentMedia.hasValidImageUrl ? null : AppTheme.cardBackgroundColor,
                      ),
                      child: Stack(
                        children: [
                          if (!currentMedia.hasValidImageUrl)
                            const Center(
                              child: AppIcons.videoLibraryMedium,
                            ),
                          // Dark overlay
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.black.withOpacity(0.3),
                            ),
                          ),
                          // Play button
                          Center(
                            child: GestureDetector(
                              onTap: () => _playEpisode(episode.episodeNumber),
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.play_arrow,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                            ),
                          ),
                          // Episode number overlay
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: AppTheme.badgePadding,
                              decoration: AppTheme.createBadgeDecoration(AppTheme.ratingBadgeColor),
                              child: Text(
                                'EP ${episode.episodeNumber}',
                                style: AppTheme.episodeBadgeTextStyle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppTheme.mediumVerticalSpacer,
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _playEpisode(int episodeNumber) {
    // Media copy to navigate (original stays the same)
    final episodeMedia = Media(
      id: currentMedia.id,
      title: '${currentMedia.title} - Episode $episodeNumber',
      description: currentMedia.description,
      imageUrl: currentMedia.imageUrl,
      type: currentMedia.type,
      year: currentMedia.year,
      rating: currentMedia.rating,
      genres: currentMedia.genres,
      seasons: currentMedia.seasons,
      totalEpisodes: currentMedia.totalEpisodes,
      duration: currentMedia.duration,
      videoUrl: currentMedia.getVideoUrl(episodeNumber),
      episodes: currentMedia.episodes,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(media: episodeMedia),
      ),
    );
  }
}
