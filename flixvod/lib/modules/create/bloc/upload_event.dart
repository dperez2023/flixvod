import 'dart:io';
import 'package:equatable/equatable.dart';
import '../../../models/media.dart';

abstract class UploadEvent extends Equatable {
  const UploadEvent();

  @override
  List<Object?> get props => [];
}

class ValidateFormEvent extends UploadEvent {
  final String title;
  final String description;
  final MediaType type;
  final List<String> genres;
  final double rating;
  final File? video;
  final File? thumbnail;
  final List<File?> episodeVideos;
  final List<String> episodeTitles;

  const ValidateFormEvent({
    required this.title,
    required this.description,
    required this.type,
    required this.genres,
    required this.rating,
    this.video,
    this.thumbnail,
    required this.episodeVideos,
    required this.episodeTitles,
  });

  @override
  List<Object?> get props => [
    title,
    description,
    type,
    genres,
    rating,
    video,
    thumbnail,
    episodeVideos,
    episodeTitles,
  ];
}

class CompressVideoEvent extends UploadEvent {
  final File videoFile;

  const CompressVideoEvent(this.videoFile);

  @override
  List<Object> get props => [videoFile];
}

class UploadMediaEvent extends UploadEvent {
  final String title;
  final String description;
  final MediaType type;
  final List<String> genres;
  final double rating;
  final File? video;
  final File? thumbnail;
  final List<File?> episodeVideos;
  final List<String> episodeTitles;

  const UploadMediaEvent({
    required this.title,
    required this.description,
    required this.type,
    required this.genres,
    required this.rating,
    this.video,
    this.thumbnail,
    required this.episodeVideos,
    required this.episodeTitles,
  });

  @override
  List<Object?> get props => [
    title,
    description,
    type,
    genres,
    rating,
    video,
    thumbnail,
    episodeVideos,
    episodeTitles,
  ];
}

class UpdateMediaEvent extends UploadEvent {
  final String mediaId;
  final String title;
  final String description;
  final MediaType type;
  final List<String> genres;
  final double rating;

  const UpdateMediaEvent({
    required this.mediaId,
    required this.title,
    required this.description,
    required this.type,
    required this.genres,
    required this.rating,
  });

  @override
  List<Object> get props => [mediaId, title, description, type, genres, rating];
}

class ResetUploadEvent extends UploadEvent {}
