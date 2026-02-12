import 'package:flutter/material.dart';
import '../models/pokemon_model.dart';
import '../utils/type_color_utils.dart';

class PokemonDetailsPage extends StatelessWidget {
  final Pokemon pokemon;
  const PokemonDetailsPage({required this.pokemon, Key? key}) : super(key: key);

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
          color: Colors.white, 
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