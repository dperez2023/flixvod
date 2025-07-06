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
    
    // Ensure keyboard doesn't auto-show when page loads
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
    final currentState = bloc.state;

    final searchQuery = currentState.searchQuery;
    final typeFilter = currentState.selectedFilter;
    final genreFilter = currentState.selectedGenre;
    
    try {
      bloc.add(LoadCatalogue());
      
      // Waits for the catalogue to load, then apply filters
      await bloc.stream.firstWhere((state) => 
        state.status == CatalogueStatus.loaded || state.status == CatalogueStatus.error
      );
      
      // Only reapply filters if load was successful (and there's actual data)
      if (bloc.state.status == CatalogueStatus.loaded && bloc.state.allMedia.isNotEmpty) {
        if (typeFilter != null) {
          bloc.add(FilterByType(typeFilter));
          await Future.delayed(const Duration(milliseconds: 50));
        }
        
        if (genreFilter != null) {
          bloc.add(FilterByGenre(genreFilter));
          await Future.delayed(const Duration(milliseconds: 50));
        }
        
        if (searchQuery.isNotEmpty) {
          bloc.add(SearchMedia(searchQuery));
        }
      }
    } catch (e) {
      debugPrint('Error during refresh, clearing filters: $e');
      await _clearAllFiltersAndRefresh();
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
            if (_isRefreshing) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppTheme.primaryForegroundColor,
                ),
              );
            }

            switch (state.status) {
              case CatalogueStatus.initial:
              case CatalogueStatus.loading:
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryForegroundColor,
                  ),
                );
              
              case CatalogueStatus.error:
                return ErrorStateWidget(
                  errorMessage: state.errorMessage,
                  onRetry: () {
                    context.read<CatalogueBloc>().add(LoadCatalogue());
                  },
                );
              
              case CatalogueStatus.loaded:
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
                    // Has data but filtered out - show empty
                    return Column(
                      children: [
                        // Always show filters even when no results
                        Container(
                          width: double.infinity,
                          color: AppTheme.primaryBackgroundColor,
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
                            ],
                          ),
                        ),
                        // Pull to Refresh
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: _refreshCatalogue,
                            child: ListView(
                              children: [
                                SizedBox(
                                  height: MediaQuery.of(context).size.height * 0.4,
                                  child: EmptyStateWidget(
                                    icon: Icons.search_off,
                                    message: Localized.of(context).noMediaFound,
                                    subtitle: Localized.of(context).noMediaFoundSubtitle,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                }
                  
                return FilteredMediaListWidget(
                  movies: state.movies,
                  series: state.series,
                  onRefresh: _refreshCatalogue,
                );
            }
          },
        ),
      ),
    );
  }
}
