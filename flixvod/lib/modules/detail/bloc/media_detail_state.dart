import 'package:equatable/equatable.dart';
import '../../../models/media.dart';

enum MediaDetailStatus {
  initial,
  loading,
  loaded,
  deleting,
  deleted,
  error,
}

enum NavigationAction {
  none,
  navigateToVideoPlayer,
}

class MediaDetailState extends Equatable {
  final MediaDetailStatus status;
  final Media? media;
  final String? errorMessage;
  final bool isDeleting;
  final NavigationAction navigationAction;
  final Media? navigationMedia;
  final int? navigationEpisodeNumber;

  const MediaDetailState({
    this.status = MediaDetailStatus.initial,
    this.media,
    this.errorMessage,
    this.isDeleting = false,
    this.navigationAction = NavigationAction.none,
    this.navigationMedia,
    this.navigationEpisodeNumber,
  });

  MediaDetailState copyWith({
    MediaDetailStatus? status,
    Media? media,
    String? errorMessage,
    bool? isDeleting,
    NavigationAction? navigationAction,
    Media? navigationMedia,
    int? navigationEpisodeNumber,
  }) {
    return MediaDetailState(
      status: status ?? this.status,
      media: media ?? this.media,
      errorMessage: errorMessage,
      isDeleting: isDeleting ?? this.isDeleting,
      navigationAction: navigationAction ?? this.navigationAction,
      navigationMedia: navigationMedia ?? this.navigationMedia,
      navigationEpisodeNumber: navigationEpisodeNumber ?? this.navigationEpisodeNumber,
    );
  }

  /// Creates a copy of this state with navigation action cleared
  MediaDetailState clearNavigation() {
    return copyWith(
      navigationAction: NavigationAction.none,
      navigationMedia: null,
      navigationEpisodeNumber: null,
    );
  }

  @override
  List<Object?> get props => [
    status, 
    media, 
    errorMessage, 
    isDeleting, 
    navigationAction, 
    navigationMedia, 
    navigationEpisodeNumber
  ];
}
