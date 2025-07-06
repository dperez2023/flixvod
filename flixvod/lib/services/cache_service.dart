import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/media.dart';
import '../utils/logger.dart';

class CacheService {
  static const String _mediaListKey = 'cached_media_list';
  static const String _cacheTimestampKey = 'cache_timestamp';
  static const Duration _cacheExpiry = Duration(hours: 1);

  /// Cache media list locally
  static Future<void> cacheMediaList(List<Media> mediaList) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mediaJson = mediaList.map((media) => media.toJson()).toList();
      final jsonString = jsonEncode(mediaJson);
      
      await prefs.setString(_mediaListKey, jsonString);
      await prefs.setInt(_cacheTimestampKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e, s) {
      logger.e('Failed to cache media list: $e', s);
    }
  }

  /// Get cached media list if not expired
  static Future<List<Media>?> getCachedMediaList() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_mediaListKey);
      final timestamp = prefs.getInt(_cacheTimestampKey);
      
      if (jsonString == null || timestamp == null) {
        return null;
      }

      // Check if cache is expired
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      if (DateTime.now().difference(cacheTime) > _cacheExpiry) {
        return null;
      }

      final List<dynamic> mediaJson = jsonDecode(jsonString);
      return mediaJson.map((json) => Media.fromJson(json)).toList();
    } catch (e, s) {
      logger.e('Failed to get cached media list: $e', s);
      return null;
    }
  }

  static Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_mediaListKey);
      await prefs.remove(_cacheTimestampKey);
    } catch (e, s) {
      logger.e('Failed to clear cache: $e', s);
    }
  }

  /// Check if cache is expired
  static Future<bool> isCacheExpired() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(_cacheTimestampKey);
      
      if (timestamp == null) return true;
      
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      return DateTime.now().difference(cacheTime) > _cacheExpiry;
    } catch (e) {
      return true;
    }
  }
}
