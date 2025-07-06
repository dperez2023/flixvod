import 'package:flutter_bloc/flutter_bloc.dart';
import 'media_detail_event.dart';
import 'media_detail_state.dart';
import '../../../services/storage/firebase_service.dart';
import '../../../utils/logger.dart';

class MediaDetailBloc extends Bloc<MediaDetailEvent, MediaDetailState> {
  MediaDetailBloc() : super(const MediaDetailState()) {
    on<LoadMediaDetailEvent>(_onLoadMediaDetail);
    on<DeleteMediaEvent>(_onDeleteMedia);
    on<PlayVideoEvent>(_onPlayVideo);
    on<RefreshMediaDetailEvent>(_onRefreshMediaDetail);
    on<ClearNavigationEvent>(_onClearNavigation);
  }

  void _onLoadMediaDetail(LoadMediaDetailEvent event, Emitter<MediaDetailState> emit) async {
    emit(state.copyWith(status: MediaDetailStatus.loading));
    
    try {
      final media = await FirebaseService.getMediaById(event.mediaId);
      
      if (media != null) {
        emit(state.copyWith(
          status: MediaDetailStatus.loaded,
          media: media,
        ));
      } else {
        emit(state.copyWith(
          status: MediaDetailStatus.error,
          errorMessage: 'Media not found',
        ));
      }
    } catch (e) {
      FlixLogger.instance.e('Failed to load media detail: $e');
      emit(state.copyWith(
        status: MediaDetailStatus.error,
        errorMessage: 'Failed to load media: $e',
      ));
    }
  }

  void _onDeleteMedia(DeleteMediaEvent event, Emitter<MediaDetailState> emit) async {
    emit(state.copyWith(
      status: MediaDetailStatus.deleting,
      isDeleting: true,
    ));
    
    try {
      await FirebaseService.deleteMedia(event.mediaId);
      final stillExists = await FirebaseService.mediaExists(event.mediaId);
      
      if (!stillExists) {
        emit(state.copyWith(
          status: MediaDetailStatus.deleted,
          isDeleting: false,
        ));
      } else {
        emit(state.copyWith(
          status: MediaDetailStatus.error,
          errorMessage: 'Media deletion failed - still exists',
          isDeleting: false,
        ));
      }
    } catch (e) {
      FlixLogger.instance.e('Failed to delete media: $e');
      emit(state.copyWith(
        status: MediaDetailStatus.error,
        errorMessage: 'Failed to delete media: $e',
        isDeleting: false,
      ));
    }
  }

  void _onPlayVideo(PlayVideoEvent event, Emitter<MediaDetailState> emit) async {
    try {
      FlixLogger.instance.d('Playing video: ${event.media.title}');
      
      if (event.episodeNumber != null) {
        FlixLogger.instance.d('Episode: ${event.episodeNumber}');
      }
      
      emit(state.copyWith(
        navigationAction: NavigationAction.navigateToVideoPlayer,
        navigationMedia: event.media,
        navigationEpisodeNumber: event.episodeNumber,
      ));
      
    } catch (e) {
      FlixLogger.instance.e('Failed to play video: $e');
      emit(state.copyWith(
        status: MediaDetailStatus.error,
        errorMessage: 'Failed to play video: $e',
      ));
    }
  }

  void _onRefreshMediaDetail(RefreshMediaDetailEvent event, Emitter<MediaDetailState> emit) async {
    add(LoadMediaDetailEvent(event.mediaId));
  }

  void _onClearNavigation(ClearNavigationEvent event, Emitter<MediaDetailState> emit) {
    emit(state.clearNavigation());
  }
}
