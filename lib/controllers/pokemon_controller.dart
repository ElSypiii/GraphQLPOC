import 'package:flutter/foundation.dart';
import '../models/pokemon_model.dart';
import '../services/pokemon_service.dart';

class PokemonController extends ChangeNotifier {
  final PokemonService _pokemonService;
  
  List<Pokemon> _allPokemons = [];
  List<Pokemon> _filteredPokemons = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _offset = 0;
  String _searchQuery = '';
  String? _filterType;
  
  PokemonController(this._pokemonService) {
    _filteredPokemons = _allPokemons;
  }

  List<Pokemon> get pokemons => _filteredPokemons;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  String get searchQuery => _searchQuery;
  String? get filterType => _filterType;

  Future<void> loadMorePokemons({int limit = 50}) async {
    if (!_hasMore || _isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      final newPokemons = await _pokemonService.fetchPokemons(
        limit: limit,
        offset: _offset,
      );

      _allPokemons.addAll(newPokemons);
      _updateFilteredPokemons();

      _offset += limit;
      _hasMore = newPokemons.length == limit;
    } catch (e) {
      print('Error loading pokemons: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _updateFilteredPokemons();
    notifyListeners();
  }

  void setFilterType(String? type) {
    _filterType = type;
    _updateFilteredPokemons();
    notifyListeners();
  }


  Set<String> getAllTypes() {
    return _pokemonService.getAllTypes(_allPokemons);
  }

  // Async method to get types that will trigger loading if needed
  Future<Set<String>> getAllTypesAsync() async {
    if (_allPokemons.isEmpty) {
      // Load some initial data if needed
      await loadMorePokemons();
    }
    return getAllTypes();
  }

  void _updateFilteredPokemons() {
    _filteredPokemons = _pokemonService.filterPokemons(
      _allPokemons,
      searchQuery: _searchQuery,
      filterType: _filterType,
    );
  }
}