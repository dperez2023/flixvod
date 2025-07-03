import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flixvod/logger.dart';
import '../models/media.dart';

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
      logger.d('✅ Firebase VOD Service initialized');
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
        // TODO: Progress upload status in a UI dialog/progress bar
        double progress = snapshot.bytesTransferred / snapshot.totalBytes;
        logger.d('Upload progress: ${(progress * 100).toStringAsFixed(1)}%');
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

      // Create Media object
      final media = Media(
        id: videoId,
        title: title,
        description: description,
        imageUrl: thumbnailUrl ?? 'https://via.placeholder.com/300x450?text=${Uri.encodeComponent(title)}',
        videoUrl: videoUrl,
        type: type,
        year: DateTime.now().year,
        rating: 5.0, // Default rating
        genres: genres,
        seasons: type == MediaType.series ? 1 : null,
        totalEpisodes: type == MediaType.series ? 1 : null,
        duration: type == MediaType.movie ? 120 : null,
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
        'seasons': media.seasons,
        'totalEpisodes': media.totalEpisodes,
        'duration': media.duration,
        'userId': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return media;
    } catch (e) {
      throw Exception('Upload failed: $e');
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
          id: data['id'],
          title: data['title'],
          description: data['description'],
          imageUrl: data['imageUrl'],
          videoUrl: data['videoUrl'],
          type: data['type'] == 'MediaType.series' ? MediaType.series : MediaType.movie,
          year: data['year'],
          rating: (data['rating'] as num).toDouble(),
          genres: List<String>.from(data['genres']),
          seasons: data['seasons'],
          totalEpisodes: data['totalEpisodes'],
          duration: data['duration'],
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
          id: data['id'],
          title: data['title'],
          description: data['description'],
          imageUrl: data['imageUrl'],
          videoUrl: data['videoUrl'],
          type: data['type'] == 'MediaType.series' ? MediaType.series : MediaType.movie,
          year: data['year'],
          rating: (data['rating'] as num).toDouble(),
          genres: List<String>.from(data['genres']),
          seasons: data['seasons'],
          totalEpisodes: data['totalEpisodes'],
          duration: data['duration'],
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
      //TODO: Should annonymous users be able to delete media?
      if (user == null) throw Exception('User not authenticated');

      final doc = await _firestore.collection('media').doc(mediaId).get();
      if (!doc.exists) throw Exception('Media not found');

      final data = doc.data()!;
      
      // Check if user owns this media
      if (data['userId'] != user.uid) {
        throw Exception('Not authorized to delete this media');
      }

      // Delete video file from Storage
      final videoUrl = data['videoUrl'] as String;
      final videoRef = _storage.refFromURL(videoUrl);
      await videoRef.delete();

      // Delete thumbnail if exists
      try {
        if (data['imageUrl'] != null && 
            (data['imageUrl'] as String).contains('firebasestorage')) {
          final thumbRef = _storage.refFromURL(data['imageUrl']);
          await thumbRef.delete();
        }
      } catch (e, s) {
        // Thumbnail deletion failed, but continue
        logger.e('Thumbnail deletion failed: $e', s);
      }

      // Delete metadata from Firestore
      await _firestore.collection('media').doc(mediaId).delete();
      
      logger.i('✅ Media deleted successfully');
    } catch (e, s) {
      throw Exception('Delete failed: $e');
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
          id: data['id'],
          title: data['title'],
          description: data['description'],
          imageUrl: data['imageUrl'],
          videoUrl: data['videoUrl'],
          type: type,
          year: data['year'],
          rating: (data['rating'] as num).toDouble(),
          genres: List<String>.from(data['genres']),
          seasons: data['seasons'],
          totalEpisodes: data['totalEpisodes'],
          duration: data['duration'],
        );
      }).toList();
    } catch (e) {
      throw Exception('Filter failed: $e');
    }
  }
}
