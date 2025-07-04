import 'package:flutter_bloc/flutter_bloc.dart';
import 'catalogue_event.dart';
import 'catalogue_state.dart';
import '../models/media.dart';
import '../services/firebase_service.dart';
import '../services/cache_service.dart';
import '../logger.dart';

class CatalogueBloc extends Bloc<CatalogueEvent, CatalogueState> {
  CatalogueBloc() : super(const CatalogueState()) {
    on<LoadCatalogue>(_onLoadCatalogue);
    on<FilterByType>(_onFilterByType);
    on<SearchMedia>(_onSearchMedia);
  }

  void _onLoadCatalogue(LoadCatalogue event, Emitter<CatalogueState> emit) async {
    emit(state.copyWith(status: CatalogueStatus.loading));
    
    try {
      /// Cache first, then remote (if online)
      final cachedMedia = await CacheService.getCachedMediaList();
      
      if (cachedMedia != null && cachedMedia.isNotEmpty) {
        logger.d('Loading ${cachedMedia.length} media items from cache');
        emit(state.copyWith(
          status: CatalogueStatus.loaded,
          allMedia: cachedMedia,
          filteredMedia: cachedMedia,
        ));
        return;
      }
      
      // Load media from Firebase if no cache
      logger.d('No cache found, loading from Firebase');
      final mediaList = await FirebaseService.getAllMedia();
      
      if (mediaList.isNotEmpty) {
        // Cache the data for future use
        await CacheService.cacheMediaList(mediaList);
        logger.d('Loaded ${mediaList.length} media items from Firebase');
        
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
