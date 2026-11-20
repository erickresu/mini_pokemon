import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/poke_api_pokemon.dart';
import '../models/poke_api_pokemon_page.dart';
import '../models/poke_api_pokemon_summary.dart';

class PokeApiService {
  static const String _baseUrl = 'https://pokeapi.co/api/v2';

  // Retrieve one Pokemon's complete details.
  Future<PokeApiPokemon> fetchPokemon(String name) async {
    final uri = Uri.parse('$_baseUrl/pokemon/${name.trim().toLowerCase()}');

    final response = await http.get(uri).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;

      return PokeApiPokemon.fromJson(json);
    }

    throw Exception('Failed to fetch Pokemon: ${response.statusCode}');
  }

  // Retrieve a paginated list of Pokemon.
  Future<List<PokeApiPokemonSummary>> fetchPokemonList({
    int limit = 20,
    int offset = 0,
  }) async {
    final page = await fetchPokemonPage(limit: limit, offset: offset);
    return page.results;
  }

  Future<PokeApiPokemonPage> fetchPokemonPage({
    int limit = 20,
    int offset = 0,
  }) async {
    final uri = Uri.parse('$_baseUrl/pokemon').replace(
      queryParameters: {'limit': limit.toString(), 'offset': offset.toString()},
    );

    final response = await http.get(uri).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;

      final results = json['results'] as List;

      return PokeApiPokemonPage(
        results: results
            .map(
              (item) =>
                  PokeApiPokemonSummary.fromJson(item as Map<String, dynamic>),
            )
            .toList(),
        hasMore: (json['next'] as String?) != null,
      );
    }

    throw Exception('Failed to fetch Pokemon list: ${response.statusCode}');
  }
}
