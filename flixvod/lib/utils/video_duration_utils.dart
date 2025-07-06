import 'dart:io';
import 'package:flutter/services.dart';
import 'logger.dart';
import '../models/media.dart';

class VideoDurationUtils {
  static const MethodChannel _channel = MethodChannel('video_duration');

  /// Get video duration in minutes from a video file
  /// Returns null if duration cannot be determined
  static Future<int?> getVideoDurationInMinutes(File videoFile) async {
    try {
      // Check if file exists
      if (!await videoFile.exists()) {
        logger.e('Video file does not exist: ${videoFile.path}');
        return null;
      }

      // Get file size for basic validation
      final fileSize = await videoFile.length();
      if (fileSize == 0) {
        logger.e('Video file is empty: ${videoFile.path}');
        return null;
      }

      // Try to get duration using platform channel (if available)
      try {
        final durationInSeconds = await _channel.invokeMethod<int>('getDuration', {
          'path': videoFile.absolute.path,
        });
        
        if (durationInSeconds != null && durationInSeconds > 0) {
          final durationInMinutes = (durationInSeconds / 60).round();
          return durationInMinutes;
        }
      } catch (e) {
        logger.w('Platform channel method failed, using fallback: $e');
      }

      // Fallback: Estimate duration based on file size and type
      return _estimateDurationFromFileSize(videoFile, fileSize);
      
    } catch (e, stackTrace) {
      logger.e('Failed to get video duration: $e', stackTrace);
      return null;
    }
  }

  /// Estimate video duration based on file size and extension
  /// This is a rough estimation and may not be accurate
  static int? _estimateDurationFromFileSize(File videoFile, int fileSize) {
    try {
      final extension = videoFile.path.split('.').last.toLowerCase();
      
      // Average bitrates for different formats (kbps)
      final Map<String, double> averageBitrates = {
        'mp4': 2000.0,   // 2 Mbps for standard quality
        'mov': 2500.0,   // 2.5 Mbps for MOV files
        'avi': 1500.0,   // 1.5 Mbps for AVI files
        'mkv': 2200.0,   // 2.2 Mbps for MKV files
        'm4v': 2000.0,   // 2 Mbps for M4V files
        'webm': 1800.0,  // 1.8 Mbps for WebM files
      };

      final bitrate = averageBitrates[extension] ?? 2000.0; // Default to 2 Mbps
      
      // Calculate estimated duration
      // File size in bytes -> bits -> seconds -> minutes
      final fileSizeInBits = fileSize * 8;
      final bitrateInBitsPerSecond = bitrate * 1000;
      final durationInSeconds = fileSizeInBits / bitrateInBitsPerSecond;
      final durationInMinutes = (durationInSeconds / 60).round();
      
      // Sanity check: videos should be between 1 minute and 10 hours
      if (durationInMinutes < 1) {
        logger.w('Estimated duration too short: ${durationInMinutes} minutes');
        return 1; // Minimum 1 minute
      } else if (durationInMinutes > 600) { // 10 hours
        logger.w('Estimated duration too long: ${durationInMinutes} minutes');
        return 120; // Default to 2 hours for long videos
      }
      
      return durationInMinutes;
      
    } catch (e) {
      logger.e('Failed to estimate duration from file size: $e');
      return null;
    }
  }

  /// Format file size for logging
  static String _formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes} B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Get a reasonable default duration based on media type
  static int getDefaultDuration(MediaType mediaType) {
    switch (mediaType) {
      case MediaType.movie:
        return 120; // 2 hours default for movies
      case MediaType.series:
        return 45;  // 45 minutes default for series episodes
    }
  }

  /// Validate if a duration seems reasonable for the media type
  static bool isReasonableDuration(int durationInMinutes, MediaType mediaType) {
    switch (mediaType) {
      case MediaType.movie:
        // Movies: typically 60-300 minutes (1-5 hours)
        return durationInMinutes >= 60 && durationInMinutes <= 300;
      case MediaType.series:
        // Series episodes: typically 20-90 minutes
        return durationInMinutes >= 20 && durationInMinutes <= 90;
    }
  }
}
