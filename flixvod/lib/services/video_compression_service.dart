import 'dart:io';
import 'package:path/path.dart' as path;

class VideoCompressionService {
  static int maxVideoSize = 100 * 1024 * 1024;

  /// If needed depending of size and rules, video should be compressed
  static Future<File> compressVideo({
    required File inputFile,
    String? outputPath,
    VideoQuality quality = VideoQuality.medium,
  }) async {
    try {
      final String fileName = path.basenameWithoutExtension(inputFile.path);
      final String extension = path.extension(inputFile.path);
      final String outputDir = outputPath ?? path.dirname(inputFile.path);
      final String compressedPath = path.join(outputDir, '${fileName}_compressed$extension');

      final compressedFile = await inputFile.copy(compressedPath);

      // TODO: Implement video compression (ffmpeg)
      return compressedFile;
    } catch (e) {
      throw Exception('Video compression failed: $e');
    }
  }

  /// Get video file information
  static Future<VideoInfo> getVideoInfo(File videoFile) async {
    try {
      final stats = await videoFile.stat();
      
      // TODO: Missing video metadata
      return VideoInfo(
        filePath: videoFile.path,
        fileSize: stats.size,
        duration: const Duration(minutes: 5),
        width: 1920,
        height: 1080,
        bitrate: 5000000,
      );
    } catch (e) {
      throw Exception('Failed to get video info: $e');
    }
  }

  /// Estimate compressed file size
  static int estimateCompressedSize(VideoInfo info, VideoQuality quality) {
    final double compressionRatio = switch (quality) {
      VideoQuality.low => 0.3,
      VideoQuality.medium => 0.5,
      VideoQuality.high => 0.7,
    };
    
    return (info.fileSize * compressionRatio).round();
  }

  /// Check if video needs compression
  static bool shouldCompress(VideoInfo info) {
    return info.fileSize > maxVideoSize;
  }
}

enum VideoQuality {
  low,    // 480p
  medium, // 720p
  high,   // 1080p
}

class VideoInfo {
  final String filePath;
  final int fileSize;
  final Duration duration;
  final int width;
  final int height;
  final int bitrate;

  const VideoInfo({
    required this.filePath,
    required this.fileSize,
    required this.duration,
    required this.width,
    required this.height,
    required this.bitrate,
  });

  bool get isLargeFile => fileSize > VideoCompressionService.maxVideoSize;
  bool get isHighDefinition => width >= 1920 && height >= 1080;
  String get sizeString => '${(fileSize / 1024 / 1024).toStringAsFixed(1)} MB';
}
