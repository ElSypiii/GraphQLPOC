import 'dart:convert';

class Pokemon {
  final int id;
  final String name;
  final String? imageUrl;
  final List<String> types;

  Pokemon({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.types,
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
          // Capitalize the first letter of the type name
          types.add(typeName.capitalize());
        }
      }
    }

    return Pokemon(
      id: id ?? 0,
      name: name?.capitalize() ?? '',
      imageUrl: imageUrl,
      types: types,
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }
}