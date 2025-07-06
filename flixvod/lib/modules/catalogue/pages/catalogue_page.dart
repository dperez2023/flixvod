import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/catalogue_bloc.dart';
import '../bloc/catalogue_event.dart';
import '../bloc/catalogue_state.dart';
import '../../create/upload_page.dart';
import '../widgets/catalogue_app_bar_widget.dart';
import '../../common/error_state_widget.dart';
import '../../common/empty_state_widget.dart';
import '../widgets/media_list_widget.dart';
import '../../../localization/localized.dart';

class CataloguePage extends StatefulWidget {
  const CataloguePage({super.key});

  @override
  State<CataloguePage> createState() => _CataloguePageState();
}

class _CataloguePageState extends State<CataloguePage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<CatalogueBloc>().add(LoadCatalogue());
  }

  @override
  void dispose() {
    _searchController.dispose();
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
      
      // Only reapply filters if load was successful
      if (bloc.state.status == CatalogueStatus.loaded) {
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
      appBar: CatalogueAppBarWidget(
        searchController: _searchController,
        onSearchChanged: (query) {
          context.read<CatalogueBloc>().add(SearchMedia(query));
        },
        onUpload: _navigateToUpload,
      ),
      body: BlocBuilder<CatalogueBloc, CatalogueState>(
        builder: (context, state) {
          if (_isRefreshing) {
            return const Center(child: CircularProgressIndicator());
          }

          switch (state.status) {
            case CatalogueStatus.initial:
            case CatalogueStatus.loading:
              return const Center(child: CircularProgressIndicator());
            
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
                  // Has data but filtered out - show search/filter empty state
                  return RefreshIndicator(
                    onRefresh: _refreshCatalogue,
                    child: ListView(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.6,
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
                
              return MediaListWidget(
                movies: state.movies,
                series: state.series,
                onRefresh: _refreshCatalogue,
              );
          }
        },
      ),
    );
  }
}
