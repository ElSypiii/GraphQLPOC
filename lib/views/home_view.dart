import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../models/pokemon_model.dart';
import '../controllers/pokemon_controller.dart';
import '../services/pokemon_service.dart';
import '../utils/type_color_utils.dart';
import 'pokemon_details_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late PokemonController _controller;

  @override
  void initState() {
    super.initState();
    final pokemonService = Provider.of<PokemonService>(context, listen: false);
    _controller = PokemonController(pokemonService);
    _controller.addListener(_onControllerUpdate);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load only 20 pokemons initially for better performance
      _controller.loadMorePokemons(limit: 20);
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerUpdate);
    super.dispose();
  }

  void _onControllerUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<PokemonController>(
        builder: (context, controller, child) {
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
                            controller.setSearchQuery(val);
                          },
                        ),
                        const SizedBox(height: 8),
                        Row(
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
                                      value: controller.filterType,
                                      hint: const Text(
                                        'Filter by Type',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                      items: controller.getAllTypes()
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
                                        controller.setFilterType(val);
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
                            if (controller.filterType != null)
                              IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  color: Colors.deepPurple,
                                ),
                                onPressed: () {
                                  controller.setFilterType(null);
                                },
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: controller.pokemons.isEmpty && controller.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : NotificationListener<ScrollNotification>(
                            onNotification: (scrollInfo) {
                              if (controller.hasMore &&
                                  !controller.isLoading &&
                                  scrollInfo.metrics.pixels >=
                                      scrollInfo.metrics.maxScrollExtent - 100) {
                                controller.loadMorePokemons();
                              }
                              return false;
                            },
                            child: GridView.builder(
                              padding: const EdgeInsets.all(12),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: kGridItemAspectRatio,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                              itemCount: controller.pokemons.length + (controller.hasMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == controller.pokemons.length) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
                                final pokemon = controller.pokemons[index];
                                return Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(kCardBorderRadius),
                                  ),
                                  elevation: 4,
                                  color: Colors.white,
                                  child: InkWell(
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
                                );
                              },
                            ),
                          ),
                  ),
                ],
              ),
            ),
          );
        },
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