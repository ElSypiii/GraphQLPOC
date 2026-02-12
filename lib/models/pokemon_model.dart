import 'dart:convert';

class Pokemon {
  final int id;
  final String name;
  final String? imageUrl;
  final List<String> types;
  final List<String> moves;

  Pokemon({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.types,
    this.moves = const [],
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as int?;
    final name = json['name'] as String?;
    
    String? imageUrl;
    if (json['pokemon_v2_pokemonsprites'] != null &&
        json['pokemon_v2_pokemonsprites'] is List &&
        (json['pokemon_v2_pokemonsprites'] as List).isNotEmpty) {
      final spritesJson = json['pokemon_v2_pokemonsprites'][0]['sprites'];
      if (spritesJson != null) {
        Map<String, dynamic> sprites;
        if (spritesJson is String) {
          sprites = Map<String, dynamic>.from(jsonDecode(spritesJson));
        } else {
          sprites = Map<String, dynamic>.from(spritesJson);
        }
        imageUrl = sprites['front_default'];
      }
    }

    final types = <String>[];
    if (json['pokemon_v2_pokemontypes'] != null) {
      for (final typeData in json['pokemon_v2_pokemontypes']) {
        final typeName = typeData['pokemon_v2_type']['name'] as String?;
        if (typeName != null) {
          types.add(typeName.capitalize());
        }
      }
    }

    final moves = <String>[];
    if (json['pokemon_v2_pokemonmoves'] != null) {
      for (final moveData in json['pokemon_v2_pokemonmoves']) {
        final moveName = moveData['pokemon_v2_move']['name'] as String?;
        if (moveName != null) {
          moves.add(moveName.split('-').map((word) => '${word[0].toUpperCase()}${word.substring(1)}').join(' '));
        }
      }
    }

    return Pokemon(
      id: id ?? 0,
      name: name?.capitalize() ?? '',
      imageUrl: imageUrl,
      types: types,
      moves: moves,
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }
}