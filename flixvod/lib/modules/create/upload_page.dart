import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/media.dart';
import '../../services/storage/firebase_service.dart';
import '../../services/video_compression_service.dart';
import '../../localization/localized.dart';
import '../common/notification_message_widget.dart';

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

  final List<String> _availableGenres = [
    'Action', 'Adventure', 'Comedy', 'Drama', 'Horror', 'Romance', 
    'Sci-Fi', 'Thriller', 'Documentary', 'Animation', 'Fantasy', 'Mystery'
  ];

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
  }

  bool get editMode => widget.mediaToEdit != null;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
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
      _showError(Localized.of(context).failedToPickVideo(e.toString()));
    }
  }

  Future<void> _pickThumbnail() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        setState(() {
          _selectedThumbnail = File(image.path);
        });
      }
    } catch (e) {
      _showError(Localized.of(context).failedToPickThumbnail(e.toString()));
    }
  }

  Future<void> _uploadMedia() async {
    if (!_formKey.currentState!.validate()) {
      _showError(Localized.of(context).fillAllRequiredFields);
      return;
    }

    // For editing, video is optional; for new upload, it's required
    if (!editMode && _selectedVideo == null) {
      _showError(Localized.of(context).pleaseSelectVideo);
      return;
    }

    setState(() {
      _isUploading = true;
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
        final message = editMode 
          ? Localized.of(context).successfullyUpdated(_titleController.text)
          : Localized.of(context).successfullyUploaded(_titleController.text);
        
        NotificationMessageWidget.showSuccess(context, message);
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      _showError(Localized.of(context).uploadFailed(e.toString()));
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
              const SizedBox(height: 8),
              Text(Localized.of(context).compressionRecommendation),
              const SizedBox(height: 8),
              Text(Localized.of(context).estimatedCompressedSize((VideoCompressionService.estimateCompressedSize(videoInfo, VideoQuality.medium) / 1024 / 1024).toStringAsFixed(1))),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(Localized.of(context).uploadOriginal),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
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
          if (!_isUploading)
            TextButton(
              onPressed: _uploadMedia,
              child: Text(editMode 
                ? Localized.of(context).update 
                : Localized.of(context).upload),
            ),
        ],
      ),
      body: _isUploading
          ? _buildUploadProgress()
          : _buildUploadForm(),
    );
  }

  Widget _buildUploadProgress() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Uploading...',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Video and Thumbnail selection when in create mode
              if (!editMode) ...[
                _buildTypeSelector(),
                const SizedBox(height: 16),
                _buildVideoSelector(),
                const SizedBox(height: 16),
                _buildThumbnailSelector(),
                const SizedBox(height: 16),
              ],

              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: Localized.of(context).titleLabel,
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return Localized.of(context).titleRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Description TextField (Form)
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: Localized.of(context).descriptionLabel,
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return Localized.of(context).descriptionRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              _buildGenreSelector(),
              const SizedBox(height: 16),

              _buildStarRating(),
              const SizedBox(height: 16),
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

  Widget _buildGenreSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          Localized.of(context).genresLabel,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: _availableGenres.map((genre) {
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
        const SizedBox(height: 8),
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
                  ? Colors.amber 
                  : Colors.grey[300],
              ),
            );
          }),
        ),
        const SizedBox(height: 4),
        Text(
          '${_selectedRating.toStringAsFixed(1)} / 5.0',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
