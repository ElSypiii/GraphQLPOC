import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../constants/app_constants.dart';
import '../models/pokemon_model.dart';
import '../models/favorites_model.dart';
import '../blocs/pokemon_bloc.dart';
import '../services/pokemon_service.dart';
import '../utils/type_color_utils.dart';
import 'pokemon_details_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late PokemonBloc _pokemonBloc;
  late ScrollController _scrollController;
  final int _initialLoadLimit = 20;

  @override
  void initState() {
    super.initState();
    final pokemonService = Provider.of<PokemonService>(context, listen: false);
    _pokemonBloc = PokemonBloc(pokemonService);
    _scrollController = ScrollController();
    
    _pokemonBloc.loadMoreSink.add(_initialLoadLimit);

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _pokemonBloc.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 100) {
      _pokemonBloc.loadMoreSink.add(_initialLoadLimit);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
            appBar: AppBar(
              title: const Text(
                kAppName,
                style: TextStyle(
                  fontSize: kTitleFontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              backgroundColor: Colors.deepPurple,
              elevation: 4,
              centerTitle: true,
              actions: [
                IconButton(
                  icon: Icon(Icons.favorite, color: Colors.white),
                  onPressed: () {
                    Navigator.pushNamed(context, '/favorites');
                  },
                ),
              ],
            ),
            body: Container(
              color: Colors.deepPurple.shade50,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    margin: const EdgeInsets.all(kDefaultPadding),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(kCardBorderRadius),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        TextField(
                          decoration: InputDecoration(
                            hintText: 'Search Pokémon...',
                            prefixIcon: Icon(Icons.search, color: Colors.deepPurple),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          onChanged: (val) {
                            _pokemonBloc.searchSink.add(val);
                          },
                        ),
                        const SizedBox(height: 8),
                        StreamBuilder<Set<String>>(
                          stream: _pokemonBloc.typesStream,
                          builder: (context, typesSnapshot) {
                            final allTypes = typesSnapshot.data ?? <String>{};
                            return Row(
                              children: [
                                Expanded(
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          isExpanded: true,
                                          value: _pokemonBloc.currentFilterType,
                                          hint: const Text(
                                            'Filter by Type',
                                            style: TextStyle(color: Colors.grey),
                                          ),
                                          items: allTypes
                                              .map((t) => DropdownMenuItem(
                                                    value: t,
                                                    child: Text(
                                                      t,
                                                      style: TextStyle(
                                                        color: TypeColorUtils.getTypeColor(t),
                                                      ),
                                                    ),
                                                  ))
                                              .toList(),
                                          onChanged: (val) {
                                            _pokemonBloc.filterSink.add(val);
                                          },
                                          icon: Icon(
                                            Icons.arrow_drop_down,
                                            color: Colors.deepPurple,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                if (_pokemonBloc.currentFilterType != null)
                                  IconButton(
                                    icon: Icon(
                                      Icons.clear,
                                      color: Colors.deepPurple,
                                    ),
                                    onPressed: () {
                                      _pokemonBloc.filterSink.add(null);
                                    },
                                  ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: StreamBuilder<List<Pokemon>>(
                      stream: _pokemonBloc.pokemonsStream,
                      builder: (context, pokemonsSnapshot) {
                        if (!pokemonsSnapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final pokemons = pokemonsSnapshot.data ?? [];
                        
                        return StreamBuilder<bool>(
                          stream: _pokemonBloc.loadingStream,
                          builder: (context, loadingSnapshot) {
                            final isLoading = loadingSnapshot.data ?? false;
                            
                            return GridView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(12),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: kGridItemAspectRatio,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                              itemCount: pokemons.length + (isLoading ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == pokemons.length) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                final pokemon = pokemons[index];
                                return Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(kCardBorderRadius),
                                  ),
                                  elevation: 4,
                                  color: Colors.white,
                                  child: Stack(
                                    children: [
                                      InkWell(
                                        borderRadius: BorderRadius.circular(kCardBorderRadius),
                                        onTap: () => _openDetails(context, pokemon),
                                        child: Padding(
                                          padding: const EdgeInsets.all(kDefaultPadding),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Flexible(
                                                child: pokemon.imageUrl != null
                                                    ? ClipRRect(
                                                        borderRadius: BorderRadius.circular(12),
                                                        child: Image.network(
                                                          pokemon.imageUrl!,
                                                          width: kImageSize,
                                                          height: kImageSize,
                                                          fit: BoxFit.contain,
                                                          errorBuilder:
                                                              (context, error, stack) => Icon(
                                                            Icons.image_not_supported,
                                                            size: kErrorIconSize,
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                      )
                                                    : CircleAvatar(
                                                        child: Text(
                                                          pokemon.id.toString(),
                                                        ),
                                                        radius: kAvatarRadius,
                                                      ),
                                              ),
                                              const SizedBox(height: 6),
                                              Flexible(
                                                child: Text(
                                                  pokemon.name,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: kNameFontSize,
                                                    color: Colors.deepPurple,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: Consumer<FavoritesModel>(
                                          builder: (context, favoritesModel, child) {
                                            final isFavorite = favoritesModel.isFavorite(pokemon.id);
                                            return GestureDetector(
                                              onTap: () {
                                                favoritesModel.toggleFavorite(pokemon);
                                              },
                                              child: Container(
                                                padding: const EdgeInsets.all(4),
                                                decoration: BoxDecoration(
                                                  color: Colors.white.withOpacity(0.8),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(
                                                  isFavorite ? Icons.favorite : Icons.favorite_border,
                                                  color: isFavorite ? Colors.red : Colors.grey.shade800,
                                                  size: 16,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  void _openDetails(BuildContext context, Pokemon pokemon) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PokemonDetailsPage(pokemon: pokemon)),
    );
  }
}