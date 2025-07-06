import 'package:equatable/equatable.dart';

enum UploadStatus {
  initial,
  validating,
  compressing,
  uploading,
  success,
  error,
}

class UploadState extends Equatable {
  final UploadStatus status;
  final String? errorMessage;
  final double? compressionProgress;
  final double? uploadProgress;
  final String? successMessage;
  final bool isFormValid;

  const UploadState({
    this.status = UploadStatus.initial,
    this.errorMessage,
    this.compressionProgress,
    this.uploadProgress,
    this.successMessage,
    this.isFormValid = false,
  });

  UploadState copyWith({
    UploadStatus? status,
    String? errorMessage,
    double? compressionProgress,
    double? uploadProgress,
    String? successMessage,
    bool? isFormValid,
  }) {
    return UploadState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      compressionProgress: compressionProgress ?? this.compressionProgress,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      successMessage: successMessage,
      isFormValid: isFormValid ?? this.isFormValid,
    );
  }

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    compressionProgress,
    uploadProgress,
    successMessage,
    isFormValid,
  ];
}
