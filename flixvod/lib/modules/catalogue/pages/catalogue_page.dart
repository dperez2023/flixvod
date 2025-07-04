import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/catalogue_bloc.dart';
import '../bloc/catalogue_event.dart';
import '../bloc/catalogue_state.dart';
import '../../pages/upload_page.dart';
import '../widgets/catalogue_app_bar_widget.dart';
import '../../widgets/error_state_widget.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/media_list_widget.dart';
import '../../utils/localized.dart';

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

  void _refreshCatalogue() {
    context.read<CatalogueBloc>().add(LoadCatalogue());
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
        onRefresh: _refreshCatalogue,
        onUpload: _navigateToUpload,
      ),
      body: BlocBuilder<CatalogueBloc, CatalogueState>(
        builder: (context, state) {
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
                  // Empty state with refresh
                  return EmptyStateWidget(
                    icon: Icons.video_library_outlined,
                    message: Localized.of(context).noMediaAvailable,
                    subtitle: Localized.of(context).noMediaAvailableSubtitle,
                    onRefresh: _refreshCatalogue,
                    refreshButtonText: Localized.of(context).refresh,
                  );
                } else {
                  // Has data but filtered out - show search/filter empty state
                  return EmptyStateWidget(
                    icon: Icons.search_off,
                    message: Localized.of(context).noMediaFound,
                    subtitle: Localized.of(context).noMediaFoundSubtitle,
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
