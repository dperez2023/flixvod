import 'package:flutter_test/flutter_test.dart';
import 'package:flixvod/models/media.dart';

/// Test helper class containing common test data and utilities
class FirebaseServiceTestHelper {
  static Media createTestMovie({
    String id = 'test-movie-1',
    String title = 'Test Movie',
    String description = 'Description for test movie',
    List<String> genres = const ['Action', 'Comedy'],
    double rating = 4,
    int duration = 10,
  }) {
    return Media(
      id: id,
      title: title,
      description: description,
      imageUrl: 'https://example.com/image.jpg',
      videoUrl: 'https://example.com/video.mp4',
      type: MediaType.movie,
      year: 2025,
      rating: rating,
      genres: genres,
      totalEpisodes: null,
      duration: duration,
      episodes: const [],
    );
  }

  static Media createTestSeries({
    String id = 'test-series-1',
    String title = 'Test Series',
    String description = 'A test series for unit testing',
    List<String> genres = const ['Drama', 'Thriller'],
    double rating = 4.8,
    int episodeCount = 3,
    int duration = 180,
  }) {
    final episodes = List.generate(episodeCount, (index) {
      return Episode(
        episodeNumber: index + 1,
        videoUrl: 'https://example.com/episode-${index + 1}.mp4',
      );
    });

    return Media(
      id: id,
      title: title,
      description: description,
      imageUrl: 'https://example.com/test-series-image.jpg',
      videoUrl: '',
      type: MediaType.series,
      year: 2023,
      rating: rating,
      genres: genres,
      totalEpisodes: episodeCount,
      duration: duration,
      episodes: episodes,
    );
  }

  /// Common test expectations for Media objects
  static void expectValidMedia(Media media) {
    expect(media.id, isNotEmpty);
    expect(media.title, isNotEmpty);
    expect(media.description, isNotEmpty);
    expect(media.type, isA<MediaType>());
    expect(media.rating, greaterThanOrEqualTo(0));
    expect(media.rating, lessThanOrEqualTo(5));
    expect(media.genres, isNotEmpty);
    expect(media.year, greaterThan(1900));
    expect(media.duration, greaterThan(0));
  }

  /// Common test expectations for genre lists
  static void expectValidGenreList(List<String> genres) {
    expect(genres, isNotEmpty);
    expect(genres.every((genre) => genre.isNotEmpty), true);
    expect(genres.every((genre) => genre.trim() == genre), true);
    expect(genres.toSet().length, equals(genres.length)); // No duplicates
  }

  static const Map<String, String> firebaseErrorCodes = {
    'network-request-failed': 'No internet connection',
    'unavailable': 'No internet connection',
    'timeout': 'Operation timed out',
    'deadline-exceeded': 'Operation timed out',
    'quota-exceeded': 'Storage quota exceeded',
    'resource-exhausted': 'Storage quota exceeded',
    'unauthorized': 'Permission denied',
    'permission-denied': 'Permission denied',
  };

  static Map<String, dynamic> createMockFirestoreMovieData({
    String id = 'test-movie-1',
    String title = 'Test Movie',
  }) {
    return {
      'id': id,
      'title': title,
      'description': 'A test movie for unit testing',
      'imageUrl': 'https://example.com/image.jpg',
      'videoUrl': 'https://example.com/video.mp4',
      'type': 'MediaType.movie',
      'year': 2023,
      'rating': 4.5,
      'genres': ['Action', 'Comedy'],
      'totalEpisodes': null,
      'duration': 120,
      'episodes': [],
      'userId': 'test-user-id',
      'createdAt': DateTime.now(),
      'updatedAt': DateTime.now(),
    };
  }

  static Map<String, dynamic> createMockFirestoreSeriesData({
    String id = 'test-series-1',
    String title = 'Test Series',
  }) {
    return {
      'id': id,
      'title': title,
      'description': 'A test series for unit testing',
      'imageUrl': 'https://example.com/test-series-image.jpg',
      'videoUrl': '',
      'type': 'MediaType.series',
      'year': 2023,
      'rating': 4.8,
      'genres': ['Drama', 'Thriller'],
      'totalEpisodes': 3,
      'duration': 180,
      'episodes': [
        {'episodeNumber': 1, 'videoUrl': 'https://example.com/episode-1.mp4'},
        {'episodeNumber': 2, 'videoUrl': 'https://example.com/episode-2.mp4'},
        {'episodeNumber': 3, 'videoUrl': 'https://example.com/episode-3.mp4'},
      ],
      'userId': 'test-user-id',
      'createdAt': DateTime.now(),
      'updatedAt': DateTime.now(),
    };
  }
}
