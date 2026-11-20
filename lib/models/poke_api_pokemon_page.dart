import 'poke_api_pokemon_summary.dart';

class PokeApiPokemonPage {
  const PokeApiPokemonPage({required this.results, required this.hasMore});

  final List<PokeApiPokemonSummary> results;
  final bool hasMore;
}
