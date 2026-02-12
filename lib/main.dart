import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'constants/app_constants.dart';
import 'services/pokemon_service.dart';
import 'views/home_view.dart';

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

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: client,
      child: Provider<PokemonService>.value(
        value: pokemonService,
        child: MaterialApp(
          home: HomeView(),
          debugShowCheckedModeBanner: false, 
        ),
      ),
    );
  }
}