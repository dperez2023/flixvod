import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'upload_event.dart';
import 'upload_state.dart';
import '../../../models/media.dart';
import '../../../services/storage/firebase_service.dart';
import '../../../services/video_compression_service.dart';
import '../../../utils/logger.dart';

class UploadBloc extends Bloc<UploadEvent, UploadState> {
  UploadBloc() : super(const UploadState()) {
    on<ValidateFormEvent>(_onValidateForm);
    on<CompressVideoEvent>(_onCompressVideo);
    on<UploadMediaEvent>(_onUploadMedia);
    on<UpdateMediaEvent>(_onUpdateMedia);
    on<ResetUploadEvent>(_onResetUpload);
  }

  void _onValidateForm(ValidateFormEvent event, Emitter<UploadState> emit) {
    emit(state.copyWith(status: UploadStatus.validating));
    
    bool isValid = true;
    String? errorMessage;

    if (event.title.trim().isEmpty) {
      isValid = false;
      errorMessage = 'Title is required';
    }
    
    else if (event.description.trim().isEmpty) {
      isValid = false;
      errorMessage = 'Description is required';
    }
    
    else if (event.genres.isEmpty) {
      isValid = false;
      errorMessage = 'At least one genre must be selected';
    }

    else if (event.video == null && event.type == MediaType.movie) {
      isValid = false;
      errorMessage = 'Video file is required';
    }
    
    else if (event.type == MediaType.series) {
      if (event.episodeVideos.isEmpty || event.episodeVideos.first == null) {
        isValid = false;
        errorMessage = 'At least one episode video is required';
      } else if (event.episodeTitles.isEmpty || event.episodeTitles.first.trim().isEmpty) {
        isValid = false;
        errorMessage = 'Episode titles are required';
      }
    }

    emit(state.copyWith(
      status: isValid ? UploadStatus.initial : UploadStatus.error,
      isFormValid: isValid,
      errorMessage: errorMessage,
    ));
  }

  void _onCompressVideo(CompressVideoEvent event, Emitter<UploadState> emit) async {
    emit(state.copyWith(status: UploadStatus.compressing));
    
    try {
      // Use VideoCompressionService to compress the video
      await VideoCompressionService.compressVideo(
        inputFile: event.videoFile,
      );
      
      emit(state.copyWith(
        status: UploadStatus.initial,
        compressionProgress: 1.0,
      ));
    } catch (e) {
      FlixLogger.instance.e('Video compression error: $e');
      emit(state.copyWith(
        status: UploadStatus.error,
        errorMessage: 'Error compressing video: $e',
      ));
    }
  }

  void _onUploadMedia(UploadMediaEvent event, Emitter<UploadState> emit) async {
    emit(state.copyWith(status: UploadStatus.uploading));
    
    try {
      if (event.type == MediaType.movie) {
        await _uploadMovie(event, emit);
      } else {
        await _uploadSeries(event, emit);
      }
      
      emit(state.copyWith(
        status: UploadStatus.success,
        successMessage: 'Media uploaded successfully!',
        uploadProgress: 1.0,
      ));
    } catch (e) {
      FlixLogger.instance.e('Upload error: $e');
      emit(state.copyWith(
        status: UploadStatus.error,
        errorMessage: 'Upload failed: $e',
      ));
    }
  }

  Future<void> _uploadMovie(UploadMediaEvent event, Emitter<UploadState> emit) async {
    if (event.video == null) {
      throw Exception('Video file is required for movie upload');
    }

    await FirebaseService.uploadVideo(
      videoFile: event.video!,
      title: event.title.trim(),
      description: event.description.trim(),
      type: event.type,
      genres: List.from(event.genres),
      rating: event.rating,
      thumbnailFile: event.thumbnail,
    );
  }

  Future<void> _uploadSeries(UploadMediaEvent event, Emitter<UploadState> emit) async {
    final episodeFiles = event.episodeVideos.where((file) => file != null).cast<File>().toList();
    
    if (episodeFiles.isEmpty) {
      throw Exception('At least one episode video is required');
    }

    await FirebaseService.uploadSeries(
      episodeFiles: episodeFiles,
      title: event.title.trim(),
      description: event.description.trim(),
      genres: List.from(event.genres),
      rating: event.rating,
      thumbnailFile: event.thumbnail,
    );
  }

  void _onUpdateMedia(UpdateMediaEvent event, Emitter<UploadState> emit) async {
    emit(state.copyWith(status: UploadStatus.uploading));
    
    try {
      await FirebaseService.updateMedia(
        mediaId: event.mediaId,
        title: event.title.trim(),
        description: event.description.trim(),
        type: event.type,
        genres: List.from(event.genres),
        rating: event.rating,
      );
      
      emit(state.copyWith(
        status: UploadStatus.success,
        successMessage: 'Media updated successfully!',
      ));
    } catch (e) {
      FlixLogger.instance.e('Update error: $e');
      emit(state.copyWith(
        status: UploadStatus.error,
        errorMessage: 'Update failed: $e',
      ));
    }
  }

  void _onResetUpload(ResetUploadEvent event, Emitter<UploadState> emit) {
    emit(const UploadState());
  }
}
