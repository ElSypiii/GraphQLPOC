import 'package:flutter/foundation.dart';
import 'pokemon_model.dart';

class FavoritesModel extends ChangeNotifier {
  final Set<int> _favoriteIds = <int>{};
  final Map<int, Pokemon> _favoritePokemonMap = <int, Pokemon>{};
  
  Set<int> get favoriteIds => _favoriteIds;

  bool isFavorite(int pokemonId) {
    return _favoriteIds.contains(pokemonId);
  }

  void toggleFavorite(Pokemon pokemon) {
    if (_favoriteIds.contains(pokemon.id)) {
      _favoriteIds.remove(pokemon.id);
      _favoritePokemonMap.remove(pokemon.id);
    } else {
      _favoriteIds.add(pokemon.id);
      _favoritePokemonMap[pokemon.id] = pokemon;
    }
    notifyListeners();
  }

  Set<Pokemon> getFavorites() {
    return _favoritePokemonMap.values.toSet();
  }

  void addFavorite(Pokemon pokemon) {
    _favoriteIds.add(pokemon.id);
    _favoritePokemonMap[pokemon.id] = pokemon;
    notifyListeners();
  }

  void removeFavorite(int pokemonId) {
    _favoriteIds.remove(pokemonId);
    _favoritePokemonMap.remove(pokemonId);
    notifyListeners();
  }
}