import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/media.dart';
import '../../localization/localized.dart';
import '../player/video_player_screen.dart';
import '../catalogue/bloc/catalogue_bloc.dart';
import '../catalogue/bloc/catalogue_event.dart';
import '../create/upload_page.dart';
import '../../core/app_theme.dart';
import '../../core/app_icons.dart';
import '../../utils/logger.dart';
import 'bloc/media_detail_bloc.dart';
import 'bloc/media_detail_event.dart';
import 'bloc/media_detail_state.dart';

class MediaDetailPage extends StatelessWidget {
  final Media media;

  const MediaDetailPage({
    super.key,
    required this.media,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MediaDetailBloc()..add(LoadMediaDetailEvent(media.id)),
      child: BlocConsumer<MediaDetailBloc, MediaDetailState>(
        listener: (context, state) {
          // Handle navigation when navigation action is triggered
          if (state.navigationAction == NavigationAction.navigateToVideoPlayer) {
            if (state.navigationMedia != null) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => VideoPlayerScreen(
                    media: state.navigationMedia!,
                  ),
                ),
              ).then((_) {
                // Clear navigation action after returning from video player
                if (context.mounted) {
                  context.read<MediaDetailBloc>().add(const ClearNavigationEvent());
                }
              });
            }
          }

          if (state.status == MediaDetailStatus.error && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
          }
          if (state.status == MediaDetailStatus.deleted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(Localized.of(context).delete),
                backgroundColor: Colors.green,
              ),
            );

            try {
              final catalogueBloc = context.read<CatalogueBloc>();
              catalogueBloc.add(RefreshCatalogue());
            } catch (e, s) {
              FlixLogger.instance.e('CatalogueBloc not available for refresh', s);
            }
          }
        },
        builder: (context, state) {
          // Show loading state
          if (state.status == MediaDetailStatus.loading || state.media == null) {
            return Scaffold(
              appBar: AppBar(),
              body: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          // Show error state
          if (state.status == MediaDetailStatus.error) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Error'),
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state.errorMessage ?? 'An error occurred',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<MediaDetailBloc>().add(LoadMediaDetailEvent(media.id));
                      },
                      child: Text(Localized.of(context).retry),
                    ),
                  ],
                ),
              ),
            );
          }

          final currentMedia = state.media ?? media;
          return _buildMediaDetailContent(context, state, currentMedia);
        },
      ),
    );
  }

  Widget _buildMediaDetailContent(BuildContext context, MediaDetailState state, Media currentMedia) {
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

                    // Play button for movies
                    if (currentMedia.isMovie) 
                      Center(
                        child: Container(
                          width: AppTheme.largePlayButtonSize,
                          height: AppTheme.largePlayButtonSize,
                          decoration: AppTheme.createPlayButtonDecoration(),
                          child: IconButton(
                            onPressed: () {
                              context.read<MediaDetailBloc>().add(
                                PlayVideoEvent(currentMedia),
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
                      else
                        Text(
                          '${currentMedia.totalEpisodes} ${Localized.of(context).episodes}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                    ],
                  ),
                  
                  AppTheme.mediumVerticalSpacer,
                  
                  // Genres
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: currentMedia.genres.map((genre) => Chip(
                      label: Text(
                        genre,
                        style: AppTheme.primaryTextStyle.copyWith(fontSize: 12),
                      ),
                      backgroundColor: AppTheme.overlayBackgroundColor,
                    )).toList(),
                  ),
                  
                  AppTheme.largeVerticalSpacer,
                  
                  // Description
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
                    AppTheme.mediumVerticalSpacer,
                    _buildEpisodesList(context, currentMedia),
                  ],
                  
                  AppTheme.extraLargeVerticalSpacer,
                  _buildActionButtons(context, state, currentMedia),
                  
                  AppTheme.extraLargeVerticalSpacer,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEpisodesList(BuildContext context, Media currentMedia) {
    return Column(
      children: currentMedia.episodes.map((episode) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                '${episode.episodeNumber}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              'Episode ${episode.episodeNumber}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: IconButton(
              icon: AppIcons.play,
              onPressed: () {
                context.read<MediaDetailBloc>().add(
                  PlayVideoEvent(currentMedia, episodeNumber: episode.episodeNumber),
                );
              },
            ),
            onTap: () {
              context.read<MediaDetailBloc>().add(
                PlayVideoEvent(currentMedia, episodeNumber: episode.episodeNumber),
              );
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionButtons(BuildContext context, MediaDetailState state, Media currentMedia) {
    return Column(
      children: [        
        AppTheme.mediumVerticalSpacer,
        // Edit and Delete buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _navigateToEditPage(context, currentMedia),
                icon: AppIcons.edit,
                label: Text(Localized.of(context).editMedia),
              ),
            ),
            AppTheme.mediumHorizontalSpacer,
            Expanded(
              child: OutlinedButton.icon(
                onPressed: state.isDeleting ? null : () => _showDeleteConfirmation(context, currentMedia),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
                icon: state.isDeleting 
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : AppIcons.delete,
                label: Text(Localized.of(context).delete),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _navigateToEditPage(BuildContext context, Media currentMedia) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => UploadPage(mediaToEdit: currentMedia),
      ),
    ).then((_) {
      // Refresh media detail after edit
      if (context.mounted) {
        context.read<MediaDetailBloc>().add(RefreshMediaDetailEvent(currentMedia.id));
      }
    });
  }

  void _showDeleteConfirmation(BuildContext context, Media currentMedia) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(Localized.of(context).deleteMedia),
        content: Text(Localized.of(context).deleteConfirmation(currentMedia.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(Localized.of(context).cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<MediaDetailBloc>().add(DeleteMediaEvent(currentMedia.id));
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text(Localized.of(context).delete),
          ),
        ],
      ),
    );
  }
}
