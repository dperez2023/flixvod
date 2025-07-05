import 'package:flutter_bloc/flutter_bloc.dart';
import 'catalogue_event.dart';
import 'catalogue_state.dart';
import '../../../models/media.dart';
import '../../../services/storage/firebase_service.dart';
import '../../../services/cache_service.dart';
import '../../../logger.dart';

class CatalogueBloc extends Bloc<CatalogueEvent, CatalogueState> {
  CatalogueBloc() : super(const CatalogueState()) {
    on<LoadCatalogue>(_onLoadCatalogue);
    on<RefreshCatalogue>(_onRefreshCatalogue);
    on<FilterByType>(_onFilterByType);
    on<FilterByGenre>(_onFilterByGenre);
    on<SearchMedia>(_onSearchMedia);
  }

  void _onLoadCatalogue(LoadCatalogue event, Emitter<CatalogueState> emit) async {
    emit(state.copyWith(status: CatalogueStatus.loading));
    
    try {
      /// Cache first, then remote (if online)
      final cachedMedia = await CacheService.getCachedMediaList();
      
      if (cachedMedia != null && cachedMedia.isNotEmpty) {
        emit(state.copyWith(
          status: CatalogueStatus.loaded,
          allMedia: cachedMedia,
          filteredMedia: cachedMedia,
        ));
        return;
      }
      
      // Load media from Firebase if no cache
      final mediaList = await FirebaseService.getAllMedia();
      
      if (mediaList.isNotEmpty) {
        // Cache the data for future use
        await CacheService.cacheMediaList(mediaList);
        
        emit(state.copyWith(
          status: CatalogueStatus.loaded,
          allMedia: mediaList,
          filteredMedia: mediaList,
        ));
      } else {
        // No data available - show empty state
        logger.w('No media found in Firebase');
        emit(state.copyWith(
          status: CatalogueStatus.loaded,
          allMedia: [],
          filteredMedia: [],
        ));
      }
    } catch (e, stackTrace) {
      // Error occurred - show error state with retry option
      logger.e('Failed to load catalogue: $e', stackTrace);
      emit(state.copyWith(
        status: CatalogueStatus.error,
        errorMessage: 'Failed to load media. Please check your connection and try again.',
      ));
    }
  }

  void _onRefreshCatalogue(RefreshCatalogue event, Emitter<CatalogueState> emit) async {
    emit(state.copyWith(status: CatalogueStatus.loading));
    
    try {
      final mediaList = await FirebaseService.refreshAllMedia();
      
      emit(state.copyWith(
        status: CatalogueStatus.loaded,
        allMedia: mediaList,
        filteredMedia: mediaList,
      ));
    } catch (e, stackTrace) {
      // Error occurred - show error state with retry option
      logger.e('Failed to refresh catalogue: $e', stackTrace);
      emit(state.copyWith(
        status: CatalogueStatus.error,
        errorMessage: 'Failed to refresh media. Please check your connection and try again.',
      ));
    }
  }

  void _onFilterByType(FilterByType event, Emitter<CatalogueState> emit) {
    List<Media> filtered;
    
    if (event.type == null) {
      filtered = state.allMedia;
    } else {
      filtered = state.allMedia.where((media) => media.type == event.type).toList();
    }
    
    // Apply search filter if there's a search query
    if (state.searchQuery.isNotEmpty) {
      filtered = filtered.where((media) => 
        media.title.toLowerCase().contains(state.searchQuery.toLowerCase()) ||
        media.description.toLowerCase().contains(state.searchQuery.toLowerCase())
      ).toList();
    }
    
    emit(state.copyWith(
      selectedFilter: event.type,
      filteredMedia: filtered,
    ));
  }

  void _onFilterByGenre(FilterByGenre event, Emitter<CatalogueState> emit) {
    List<Media> filtered;
    
    if (event.genre == null) {
      filtered = state.allMedia;
    } else {
      filtered = state.allMedia.where((media) => 
        media.genres.contains(event.genre)
      ).toList();
    }
    
    if (state.selectedFilter != null) {
      filtered = filtered.where((media) => media.type == state.selectedFilter).toList();
    }
    
    if (state.searchQuery.isNotEmpty) {
      filtered = filtered.where((media) => 
        media.title.toLowerCase().contains(state.searchQuery.toLowerCase()) ||
        media.description.toLowerCase().contains(state.searchQuery.toLowerCase())
      ).toList();
    }
    
    // TODO: Is it needed to copy with?
    emit(state.copyWith(
      selectedGenre: event.genre,
      filteredMedia: filtered,
    ));
  }

  void _onSearchMedia(SearchMedia event, Emitter<CatalogueState> emit) {
    List<Media> filtered = state.allMedia;
    
    // Apply type filter if selected
    if (state.selectedFilter != null) {
      filtered = filtered.where((media) => media.type == state.selectedFilter).toList();
    }
    
    // Apply search filter
    if (event.query.isNotEmpty) {
      filtered = filtered.where((media) => 
        media.title.toLowerCase().contains(event.query.toLowerCase()) ||
        media.description.toLowerCase().contains(event.query.toLowerCase())
      ).toList();
    }
    
    emit(state.copyWith(
      searchQuery: event.query,
      filteredMedia: filtered,
    ));
  }
}
