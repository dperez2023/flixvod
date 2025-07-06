import 'package:equatable/equatable.dart';
import '../../../models/media.dart';

abstract class MediaDetailEvent extends Equatable {
  const MediaDetailEvent();

  @override
  List<Object?> get props => [];
}

class LoadMediaDetailEvent extends MediaDetailEvent {
  final String mediaId;

  const LoadMediaDetailEvent(this.mediaId);

  @override
  List<Object> get props => [mediaId];
}

class DeleteMediaEvent extends MediaDetailEvent {
  final String mediaId;

  const DeleteMediaEvent(this.mediaId);

  @override
  List<Object> get props => [mediaId];
}

class PlayVideoEvent extends MediaDetailEvent {
  final Media media;
  final int? episodeNumber;

  const PlayVideoEvent(this.media, {this.episodeNumber});

  @override
  List<Object?> get props => [media, episodeNumber];
}

class RefreshMediaDetailEvent extends MediaDetailEvent {
  final String mediaId;

  const RefreshMediaDetailEvent(this.mediaId);

  @override
  List<Object> get props => [mediaId];
}

class ClearNavigationEvent extends MediaDetailEvent {
  const ClearNavigationEvent();

  @override
  List<Object> get props => [];
}
