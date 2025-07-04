import 'package:equatable/equatable.dart';
import '../../../models/media.dart';

abstract class CatalogueEvent extends Equatable {
  const CatalogueEvent();

  @override
  List<Object> get props => [];
}

class LoadCatalogue extends CatalogueEvent {
  
}

class FilterByType extends CatalogueEvent {
  final MediaType? type;

  const FilterByType(this.type);

  @override
  List<Object> get props => type != null ? [type!] : [];
}

class SearchMedia extends CatalogueEvent {
  final String query;

  const SearchMedia(this.query);

  @override
  List<Object> get props => [query];
}

class FilterByGenre extends CatalogueEvent {
  final String? genre;

  const FilterByGenre(this.genre);

  @override
  List<Object> get props => genre != null ? [genre!] : [];
}
