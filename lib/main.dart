import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'constants/app_constants.dart';
import 'models/pokemon_model.dart';
import 'services/pokemon_service.dart';
import 'controllers/pokemon_controller.dart';
import 'utils/type_color_utils.dart';

void main() async {
  await initHiveForFlutter();
  final HttpLink httpLink = HttpLink(kPokemonApiUrl);

  ValueNotifier<GraphQLClient> client = ValueNotifier(
    GraphQLClient(
      link: httpLink,
      cache: GraphQLCache(store: HiveStore()),
    ),
  );

  final pokemonService = PokemonService(client.value);

  runApp(MyApp(client: client, pokemonService: pokemonService));
}

class MyApp extends StatelessWidget {
  final ValueNotifier<GraphQLClient> client;
  final PokemonService pokemonService;

  const MyApp({Key? key, required this.client, required this.pokemonService}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: client,
      child: Provider<PokemonService>.value(
        value: pokemonService,
        child: MaterialApp(
          home: HomeScreen(pokemonService: pokemonService),
          debugShowCheckedModeBanner: false, // Remove debug banner
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final PokemonService pokemonService;

  const HomeScreen({Key? key, required this.pokemonService}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late PokemonController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PokemonController(widget.pokemonService);
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

  // This method is now available via TypeColorUtils

  void openDetails(BuildContext context, Pokemon pokemon) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PokemonDetailsPage(pokemon: pokemon)),
    );
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
                      _controller.setSearchQuery(val);
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
                                value: _controller.filterType,
                                hint: const Text(
                                  'Filter by Type',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                items: _controller.getAllTypes()
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
                                  _controller.setFilterType(val);
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
                      if (_controller.filterType != null)
                        IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: Colors.deepPurple,
                          ),
                          onPressed: () {
                            _controller.setFilterType(null);
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: _controller.pokemons.isEmpty && _controller.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : NotificationListener<ScrollNotification>(
                      onNotification: (scrollInfo) {
                        if (_controller.hasMore &&
                            !_controller.isLoading &&
                            scrollInfo.metrics.pixels >=
                                scrollInfo.metrics.maxScrollExtent - 100) {
                          _controller.loadMorePokemons();
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
                        itemCount: _controller.pokemons.length + (_controller.hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _controller.pokemons.length) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          final pokemon = _controller.pokemons[index];
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(kCardBorderRadius),
                            ),
                            elevation: 4,
                            color: Colors.white,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(kCardBorderRadius),
                              onTap: () => openDetails(context, pokemon),
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
  }
}

class PokemonDetailsPage extends StatelessWidget {
  final Pokemon pokemon;
  const PokemonDetailsPage({required this.pokemon, Key? key}) : super(key: key);

  // This method is now available via TypeColorUtils

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          pokemon.name,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 4,
        iconTheme: const IconThemeData(
          color: Colors.white, // Change back arrow color to white
        ),
      ),
      body: Container(
        color: Colors.deepPurple.shade50,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 8,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: pokemon.imageUrl != null
                        ? Image.network(
                            pokemon.imageUrl!,
                            width: double.infinity,
                            height: 250,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            height: 250,
                            color: Colors.grey.shade300,
                            child: CircleAvatar(
                              child: Text(pokemon.id.toString()),
                              radius: 60,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Text(
                          pokemon.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 28,
                            color: Colors.deepPurple,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Pokédex ID: #${pokemon.id.toString().padLeft(3, '0')}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Types',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.deepPurple.shade700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: pokemon.types
                              .map(
                                (type) => Container(
                                  decoration: BoxDecoration(
                                    color: TypeColorUtils.getTypeColor(type.toLowerCase()).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: TypeColorUtils.getTypeColor(type.toLowerCase()),
                                      width: 1,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    child: Text(
                                      type,
                                      style: TextStyle(
                                        color: TypeColorUtils.getTypeColor(type.toLowerCase()),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (pokemon.moves.isNotEmpty)
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Moves',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.deepPurple.shade700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: pokemon.moves.take(12).map((move) => 
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.deepPurple.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  move,
                                  style: TextStyle(
                                    color: Colors.deepPurple.shade800,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
