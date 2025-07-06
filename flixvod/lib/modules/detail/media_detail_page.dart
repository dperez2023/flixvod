import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/media.dart';
import '../../localization/localized.dart';
import '../../services/storage/firebase_service.dart';
import '../../logger.dart';
import '../player/video_player_screen.dart';
import '../common/notification_message_widget.dart';
import '../catalogue/bloc/catalogue_bloc.dart';
import '../catalogue/bloc/catalogue_event.dart';
import '../create/upload_page.dart';

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
                  image: DecorationImage(
                    image: NetworkImage(currentMedia.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => VideoPlayerScreen(media: currentMedia),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: currentMedia.isMovie ? Colors.blue : Colors.orange,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          currentMedia.isMovie ? Localized.of(context).movie : Localized.of(context).series,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Rating and year
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
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
                  
                  const SizedBox(height: 16),
                  
                  // Genres
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: currentMedia.genres.map((genre) => Chip(
                      label: Text(genre),
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    )).toList(),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Description
                  Text(
                    Localized.of(context).description,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentMedia.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.justify,
                    maxLines: 10,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _navigateToEditPage(context),
                          icon: const Icon(Icons.edit),
                          label: Text(Localized.of(context).editMedia),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showDeleteConfirmation(context),
                          icon: const Icon(Icons.delete),
                          label: Text(Localized.of(context).deleteMedia),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
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
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
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
}
