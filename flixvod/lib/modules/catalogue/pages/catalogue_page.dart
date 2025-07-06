import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/catalogue_bloc.dart';
import '../bloc/catalogue_event.dart';
import '../bloc/catalogue_state.dart';
import '../../create/upload_page.dart';
import '../widgets/catalogue_app_bar_widget.dart';
import '../../common/error_state_widget.dart';
import '../../common/empty_state_widget.dart';
import '../widgets/filtered_media_list_widget.dart';
import '../widgets/filter_chips_widget.dart';
import '../../../localization/localized.dart';
import '../../../core/app_theme.dart';
import '../../../models/media.dart';
import '../../../services/storage/firebase_service.dart';
import '../../../services/cache_service.dart';

class CataloguePage extends StatefulWidget {
  const CataloguePage({super.key});

  @override
  State<CataloguePage> createState() => _CataloguePageState();
}

class _CataloguePageState extends State<CataloguePage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    context.read<CatalogueBloc>().add(LoadCatalogue());
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.unfocus();
      FocusScope.of(context).unfocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  bool _isRefreshing = false;

  Future<void> _refreshCatalogue() async {
    if (_isRefreshing) return;
    
    setState(() {
      _isRefreshing = true;
    });
    
    final bloc = context.read<CatalogueBloc>();
    
    try {
      // Clear cache first to force fresh data fetch
      await CacheService.clearCache();
      
      // Then use LoadCatalogue which will preserve filters
      bloc.add(LoadCatalogue());
      
      // Wait for completion
      await bloc.stream.firstWhere((state) => 
        state.status == CatalogueStatus.loaded || state.status == CatalogueStatus.error
      );
    } catch (e) {
      debugPrint('Error during refresh: $e');
    } finally {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  Future<void> _clearAllFiltersAndRefresh() async {
    if (_isRefreshing) return;
    
    setState(() {
      _isRefreshing = true;
    });
    
    final bloc = context.read<CatalogueBloc>();
    
    try {
      // Clear search text
      _searchController.clear();
      bloc.add(LoadCatalogue());
      
      await bloc.stream.firstWhere((state) => 
        state.status == CatalogueStatus.loaded || state.status == CatalogueStatus.error
      );
      
      // Clear all filters after load is complete
      if (bloc.state.status == CatalogueStatus.loaded) {
        bloc.add(FilterByType(null)); // Clear type filter
        await Future.delayed(const Duration(milliseconds: 50));
        
        bloc.add(FilterByGenre(null)); // Clear genre filter
        await Future.delayed(const Duration(milliseconds: 50));
        
        bloc.add(SearchMedia('')); // Clear search
      }
    } finally {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  Future<void> _navigateToUpload() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const UploadPage(),
      ),
    );
    
    // If upload was successful, refresh the catalogue
    if (result == true) {
      _refreshCatalogue();
    }
  }  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBackgroundColor,
      appBar: CatalogueAppBarWidget(
        searchController: _searchController,
        searchFocusNode: _searchFocusNode,
        onSearchChanged: (query) {
          context.read<CatalogueBloc>().add(SearchMedia(query));
        },
        onUpload: _navigateToUpload,
      ),
      body: GestureDetector(
        onTap: () {
          _searchFocusNode.unfocus();
          FocusScope.of(context).unfocus();
        },
        child: BlocBuilder<CatalogueBloc, CatalogueState>(
          builder: (context, state) {
            switch (state.status) {
              case CatalogueStatus.initial:
              case CatalogueStatus.loading:
                // Show loading only if not refreshing (to preserve filter UI during refresh)
                if (!_isRefreshing) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryForegroundColor,
                    ),
                  );
                }
                // If refreshing, fall through to show the current content with loading indicator
                break;
              
              case CatalogueStatus.error:
                return ErrorStateWidget(
                  errorMessage: state.errorMessage,
                  onRetry: () {
                    context.read<CatalogueBloc>().add(LoadCatalogue());
                  },
                );
              
              case CatalogueStatus.loaded:
                break;
            }

            // Handle loaded state and refreshing state with existing content
            if (state.filteredMedia.isEmpty) {
                  // Check if this is due to search/filter or no data
                  if (state.allMedia.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: _refreshCatalogue,
                      child: ListView(
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: EmptyStateWidget(
                              icon: Icons.video_library_outlined,
                              message: Localized.of(context).noMediaAvailable,
                              subtitle: Localized.of(context).noMediaAvailableSubtitle,
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    // Has data but filtered out - show empty with filters
                    return RefreshIndicator(
                      onRefresh: _refreshCatalogue,
                      child: ListView(
                        children: [
                          // Filter Section
                          Container(
                            width: double.infinity,
                            color: AppTheme.primaryBackgroundColor,
                            padding: const EdgeInsets.only(top: AppTheme.smallVerticalSpacerHeight),
                            child: Column(
                              children: [
                                // Filter Chips for Media Types
                                BlocBuilder<CatalogueBloc, CatalogueState>(
                                  builder: (context, state) {
                                    const availableTypes = [MediaType.movie, MediaType.series];

                                    return FilterChipsWidget<MediaType>(
                                      availableOptions: availableTypes,
                                      selectedOption: state.selectedFilter,
                                      onFilterChanged: (type) {
                                        context.read<CatalogueBloc>().add(FilterByType(type));
                                      },
                                      getOptionLabel: (context, type) {
                                        switch (type) {
                                          case MediaType.movie:
                                            return Localized.of(context).movies;
                                          case MediaType.series:
                                            return Localized.of(context).series;
                                        }
                                      },
                                      allLabel: Localized.of(context).all,
                                    );
                                  },
                                ),
                                AppTheme.tinyVerticalSpacer,
                                // Filter Chips for Genres
                                BlocBuilder<CatalogueBloc, CatalogueState>(
                                  builder: (context, state) {
                                    return FilterChipsWidget<String>(
                                      availableOptions: FirebaseService.availableGenres,
                                      selectedOption: state.selectedGenre,
                                      onFilterChanged: (genre) {
                                        context.read<CatalogueBloc>().add(FilterByGenre(genre));
                                      },
                                      getOptionLabel: (context, genre) => genre,
                                      allLabel: Localized.of(context).allGenres,
                                    );
                                  },
                                ),
                                AppTheme.mediumVerticalSpacer,
                              ],
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.5,
                            child: EmptyStateWidget(
                              icon: Icons.search_off,
                              message: Localized.of(context).noMediaFound,
                              subtitle: Localized.of(context).noMediaFoundSubtitle,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                }
                  
                return FilteredMediaListWidget(
                  movies: state.movies,
                  series: state.series,
                  onRefresh: _refreshCatalogue,
                );
          },
        ),
      ),
    );
  }
}
