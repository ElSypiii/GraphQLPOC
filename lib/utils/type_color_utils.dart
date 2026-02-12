import 'package:flutter/material.dart';

class TypeColorUtils {
  static Color getTypeColor(String typeName) {
    switch (typeName.toLowerCase()) {
      case 'normal':
        return Colors.brown.shade300;
      case 'fire':
        return Colors.orange;
      case 'water':
        return Colors.blue;
      case 'electric':
        return Colors.yellow.shade700;
      case 'grass':
        return Colors.green;
      case 'ice':
        return Colors.cyan;
      case 'fighting':
        return Colors.red.shade800;
      case 'poison':
        return Colors.purple;
      case 'ground':
        return Colors.orange.shade800;
      case 'flying':
        return Colors.indigo;
      case 'psychic':
        return Colors.pink;
      case 'bug':
        return Colors.lightGreen;
      case 'rock':
        return Colors.yellow.shade800;
      case 'ghost':
        return Colors.purple.shade800;
      case 'dragon':
        return Colors.indigo.shade800;
      case 'dark':
        return Colors.brown.shade800;
      case 'steel':
        return Colors.grey.shade600;
      case 'fairy':
        return Colors.pink.shade300;
      default:
        return Colors.grey;
    }
  }
}