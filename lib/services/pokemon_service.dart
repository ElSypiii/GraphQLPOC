import 'package:graphql_flutter/graphql_flutter.dart';
import '../models/pokemon_model.dart';

class PokemonService {
  final GraphQLClient _client;

  PokemonService(this._client);

  Future<List<Pokemon>> fetchPokemons({int limit = 50, int offset = 0}) async {
    final fetchPokemon = """
      query GetPokemon(\$limit: Int!, \$offset: Int!) {
        pokemon_v2_pokemon(limit: \$limit, offset: \$offset) {
          id
          name
          pokemon_v2_pokemonsprites {
            sprites
          }
          pokemon_v2_pokemontypes {
            pokemon_v2_type {
              name
            }
          }
        }
      }
    """;

    final result = await _client.query(
      QueryOptions(
        document: gql(fetchPokemon),
        variables: {'limit': limit, 'offset': offset},
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final pokemonList = <Pokemon>[];
    final rawPokemons = result.data?['pokemon_v2_pokemon'] ?? [];

    for (final rawPokemon in rawPokemons) {
      pokemonList.add(Pokemon.fromJson(rawPokemon));
    }

    return pokemonList;
  }

  List<Pokemon> filterPokemons(List<Pokemon> pokemons, {String? searchQuery, String? filterType}) {
    var filteredPokemons = pokemons;

    if (searchQuery != null && searchQuery.isNotEmpty) {
      filteredPokemons = filteredPokemons
          .where((p) => p.name.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }

    if (filterType != null && filterType.isNotEmpty) {
      filteredPokemons = filteredPokemons
          .where((p) => p.types.contains(filterType))
          .toList();
    }

    return filteredPokemons;
  }

  Set<String> getAllTypes(List<Pokemon> pokemons) {
    final types = <String>{};
    for (final pokemon in pokemons) {
      types.addAll(pokemon.types);
    }
    return types;
  }
}