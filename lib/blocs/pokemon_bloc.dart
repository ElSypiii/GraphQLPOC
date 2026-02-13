import 'dart:async';
import '../models/pokemon_model.dart';
import '../services/pokemon_service.dart';
import '../constants/pokemon_bloc_constants.dart';

class PokemonBloc {
  final PokemonService _pokemonService;

  PokemonBloc(this._pokemonService) {
    _setupStreamListeners();
  }

  // Streams to emit data
  final _pokemonsController = StreamController<List<Pokemon>>();
  final _loadingController = StreamController<bool>();
  final _hasMoreController = StreamController<bool>();
  final _errorController = StreamController<String?>();
  final _typesController = StreamController<Set<String>>();

  // Sinks to receive data
  final _searchController = StreamController<String>();
  final _filterController = StreamController<String?>();
  final _loadMoreController = StreamController<int>();

  // Public access to streams
  Stream<List<Pokemon>> get pokemonsStream => _pokemonsController.stream;
  Stream<bool> get loadingStream => _loadingController.stream;
  Stream<bool> get hasMoreStream => _hasMoreController.stream;
  Stream<String?> get errorStream => _errorController.stream;
  Stream<Set<String>> get typesStream => _typesController.stream;

  // Public access to sinks
  Sink<String> get searchSink => _searchController.sink;
  Sink<String?> get filterSink => _filterController.sink;
  Sink<int> get loadMoreSink => _loadMoreController.sink;

  // Private variables to hold state
  List<Pokemon> _allPokemons = [];
  List<Pokemon> _filteredPokemons = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _offset = 0;
  String _searchQuery = '';
  String? _filterType;

  String? get currentFilterType => _filterType;

  List<Pokemon> get allPokemons => _allPokemons;

  void _setupStreamListeners() {
    _searchController.stream.listen((query) {
      _searchQuery = query;
      _updateFilteredPokemons();

      // If the search results in a list that's too small to scroll,
      // and we have more to load, trigger loading more. This kicks off
      // a potential chain of loading handled in `_loadMorePokemons`.
      if (query.isNotEmpty &&
          _hasMore &&
          !_isLoading &&
          _filteredPokemons.length < PokemonBlocConstants.defaultLoadLimit) {
        _loadMorePokemons(PokemonBlocConstants.defaultLoadLimit);
      }
    });

    _filterController.stream.listen((filter) {
      _filterType = filter;
      _updateFilteredPokemons();
    });

    _loadMoreController.stream.listen((limit) {
      _loadMorePokemons(limit);
    });
  }

  void _updateFilteredPokemons() {
    var pokemons = _allPokemons;

    if (_searchQuery.isNotEmpty) {
      pokemons = pokemons
          .where(
            (p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    if (_filterType != null && _filterType!.isNotEmpty) {
      pokemons = pokemons.where((p) => p.types.contains(_filterType)).toList();
    }

    _filteredPokemons = pokemons;
    _pokemonsController.sink.add(_filteredPokemons);

    // Update types stream with ALL possible types, not just from currently loaded pokemons
    // For now, we'll use all types from all loaded pokemons, but in a real app you might want
    // to load all possible types separately
    final allTypes = <String>{};
    for (final pokemon in _allPokemons) {
      allTypes.addAll(pokemon.types);
    }
    _typesController.sink.add(allTypes);
  }

  Future<void> _loadMorePokemons([int? limit]) async {
    final effectiveLimit = limit ?? PokemonBlocConstants.defaultLoadLimit;
    if (!_hasMore || _isLoading) return;

    _isLoading = true;
    _loadingController.sink.add(_isLoading);

    try {
      final newPokemons = await _pokemonService.fetchPokemons(
        limit: effectiveLimit,
        offset: _offset,
      );

      _allPokemons.addAll(newPokemons);
      _updateFilteredPokemons();

      _offset += effectiveLimit;
      _hasMore = newPokemons.length == effectiveLimit;
      _hasMoreController.sink.add(_hasMore);
    } catch (e) {
      _errorController.sink.add(e.toString());
    } finally {
      _isLoading = false;
      _loadingController.sink.add(_isLoading);

      // If we are searching and the results are still too few to scroll,
      // and there are more pokemons to fetch, trigger another load.
      if (_searchQuery.isNotEmpty &&
          _hasMore &&
          _filteredPokemons.length < PokemonBlocConstants.defaultLoadLimit) {
        _loadMoreController.sink.add(PokemonBlocConstants.defaultLoadLimit);
      }
    }
  }

  Set<String> getAllTypes() {
    final types = <String>{};
    for (final pokemon in _allPokemons) {
      types.addAll(pokemon.types);
    }
    return types;
  }

  void dispose() {
    _pokemonsController.close();
    _loadingController.close();
    _hasMoreController.close();
    _errorController.close();
    _typesController.close();
    _searchController.close();
    _filterController.close();
    _loadMoreController.close();
  }
}
