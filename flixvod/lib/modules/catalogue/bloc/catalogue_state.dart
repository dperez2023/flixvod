import 'package:equatable/equatable.dart';
import '../../../models/media.dart';

enum CatalogueStatus { initial, loading, loaded, error }

class CatalogueState extends Equatable {
  final CatalogueStatus status;
  final List<Media> allMedia;
  final List<Media> filteredMedia;
  final MediaType? selectedFilter;
  final String? selectedGenre;
  final String searchQuery;
  final String? errorMessage;

  const CatalogueState({
    this.status = CatalogueStatus.initial,
    this.allMedia = const [],
    this.filteredMedia = const [],
    this.selectedFilter,
    this.selectedGenre,
    this.searchQuery = '',
    this.errorMessage,
  });

  List<Media> get movies => filteredMedia.where((media) => media.isMovie).toList();
  List<Media> get series => filteredMedia.where((media) => media.isSeries).toList();

  CatalogueState copyWith({
    CatalogueStatus? status,
    List<Media>? allMedia,
    List<Media>? filteredMedia,
    MediaType? selectedFilter,
    String? selectedGenre,
    String? searchQuery,
    String? errorMessage,
    bool clearSelectedFilter = false,
    bool clearSelectedGenre = false,
  }) {
    return CatalogueState(
      status: status ?? this.status,
      allMedia: allMedia ?? this.allMedia,
      filteredMedia: filteredMedia ?? this.filteredMedia,
      selectedFilter: clearSelectedFilter ? null : (selectedFilter ?? this.selectedFilter),
      selectedGenre: clearSelectedGenre ? null : (selectedGenre ?? this.selectedGenre),
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        allMedia,
        filteredMedia,
        selectedFilter,
        selectedGenre,
        searchQuery,
        errorMessage,
      ];
}
