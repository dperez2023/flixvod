import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/media.dart';
import '../../services/storage/firebase_service.dart';
import '../../services/video_compression_service.dart';
import '../../localization/localized.dart';
import '../common/notification_message_widget.dart';
import '../../core/app_theme.dart';

class UploadPage extends StatefulWidget {
  final Media? mediaToEdit;
  
  const UploadPage({super.key, this.mediaToEdit});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  File? _selectedVideo;
  File? _selectedThumbnail;
  MediaType _selectedType = MediaType.movie;
  final List<String> _selectedGenres = [];
  double _selectedRating = 3.0;
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  final List<File?> _episodeVideos = [null];
  final List<String> _episodeTitles = [''];


  @override
  void initState() {
    super.initState();
    if (widget.mediaToEdit != null) {
      _populateFieldsForEditing();
    }
  }

  void _populateFieldsForEditing() {
    final media = widget.mediaToEdit!;
    _titleController.text = media.title;
    _descriptionController.text = media.description;
    _selectedRating = media.rating;
    _selectedType = media.isMovie ? MediaType.movie : MediaType.series;
    _selectedGenres.clear();
    _selectedGenres.addAll(media.genres);
    
    // For series in edit mode, populate existing episodes (but don't show video files since we can't edit them)
    if (media.isSeries && media.episodes.isNotEmpty) {
      _episodeVideos.clear();
      _episodeTitles.clear();
      
      for (int i = 0; i < media.episodes.length && i < 4; i++) {
        _episodeVideos.add(null); // Don't populate actual files in edit mode
        _episodeTitles.add('Episode ${i + 1}'); // Placeholder title
      }
    }
  }

  bool get editMode => widget.mediaToEdit != null;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _addEpisode() {
    if (_episodeVideos.length < 4) { // Limit to 4 episodes
      setState(() {
        _episodeVideos.add(null);
        _episodeTitles.add('');
      });
    }
  }

  void _removeEpisode(int index) {
    if (_episodeVideos.length > 1 && index > 0) { // Keep at least one episode, can't remove first
      setState(() {
        _episodeVideos.removeAt(index);
        _episodeTitles.removeAt(index);
      });
    }
  }

  Future<void> _pickVideo() async {
    final l10n = Localized.of(context);
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
      );

      if (result != null) {
        setState(() {
          _selectedVideo = File(result.files.single.path!);
        });
      }
    } catch (e) {
      _showError(l10n.failedToPickVideo(e.toString()));
    }
  }

  Future<void> _pickThumbnail() async {
    final l10n = Localized.of(context);
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        setState(() {
          _selectedThumbnail = File(image.path);
        });
      }
    } catch (e) {
      _showError(l10n.failedToPickThumbnail(e.toString()));
    }
  }

  Future<void> _uploadMedia() async {
    if (!_formKey.currentState!.validate()) {
      _showError(Localized.of(context).fillAllRequiredFields);
      return;
    }

    // Validation logic based on media type
    if (_selectedType == MediaType.movie) {
      // For movies, check video selection
      if (!editMode && _selectedVideo == null) {
        _showError(Localized.of(context).pleaseSelectVideo);
        return;
      }
    } else {
      // For series, check episode validation
      if (!editMode) {
        // First episode is mandatory
        if (_episodeVideos.isEmpty || _episodeVideos[0] == null) {
          _showError(Localized.of(context).pleaseSelectFirstEpisode);
          return;
        }
      }
    }

    final l10n = Localized.of(context);
    final successMessage = editMode 
      ? l10n.successfullyUpdated(_titleController.text)
      : l10n.successfullyUploaded(_titleController.text);

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      if (editMode) {
        // Update existing media
        await _updateMedia();
      } else {
        // Create new media
        await _createNewMedia();
      }

      if (mounted) {
        NotificationMessageWidget.showSuccess(context, successMessage);
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      _showError(l10n.uploadFailed(e.toString()));
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<bool> _showCompressionDialog(VideoInfo videoInfo) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(Localized.of(context).videoCompression),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(Localized.of(context).videoSizeIs(videoInfo.sizeString)),
              AppTheme.smallVerticalSpacer,
              Text(Localized.of(context).compressionRecommendation),
              AppTheme.smallVerticalSpacer,
              Text(Localized.of(context).estimatedCompressedSize((VideoCompressionService.estimateCompressedSize(videoInfo, VideoQuality.medium) / 1024 / 1024).toStringAsFixed(1))),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              style: AppTheme.primaryTextButtonStyle,
              child: Text(Localized.of(context).uploadOriginal),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: AppTheme.primaryElevatedButtonStyle,
              child: Text(Localized.of(context).compressAndUpload),
            ),
          ],
        );
      },
    ) ?? false;
  }

  Future<void> _updateMedia() async {
    final media = widget.mediaToEdit!;
    
    // Update media metadata
    await FirebaseService.updateMedia(
      mediaId: media.id,
      title: _titleController.text,
      description: _descriptionController.text,
      type: _selectedType,
      genres: _selectedGenres,
      rating: _selectedRating
    );
  }

  Future<void> _createNewMedia() async {
    if (_selectedType == MediaType.movie) {
      // Handle movie upload (existing logic)
      File videoToUpload = _selectedVideo!;
      
      // Check if video needs compression
      final videoInfo = await VideoCompressionService.getVideoInfo(_selectedVideo!);
      
      if (VideoCompressionService.shouldCompress(videoInfo)) {
        // Show compression dialog
        final shouldCompress = await _showCompressionDialog(videoInfo);
        
        if (shouldCompress) {
          // Compress the video
          videoToUpload = await VideoCompressionService.compressVideo(
            inputFile: _selectedVideo!,
            quality: VideoQuality.medium,
          );
        }
      }

      await FirebaseService.uploadVideo(
        videoFile: videoToUpload,
        title: _titleController.text,
        description: _descriptionController.text,
        type: _selectedType,
        genres: _selectedGenres,
        rating: _selectedRating,
        thumbnailFile: _selectedThumbnail,
        onProgress: (progress) {
          setState(() {
            _uploadProgress = progress;
          });
        },
      );
    } else {
      // Handle series upload with episodes
      await _uploadSeries();
    }
  }

  Future<void> _uploadSeries() async {
    // Get valid episodes (non-null videos)
    List<File> validEpisodeVideos = [];
    for (int i = 0; i < _episodeVideos.length; i++) {
      if (_episodeVideos[i] != null) {
        validEpisodeVideos.add(_episodeVideos[i]!);
      }
    }

    // First episode is mandatory, so we should have at least one
    if (validEpisodeVideos.isEmpty) {
      throw Exception('At least one episode is required for series');
    }

    // Compress episodes if needed
    List<File> episodesToUpload = [];
    for (int i = 0; i < validEpisodeVideos.length; i++) {
      File episodeToUpload = validEpisodeVideos[i];
      
      final videoInfo = await VideoCompressionService.getVideoInfo(validEpisodeVideos[i]);
      
      if (VideoCompressionService.shouldCompress(videoInfo)) {
        // For series, auto-compress without asking for each episode
        episodeToUpload = await VideoCompressionService.compressVideo(
          inputFile: validEpisodeVideos[i],
          quality: VideoQuality.medium,
        );
      }
      
      episodesToUpload.add(episodeToUpload);
    }

    // Upload series with episodes
    await FirebaseService.uploadSeries(
      episodeFiles: episodesToUpload,
      title: _titleController.text,
      description: _descriptionController.text,
      genres: _selectedGenres,
      rating: _selectedRating,
      thumbnailFile: _selectedThumbnail,
      onProgress: (progress) {
        setState(() {
          _uploadProgress = progress;
        });
      },
    );
  }

  void _showError(String message) {
    NotificationMessageWidget.showError(context, message);
  }

  @override
  Widget build(BuildContext context) {    
    return Scaffold(
      appBar: AppBar(
        title: Text(editMode 
          ? Localized.of(context).editMedia 
          : Localized.of(context).uploadMedia),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          TextButton(
            onPressed: _uploadMedia,
            child: Text(editMode 
              ? Localized.of(context).update 
              : Localized.of(context).upload),
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildUploadForm(),
          if (_isUploading) _buildUploadOverlay(),
        ],
      ),
    );
  }

  Widget _buildUploadOverlay() {
    return Container(
      color: AppTheme.overlayBackgroundColor,
      child: Center(
        child: Card(
          margin: AppTheme.extraLargePadding,
          color: AppTheme.cardBackgroundColor,
          child: Padding(
            padding: AppTheme.largePadding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color: AppTheme.primaryForegroundColor,
                  value: _uploadProgress > 0 ? _uploadProgress : null,
                ),
                AppTheme.mediumVerticalSpacer,
                Text(
                  editMode 
                    ? 'Updating Media...'
                    : 'Uploading Media...',
                  style: AppTheme.primaryTextStyle.copyWith(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                AppTheme.smallVerticalSpacer,
                if (_uploadProgress > 0)
                  Text(
                    '${(_uploadProgress * 100).toStringAsFixed(0)}%',
                    style: AppTheme.primaryTextStyle.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                AppTheme.smallVerticalSpacer,
                Text(
                  "Please don't close the app while uploading",
                  style: AppTheme.mutedTextStyle,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUploadForm() {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: AppTheme.standardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Video and Thumbnail selection when in create mode
              if (!editMode) ...[
                _buildTypeSelector(),
                AppTheme.mediumVerticalSpacer,

                if (_selectedType == MediaType.series) ...[
                  _buildEpisodeManagement(),
                  AppTheme.mediumVerticalSpacer,
                ],

                if (_selectedType == MediaType.movie) ...[
                  _buildVideoSelector(),
                  AppTheme.mediumVerticalSpacer,
                ],

                _buildThumbnailSelector(),
                AppTheme.mediumVerticalSpacer,
              ],

              TextFormField(
                controller: _titleController,
                style: AppTheme.primaryTextStyle,
                decoration: InputDecoration(
                  labelText: Localized.of(context).titleLabel,
                  labelStyle: AppTheme.mutedTextStyle,
                  filled: true,
                  fillColor: AppTheme.cardBackgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.mediumBorderRadius),
                    borderSide: BorderSide(color: AppTheme.primaryBorderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.mediumBorderRadius),
                    borderSide: BorderSide(color: AppTheme.primaryBorderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.mediumBorderRadius),
                    borderSide: const BorderSide(color: AppTheme.primaryForegroundColor),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return Localized.of(context).titleRequired;
                  }
                  return null;
                },
              ),
              AppTheme.mediumVerticalSpacer,
              
              // Description TextField (Form)
              TextFormField(
                controller: _descriptionController,
                style: AppTheme.primaryTextStyle,
                decoration: InputDecoration(
                  labelText: Localized.of(context).descriptionLabel,
                  labelStyle: AppTheme.mutedTextStyle,
                  filled: true,
                  fillColor: AppTheme.cardBackgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.mediumBorderRadius),
                    borderSide: BorderSide(color: AppTheme.primaryBorderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.mediumBorderRadius),
                    borderSide: BorderSide(color: AppTheme.primaryBorderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.mediumBorderRadius),
                    borderSide: const BorderSide(color: AppTheme.primaryForegroundColor),
                  ),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return Localized.of(context).descriptionRequired;
                  }
                  return null;
                },
              ),
              AppTheme.mediumVerticalSpacer,

              _buildStarRating(),
              AppTheme.mediumVerticalSpacer,
              _buildGenreSelector(),
              AppTheme.mediumVerticalSpacer,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoSelector() {
    return Builder(
      builder: (context) {
        return Card(
          child: ListTile(
            leading: const Icon(Icons.video_library),
            title: Text(Localized.of(context).selectVideo),
            subtitle: _selectedVideo != null
                ? Text(_selectedVideo!.path.split('/').last)
                : Text(Localized.of(context).noVideoSelected),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: _pickVideo,
          ),
        );
      },
    );
  }

  Widget _buildThumbnailSelector() {
    return Builder(
      builder: (context) {
        return Card(
          child: ListTile(
            leading: const Icon(Icons.image),
            title: Text(Localized.of(context).selectThumbnail),
            subtitle: _selectedThumbnail != null
                ? Text(_selectedThumbnail!.path.split('/').last)
                : Text(Localized.of(context).noThumbnailSelected),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: _pickThumbnail,
          ),
        );
      },
    );
  }

  Widget _buildTypeSelector() {
    return Builder(
      builder: (context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              Localized.of(context).mediaTypeLabel,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Row(
              children: [
                Radio<MediaType>(
                  value: MediaType.movie,
                  groupValue: _selectedType,
                  onChanged: (MediaType? value) {
                    setState(() {
                      _selectedType = value!;
                    });
                  },
                ),
                Text(Localized.of(context).movie),
                Radio<MediaType>(
                  value: MediaType.series,
                  groupValue: _selectedType,
                  onChanged: (MediaType? value) {
                    setState(() {
                      _selectedType = value!;
                    });
                  },
                ),
                Text(Localized.of(context).series),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildEpisodeManagement() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Localized.of(context).episodeManagement,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        AppTheme.smallVerticalSpacer,
        ..._episodeVideos.asMap().entries.map((entry) {
          final index = entry.key;
          final videoFile = entry.value;
          
          return Card(
            margin: const EdgeInsets.only(bottom: AppTheme.smallVerticalSpacerHeight),
            child: Padding(
              padding: AppTheme.standardPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Episode ${index + 1}${index == 0 ? ' (Required)' : ' (Optional)'}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  AppTheme.smallVerticalSpacer,
                  ListTile(
                    leading: const Icon(Icons.video_library),
                    title: Text(Localized.of(context).selectEpisodeVideo),
                    subtitle: videoFile != null
                        ? Text(videoFile.path.split('/').last)
                        : Text(Localized.of(context).noVideoSelected),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _pickEpisodeVideo(index),
                  ),
                  if (index > 0 && videoFile != null) ...[
                    AppTheme.smallVerticalSpacer,
                    TextButton.icon(
                      onPressed: () => _removeEpisode(index),
                      icon: const Icon(Icons.remove),
                      label: Text(Localized.of(context).removeEpisode),
                      style: AppTheme.errorTextButtonStyle,
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
        Card(
          child: ListTile(
            leading: const Icon(Icons.add),
            title: Text(_episodeVideos.length < 4 
                ? Localized.of(context).addEpisode 
                : 'Maximum 4 episodes'),
            trailing: _episodeVideos.length < 4 
                ? const Icon(Icons.arrow_forward_ios)
                : null,
            onTap: _episodeVideos.length < 4 ? _addEpisode : null,
            enabled: _episodeVideos.length < 4,
          ),
        ),
        AppTheme.mediumVerticalSpacer,
      ],
    );
  }

  Widget _buildGenreSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Localized.of(context).genresLabel,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        AppTheme.smallVerticalSpacer,
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: FirebaseService.availableGenres.map((genre) {
            final isSelected = _selectedGenres.contains(genre);
            return FilterChip(
              label: Text(genre),
              selected: isSelected,
              onSelected: (bool selected) {
                setState(() {
                  if (selected) {
                    _selectedGenres.add(genre);
                  } else {
                    _selectedGenres.remove(genre);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStarRating() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Localized.of(context).ratingLabel,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        AppTheme.smallVerticalSpacer,
        Row(
          children: List.generate(5, (index) {
            final starValue = index + 1.0;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedRating = starValue;
                });
              },
              child: Icon(
                Icons.star,
                size: 32,
                color: starValue <= _selectedRating 
                  ? AppTheme.starColor 
                  : AppTheme.inactiveRatingColor,
              ),
            );
          }),
        ),
        AppTheme.tinyVerticalSpacer,
        Text(
          '${_selectedRating.toStringAsFixed(1)} / 5.0',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.mutedForegroundColor,
          ),
        ),
        AppTheme.mediumVerticalSpacer,
      ],
    );
  }

  Future<void> _pickEpisodeVideo(int episodeIndex) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _episodeVideos[episodeIndex] = File(result.files.single.path!);
        });
      }
    } catch (e) {
      if (mounted) {
        NotificationMessageWidget.showError(
          context,
          Localized.of(context).failedToPickVideo(e.toString()),
        );
      }
    }
  }
}
