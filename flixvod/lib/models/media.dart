import 'package:equatable/equatable.dart';

enum MediaType { movie, series }

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
  });

  bool get isMovie => type == MediaType.movie;
  bool get isSeries => type == MediaType.series;

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
      ];
}
