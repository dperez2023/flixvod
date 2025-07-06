import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flixvod/utils/logger.dart';
import '../../models/media.dart';
import '../../utils/video_duration_utils.dart';
import '../cache_service.dart';

class FirebaseService {
  static FirebaseStorage get _storage => FirebaseStorage.instance;
  static FirebaseAuth get _auth => FirebaseAuth.instance;
  static FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  static User? get currentUser => _auth.currentUser;

  static Future<void> signOut() async {
    await _auth.signOut();
  }

  static Future<void> initialize() async {
    try {
      if (_auth.currentUser == null) {
        await _auth.signInAnonymously(); //FIR Auth to allow anonymous access
      }
    } catch (e, s) {
      logger.e('❌ Firebase service initialization failed: $e', s);
      rethrow;
    }
  }

  static Future<Media> uploadVideo({
    required File videoFile,
    required String title,
    required String description,
    required MediaType type,
    required List<String> genres,
    required double rating,
    File? thumbnailFile,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final videoId = DateTime.now().millisecondsSinceEpoch.toString();

      //TODO: Missing video is actually mp4
      final fileName = '$videoId.mp4';
      
      // Upload video to Storage
      final videoRef = _storage.ref().child('videos/$fileName');
      final uploadTask = videoRef.putFile(videoFile);
      
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        double progress = snapshot.bytesTransferred / snapshot.totalBytes;
        logger.i('Upload progress: ${(progress * 100).toStringAsFixed(0)}%');
      });
      
      final videoSnapshot = await uploadTask;
      final videoUrl = await videoSnapshot.ref.getDownloadURL();

      // Upload thumbnail if provided
      String? thumbnailUrl;
      if (thumbnailFile != null) {
        final thumbRef = _storage.ref().child('thumbnails/$videoId.jpg');
        final thumbSnapshot = await thumbRef.putFile(thumbnailFile);
        thumbnailUrl = await thumbSnapshot.ref.getDownloadURL();
      }

      // Determine video duration for Media model
      int videoDuration = await VideoDurationUtils.getVideoDurationInMinutes(videoFile) ?? -1;

      // Create Media object
      final media = Media(
        id: videoId,
        title: title,
        description: description,
        imageUrl: thumbnailUrl ?? '',
        videoUrl: videoUrl,
        type: type,
        year: DateTime.now().year,
        rating: rating,
        genres: genres,
        totalEpisodes: type == MediaType.series ? 1 : null,
        duration: videoDuration,
      );

      await _firestore.collection('media').doc(videoId).set({
        'id': videoId,
        'title': title,
        'description': description,
        'imageUrl': media.imageUrl,
        'videoUrl': videoUrl,
        'type': type.toString(),
        'year': media.year,
        'rating': media.rating,
        'genres': genres,
        'totalEpisodes': media.totalEpisodes,
        'duration': media.duration,
        'userId': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      logger.i('✅ Media uploaded successfully: ${media.title} (${media.duration} minutes)');
      return media;
    } catch (e) {
      throw Exception('Upload failed: $e');
    }
  }

  // Upload series with multiple episodes
  static Future<Media> uploadSeries({
    required List<File> episodeFiles,
    required String title,
    required String description,
    required List<String> genres,
    required double rating,
    File? thumbnailFile,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      if (episodeFiles.isEmpty) {
        throw Exception('At least one episode is required for series');
      }

      if (episodeFiles.length > 4) {
        throw Exception('Maximum 4 episodes allowed per series');
      }

      final seriesId = DateTime.now().millisecondsSinceEpoch.toString();

      // Upload thumbnail if provided
      String? thumbnailUrl;
      if (thumbnailFile != null) {
        final thumbRef = _storage.ref().child('thumbnails/$seriesId.jpg');
        final thumbSnapshot = await thumbRef.putFile(thumbnailFile);
        thumbnailUrl = await thumbSnapshot.ref.getDownloadURL();
      }

      // Upload all episodes
      List<Episode> episodes = [];
      int totalDuration = 0;
      
      for (int i = 0; i < episodeFiles.length; i++) {
        final episodeFile = episodeFiles[i];
        final episodeNumber = i + 1;
        final episodeFileName = '${seriesId}_episode_$episodeNumber.mp4';
        
        // Upload episode video
        final episodeRef = _storage.ref().child('videos/$episodeFileName');
        final uploadTask = episodeRef.putFile(episodeFile);
        
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          double progress = snapshot.bytesTransferred / snapshot.totalBytes;
          logger.i('Episode $episodeNumber upload progress: ${(progress * 100).toStringAsFixed(0)}%');
        });
        
        final episodeSnapshot = await uploadTask;
        final episodeUrl = await episodeSnapshot.ref.getDownloadURL();
        
        // Get episode duration
        int episodeDuration = await VideoDurationUtils.getVideoDurationInMinutes(episodeFile) ?? 0;
        totalDuration += episodeDuration;
        
        episodes.add(Episode(
          episodeNumber: episodeNumber,
          videoUrl: episodeUrl,
        ));
      }

      // Create Media object for the series
      final media = Media(
        id: seriesId,
        title: title,
        description: description,
        imageUrl: thumbnailUrl ?? '',
        type: MediaType.series,
        year: DateTime.now().year,
        rating: rating,
        genres: genres,
        totalEpisodes: episodes.length,
        duration: totalDuration,
        episodes: episodes,
      );

      // Save to Firestore
      await _firestore.collection('media').doc(seriesId).set({
        'id': seriesId,
        'title': title,
        'description': description,
        'imageUrl': media.imageUrl,
        'type': MediaType.series.toString(),
        'year': media.year,
        'rating': media.rating,
        'genres': genres,
        'totalEpisodes': media.totalEpisodes,
        'duration': media.duration,
        'episodes': episodes.map((e) => e.toJson()).toList(),
        'userId': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      logger.i('✅ Series uploaded successfully: ${media.title} (${episodes.length} episodes, ${media.duration} minutes total)');
      return media;
    } catch (e) {
      throw Exception('Series upload failed: $e');
    }
  }

  // PLAY: Get all videos for streaming
  static Future<List<Media>> getAllMedia() async {
    try {
      final snapshot = await _firestore
          .collection('media')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Media(
          id: doc.id,
          title: data['title'],
          description: data['description'],
          imageUrl: data['imageUrl'],
          videoUrl: data['videoUrl'],
          type: data['type'] == 'MediaType.series' ? MediaType.series : MediaType.movie,
          year: data['year'],
          rating: (data['rating'] as num).toDouble(),
          genres: List<String>.from(data['genres']),
          totalEpisodes: data['totalEpisodes'],
          duration: data['duration'],
          episodes: (data['episodes'] as List<dynamic>?)
              ?.map((e) => Episode.fromJson(e as Map<String, dynamic>))
              .toList() ?? [],
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to load media: $e');
    }
  }

  // PLAY: Get user's uploaded videos
  static Future<List<Media>> getUserMedia() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final snapshot = await _firestore
          .collection('media')
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Media(
          id: doc.id,
          title: data['title'],
          description: data['description'],
          imageUrl: data['imageUrl'],
          videoUrl: data['videoUrl'],
          type: data['type'] == 'MediaType.series' ? MediaType.series : MediaType.movie,
          year: data['year'],
          rating: (data['rating'] as num).toDouble(),
          genres: List<String>.from(data['genres']),
          totalEpisodes: data['totalEpisodes'],
          duration: data['duration'],
          episodes: (data['episodes'] as List<dynamic>?)
              ?.map((e) => Episode.fromJson(e as Map<String, dynamic>))
              .toList() ?? [],
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to load user media: $e');
    }
  }

  // DELETE: Delete video and metadata
  static Future<void> deleteMedia(String mediaId) async {
    try {
      final user = _auth.currentUser;
      
      if (user == null) throw Exception('User not authenticated');

      final doc = await _firestore.collection('media').doc(mediaId).get();
      
      if (!doc.exists) {
        // TODO: Shouldn't delete an already deleted document
        logger.e('Document not found');
        return;
      }

      final data = doc.data()!;
      final mediaUserId = data['userId'] as String?;
      
      // For anonymous users or when userId is null, allow deletion
      // For identified users, check ownership
      if (mediaUserId != null && user.isAnonymous == false && mediaUserId != user.uid) {
        throw Exception('Not authorized to delete this media');
      }

      // First, delete metadata from Firestore to prevent race conditions
      await _firestore.collection('media').doc(mediaId).delete();

      // Then delete video files from Storage
      try {
        // Handle episodes for series
        final episodes = data['episodes'] as List<dynamic>?;
        if (episodes != null && episodes.isNotEmpty) {
          // Series with episodes - delete each episode video
          for (final episode in episodes) {
            final episodeData = episode as Map<String, dynamic>;
            final videoUrl = episodeData['videoUrl'] as String?;
            if (videoUrl != null && videoUrl.isNotEmpty && videoUrl.contains('firebasestorage')) {
              try {
                final videoRef = _storage.refFromURL(videoUrl);
                await videoRef.delete();
              } catch (e) {
                logger.e('Episode video file deletion failed: $e');
              }
            }
          }
        } else {
          // Single video (movie or legacy series)
          final videoUrl = data['videoUrl'] as String?;
          if (videoUrl != null && videoUrl.isNotEmpty && videoUrl.contains('firebasestorage')) {
            final videoRef = _storage.refFromURL(videoUrl);
            await videoRef.delete();
          }
        }
      } catch (e) {
        logger.e('Video file deletion failed: $e');
      }

      // Finally delete thumbnail (if exists)
      try {
        final imageUrl = data['imageUrl'] as String?;
        if (imageUrl != null && imageUrl.isNotEmpty && imageUrl.contains('firebasestorage')) {
          final thumbRef = _storage.refFromURL(imageUrl);
          await thumbRef.delete();
        }
      } catch (e) {
        // Thumbnail deletion failed, but continue
        logger.e('Thumbnail deletion failed: $e');
      }
      
      logger.i('✅ Media deleted successfully - ID: $mediaId');
    } catch (e, s) {
      logger.e('Delete failed: $e', s);
      throw Exception('Delete failed: $e');
    }
  }

  // VERIFY: Check if media document exists (for debugging)
  static Future<bool> mediaExists(String mediaId) async {
    try {
      final doc = await _firestore.collection('media').doc(mediaId).get();
      return doc.exists;
    } catch (e) {
      logger.e('Error checking media existence: $e');
      return false;
    }
  }

  // SEARCH: Search media by title or description
  static Future<List<Media>> searchMedia(String query) async {
    try {
      if (query.isEmpty) return getAllMedia();

      // Firebase doesn't support full-text search natively
      // So we'll get all media and filter client-side for now
      final allMedia = await getAllMedia();
      
      return allMedia.where((media) =>
        media.title.toLowerCase().contains(query.toLowerCase()) ||
        media.description.toLowerCase().contains(query.toLowerCase()) ||
        media.genres.any((genre) => genre.toLowerCase().contains(query.toLowerCase()))
      ).toList();
    } catch (e) {
      throw Exception('Search failed: $e');
    }
  }

  // FILTER: Filter media by type
  static Future<List<Media>> filterMediaByType(MediaType type) async {
    try {
      final snapshot = await _firestore
          .collection('media')
          .where('type', isEqualTo: type.toString())
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Media(
          id: doc.id,
          title: data['title'],
          description: data['description'],
          imageUrl: data['imageUrl'],
          videoUrl: data['videoUrl'],
          type: type,
          year: data['year'],
          rating: (data['rating'] as num).toDouble(),
          genres: List<String>.from(data['genres']),
          totalEpisodes: data['totalEpisodes'],
          duration: data['duration'],
          episodes: (data['episodes'] as List<dynamic>?)
              ?.map((e) => Episode.fromJson(e as Map<String, dynamic>))
              .toList() ?? [],
        );
      }).toList();
    } catch (e) {
      throw Exception('Filter failed: $e');
    }
  }

  // REFRESH: Force refresh from Firebase
  static Future<List<Media>> refreshAllMedia() async {
    try {
      // Clear cache first
      await CacheService.clearCache();
      
      // Get fresh data from Firebase
      final snapshot = await _firestore
          .collection('media')
          .orderBy('createdAt', descending: true)
          .get();

      final mediaList = snapshot.docs.map((doc) {
        final data = doc.data();
        return Media(
          id: doc.id,
          title: data['title'],
          description: data['description'],
          imageUrl: data['imageUrl'],
          videoUrl: data['videoUrl'],
          type: data['type'] == 'MediaType.series' ? MediaType.series : MediaType.movie,
          year: data['year'],
          rating: (data['rating'] as num).toDouble(),
          genres: List<String>.from(data['genres']),
          totalEpisodes: data['totalEpisodes'],
          duration: data['duration'],
          episodes: (data['episodes'] as List<dynamic>?)
              ?.map((e) => Episode.fromJson(e as Map<String, dynamic>))
              .toList() ?? [],
        );
      }).toList();

      // Update cache with fresh data
      await CacheService.cacheMediaList(mediaList);
      
      return mediaList;
    } catch (e) {
      throw Exception('Failed to refresh media: $e');
    }
  }

  // Update existing media metadata
  static Future<void> updateMedia({
    required String mediaId,
    required String title,
    required String description,
    required MediaType type,
    required List<String> genres,
    required double rating,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Get current media to preserve episode data
      final currentDoc = await _firestore.collection('media').doc(mediaId).get();
      if (!currentDoc.exists) {
        throw Exception('Media not found');
      }

      final currentData = currentDoc.data()!;
      final currentEpisodes = currentData['episodes'] as List<dynamic>?;

      // Prepare update data
      final updateData = <String, dynamic>{
        'title': title,
        'description': description,
        'type': type.toString(),
        'genres': genres,
        'rating': rating,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (type == MediaType.series && currentEpisodes != null) {
        updateData['episodes'] = currentEpisodes;
        updateData['totalEpisodes'] = currentEpisodes.length;
      } else {
        throw Exception('Serie doesnt have episodes');
      }

      // Update Firestore with the changes
      await _firestore.collection('media').doc(mediaId).update(updateData);

      await CacheService.clearCache();
      logger.i('✅ Media updated successfully: $title');
    } catch (e) {
      throw Exception('Update failed: $e');
    }
  }

  /// Fetches a single media item by its ID
  static Future<Media?> getMediaById(String mediaId) async {
    try {
      final docSnapshot = await _firestore.collection('media').doc(mediaId).get();
      
      if (!docSnapshot.exists) {
        logger.w('Media with ID $mediaId not found');
        return null;
      }

      final data = docSnapshot.data()!;
      return Media(
        id: docSnapshot.id,
        title: data['title'],
        description: data['description'],
        imageUrl: data['imageUrl'],
        videoUrl: data['videoUrl'],
        type: data['type'] == 'MediaType.series' ? MediaType.series : MediaType.movie,
        year: data['year'],
        rating: (data['rating'] as num).toDouble(),
        genres: List<String>.from(data['genres']),
        totalEpisodes: data['totalEpisodes'],
        duration: data['duration'],
        episodes: (data['episodes'] as List<dynamic>?)
            ?.map((e) => Episode.fromJson(e as Map<String, dynamic>))
            .toList() ?? [],
      );
    } catch (e) {
      logger.e('Failed to fetch media by ID: $e');
      throw Exception('Failed to fetch media: $e');
    }
  }

}
