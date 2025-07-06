import 'package:equatable/equatable.dart';

enum MediaType { movie, series }

class Episode extends Equatable {
  final int episodeNumber;
  final String videoUrl;

  const Episode({
    required this.episodeNumber,
    required this.videoUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'episodeNumber': episodeNumber,
      'videoUrl': videoUrl,
    };
  }

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      episodeNumber: json['episodeNumber'] ?? 1,
      videoUrl: json['videoUrl'] ?? '',
    );
  }

  @override
  List<Object?> get props => [episodeNumber, videoUrl];
}

class Media extends Equatable {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final MediaType type;
  final int year;
  final double rating;
  final List<String> genres;
  final int? seasons;
  final int? totalEpisodes;
  final int? duration;
  final String? videoUrl;
  final List<Episode> episodes;

  const Media({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.type,
    required this.year,
    required this.rating,
    required this.genres,
    this.seasons,
    this.totalEpisodes,
    this.duration,
    this.videoUrl,
    this.episodes = const [],
  });

  bool get isMovie => type == MediaType.movie;
  bool get isSeries => type == MediaType.series;
  int get episodeCount => episodes.length;

  /// Returns true if the media has a valid image URL
  bool get hasValidImageUrl => imageUrl.isNotEmpty && Uri.tryParse(imageUrl) != null;

  // Get episode by number
  Episode? getEpisode(int episodeNumber) {
    return episodes.where((e) => e.episodeNumber == episodeNumber).firstOrNull;
  }

  String? getVideoUrl([int? episodeNumber]) {
    if (isMovie) return videoUrl;

    // If episodeNumber is provided, return the specific episode's video URL
    if (episodeNumber != null) {
      return getEpisode(episodeNumber)?.videoUrl;
    }
    return episodes.isNotEmpty ? episodes.first.videoUrl : videoUrl;
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'type': type.name,
      'year': year,
      'rating': rating,
      'genres': genres,
      'seasons': seasons,
      'totalEpisodes': totalEpisodes,
      'duration': duration,
      'videoUrl': videoUrl,
      'episodes': episodes.map((e) => e.toJson()).toList(),
    };
  }

  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      type: MediaType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MediaType.movie,
      ),
      year: json['year'] ?? 0,
      rating: (json['rating'] ?? 0.0).toDouble(),
      genres: List<String>.from(json['genres'] ?? []),
      seasons: json['seasons'],
      totalEpisodes: json['totalEpisodes'],
      duration: json['duration'],
      videoUrl: json['videoUrl'],
      episodes: (json['episodes'] as List<dynamic>?)
          ?.map((e) => Episode.fromJson(e as Map<String, dynamic>))
          .toList() ?? [], //TODO: Confirm mapping
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        imageUrl,
        type,
        year,
        rating,
        genres,
        seasons,
        totalEpisodes,
        duration,
        videoUrl,
        episodes,
      ];
}
