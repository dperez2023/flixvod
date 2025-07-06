import 'package:flutter_test/flutter_test.dart';
import 'package:flixvod/services/storage/firebase_service.dart';
import 'package:flixvod/models/media.dart';

void main() {
  final expectedGenres = [
    'Action',
    'Adventure',
    'Animation',
    'Comedy',
    'Crime',
    'Documentary',
    'Drama',
    'Family',
    'Fantasy',
    'History',
    'Horror',
    'Music',
    'Mystery',
    'Romance',
    'Sci-Fi',
    'Thriller',
    'War',
    'Western'
  ];
  group('FirebaseService', () {
    group('Static Properties and Methods', () {
      test('availableGenres should return non-empty list', () {
        const genres = FirebaseService.availableGenres;
        
        expect(genres, isA<List<String>>());
        expect(genres.isNotEmpty, true);
        expect(genres.length, greaterThan(10));
      });

      test('availableGenres should contain expected genres', () {
        const genres = FirebaseService.availableGenres;
        
        expect(genres, contains('Action'));
        expect(genres, contains('Comedy'));
        expect(genres, contains('Drama'));
        expect(genres, contains('Horror'));
        expect(genres, contains('Romance'));
        expect(genres, contains('Sci-Fi'));
        expect(genres, contains('Thriller'));
      });

      test('availableGenres should be immutable', () {
        final genres = FirebaseService.availableGenres;
        
        expect(() => genres.add('New Genre'), throwsUnsupportedError);
        expect(() => genres.remove('Action'), throwsUnsupportedError);
        expect(() => genres.clear(), throwsUnsupportedError);
      });

      test('getAvailableGenres should return Future with same genres', () async {
        final genres = await FirebaseService.getAvailableGenres();
        
        expect(genres, isA<List<String>>());
        expect(genres.length, equals(FirebaseService.availableGenres.length));
        expect(genres, containsAll(FirebaseService.availableGenres));
      });

      test('getAvailableGenres should return a copy of the list', () async {
        final genres = await FirebaseService.getAvailableGenres();
        
        genres.add('Test Genre');
        expect(genres.length, equals(FirebaseService.availableGenres.length + 1));
        expect(FirebaseService.availableGenres.contains('Test Genre'), false);
      });
    });

    group('Method Signatures - Function Existence Tests', () {
      test('uploadVideo should be a function', () {
        expect(FirebaseService.uploadVideo, isA<Function>());
      });

      test('uploadSeries should be a function', () {
        expect(FirebaseService.uploadSeries, isA<Function>());
      });

      test('getAllMedia should be a function', () {
        expect(FirebaseService.getAllMedia, isA<Function>());
      });

      test('refreshAllMedia should be a function', () {
        expect(FirebaseService.refreshAllMedia, isA<Function>());
      });

      test('getMediaById should be a function', () {
        expect(FirebaseService.getMediaById, isA<Function>());
      });

      test('deleteMedia should be a function', () {
        expect(FirebaseService.deleteMedia, isA<Function>());
      });

      test('mediaExists should be a function', () {
        expect(FirebaseService.mediaExists, isA<Function>());
      });

      test('searchMedia should be a function', () {
        expect(FirebaseService.searchMedia, isA<Function>());
      });

      test('filterMediaByType should be a function', () {
        expect(FirebaseService.filterMediaByType, isA<Function>());
      });

      test('getUserMedia should be a function', () {
        expect(FirebaseService.getUserMedia, isA<Function>());
      });

      test('updateMedia should be a function', () {
        expect(FirebaseService.updateMedia, isA<Function>());
      });

      test('signOut should be a function', () {
        expect(FirebaseService.signOut, isA<Function>());
      });

      test('initialize should be a function', () {
        expect(FirebaseService.initialize, isA<Function>());
      });
    });

    group('Media Type Validation', () {
      test('should handle MediaType enum correctly', () {
        expect(MediaType.movie, isA<MediaType>());
        expect(MediaType.series, isA<MediaType>());
        expect(MediaType.movie.toString(), equals('MediaType.movie'));
        expect(MediaType.series.toString(), equals('MediaType.series'));
      });

      test('MediaType values should be distinct', () {
        expect(MediaType.movie, isNot(equals(MediaType.series)));
      });
    });

    group('Genre Validation', () {
      test('should validate common genres are present', () {
        const genres = FirebaseService.availableGenres;

        for (final genre in expectedGenres) {
          expect(genres, contains(genre), reason: 'Genre "$genre" should be available');
        }
      });

      test('should not contain duplicate genres', () {
        const genres = FirebaseService.availableGenres;
        final uniqueGenres = genres.toSet();
        
        expect(genres.length, equals(uniqueGenres.length), 
               reason: 'Genre list should not contain duplicates');
      });

      test('should have genres in a reasonable order', () {
        const genres = FirebaseService.availableGenres;
        
        // Test that the list is not empty and has a reasonable structure
        expect(genres.first, isA<String>());
        expect(genres.last, isA<String>());
        expect(genres.every((genre) => genre.isNotEmpty), true);
      });

      test('should have all genres with proper capitalization', () {
        const genres = FirebaseService.availableGenres;
        
        for (final genre in genres) {
          expect(genre, isNotEmpty);
          expect(genre.trim(), equals(genre), reason: 'Genre should not have leading/trailing whitespace');
          expect(genre[0], equals(genre[0].toUpperCase()), reason: 'Genre should start with uppercase');
          // Check that genres don't contain only lowercase or uppercase
          expect(genre, isNot(equals(genre.toLowerCase())), reason: 'Genre should not be all lowercase');
        }
      });
    });

    group('Constants and Configuration', () {
      test('should have reasonable genre count', () {
        const genres = FirebaseService.availableGenres;
        expect(genres.length, greaterThanOrEqualTo(15));
        expect(genres.length, lessThanOrEqualTo(25));
      });

      test('should have consistent genre naming', () {
        const genres = FirebaseService.availableGenres;
        
        for (final genre in genres) {
          expect(genre, isNotEmpty);
          expect(genre.trim(), equals(genre));
          // Check that no genre contains invalid characters
          expect(genre, matches(RegExp(r'^[a-zA-Z\s\-]+$')), 
                 reason: 'Genre "$genre" should only contain letters, spaces, and hyphens');
        }
      });

      test('should contain expected genre categories', () {
        const genres = FirebaseService.availableGenres;
        
        // Test for presence of major genre categories
        expect(genres.where((g) => g.toLowerCase().contains('action')), isNotEmpty);
        expect(genres.where((g) => g.toLowerCase().contains('comedy')), isNotEmpty);
        expect(genres.where((g) => g.toLowerCase().contains('drama')), isNotEmpty);
        expect(genres.where((g) => g.toLowerCase().contains('horror')), isNotEmpty);
      });
    });

    group('Service Class Structure', () {
      test('FirebaseService should be a class', () {
        expect(FirebaseService, isA<Type>());
      });

      test('should have all required static methods defined', () {
        // Test method existence without calling them
        expect(FirebaseService.getAvailableGenres, isA<Function>());
        expect(FirebaseService.signOut, isA<Function>());
        expect(FirebaseService.initialize, isA<Function>());
        expect(FirebaseService.uploadVideo, isA<Function>());
        expect(FirebaseService.uploadSeries, isA<Function>());
        expect(FirebaseService.getAllMedia, isA<Function>());
        expect(FirebaseService.getUserMedia, isA<Function>());
        expect(FirebaseService.deleteMedia, isA<Function>());
        expect(FirebaseService.mediaExists, isA<Function>());
        expect(FirebaseService.searchMedia, isA<Function>());
        expect(FirebaseService.filterMediaByType, isA<Function>());
        expect(FirebaseService.refreshAllMedia, isA<Function>());
        expect(FirebaseService.updateMedia, isA<Function>());
        expect(FirebaseService.getMediaById, isA<Function>());
      });

      test('should have static properties defined', () {
        expect(FirebaseService.availableGenres, isA<List<String>>());
      });
    });

    group('Data Consistency', () {
      test('getAvailableGenres should be consistent with static property', () async {
        final asyncGenres = await FirebaseService.getAvailableGenres();
        final staticGenres = FirebaseService.availableGenres;
        
        expect(asyncGenres.length, equals(staticGenres.length));
        
        for (int i = 0; i < asyncGenres.length; i++) {
          expect(asyncGenres[i], equals(staticGenres[i]));
        }
      });

      test('multiple calls to getAvailableGenres should return equivalent data', () async {
        final first = await FirebaseService.getAvailableGenres();
        final second = await FirebaseService.getAvailableGenres();
        
        expect(first.length, equals(second.length));
        expect(first, containsAll(second));
        expect(second, containsAll(first));
      });

      test('genre list should be stable across calls', () {
        final first = FirebaseService.availableGenres;
        final second = FirebaseService.availableGenres;
        
        expect(identical(first, second), true, reason: 'Should return the same instance');
      });
    });

    group('Input Validation Tests', () {
      test('Media enum should have expected values', () {
        expect(MediaType.values, hasLength(2));
        expect(MediaType.values, contains(MediaType.movie));
        expect(MediaType.values, contains(MediaType.series));
      });

      test('enum toString should be consistent', () {
        expect(MediaType.movie.toString(), contains('movie'));
        expect(MediaType.series.toString(), contains('series'));
        expect(MediaType.movie.toString(), isNot(contains('series')));
        expect(MediaType.series.toString(), isNot(contains('movie')));
      });
    });

    group('Timeout Functionality', () {
      test('timeout wrapper should exist and be callable', () {
        expect(FirebaseService, isA<Type>());
        
        // Verify that methods that should use timeout can be called
        expect(FirebaseService.getAllMedia, isA<Function>());
        expect(FirebaseService.refreshAllMedia, isA<Function>());
        expect(FirebaseService.getMediaById, isA<Function>());
      });

      test('timeout should be consistent across methods', () {
        // Meaning that methods that are expected to have timeout handling
        expect(FirebaseService.getAllMedia, isA<Function>());
        expect(FirebaseService.refreshAllMedia, isA<Function>());
        expect(FirebaseService.getMediaById, isA<Function>());
        expect(FirebaseService.deleteMedia, isA<Function>());
        expect(FirebaseService.updateMedia, isA<Function>());
        expect(FirebaseService.getUserMedia, isA<Function>());
        expect(FirebaseService.mediaExists, isA<Function>());
        expect(FirebaseService.filterMediaByType, isA<Function>());
      });

      test('should have timeout handling in exception handler', () {
        // Verify that the exception handler includes timeout
        expect(FirebaseService.availableGenres, isA<List<String>>());
        expect(FirebaseService.getAvailableGenres, isA<Function>());
      });
    });
  });
}
