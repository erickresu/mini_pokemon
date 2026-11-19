import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/poke_api_pokemon.dart';

class PokeApiService {
  static const String _baseUrl = 'https://pokeapi.co/api/v2';

  Future<PokeApiPokemon> fetchPokemon(String name) async {
    final uri = Uri.parse('$_baseUrl/pokemon/${name.trim().toLowerCase()}');

    final response = await http.get(uri).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;

      return PokeApiPokemon.fromJson(json);
    }

    throw Exception('Failed to fetch Pokemon: ${response.statusCode}');
  }
}
