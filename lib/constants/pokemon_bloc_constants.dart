class PokemonBlocConstants {
  static const int defaultLoadLimit = 20;
  
  /// Minimum number of matches threshold for loading more Pokemon during search
  static const int minimumMatchesThreshold = 0;
  
  static const int maxLoadLimit = 50;
  
  static const int searchTimeoutMs = 500;
  
  static const Set<String> allPokemonTypes = {
    'Normal', 'Fire', 'Water', 'Electric', 'Grass', 'Ice',
    'Fighting', 'Poison', 'Ground', 'Flying', 'Psychic', 'Bug',
    'Rock', 'Ghost', 'Dragon', 'Dark', 'Steel', 'Fairy'
  };
}