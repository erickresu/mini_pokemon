import 'dart:io';

import 'package:mini_pokemon/services/poke_api_service.dart';

Future<void> main() async {
  final service = PokeApiService();

  try {
    final pokemons = await service.fetchPokemonList(limit: 10, offset: 0);

    stdout.writeln('Pokemon catalog retrieved!');
    stdout.writeln('Total retrieved: ${pokemons.length}');
    stdout.writeln('');

    for (final pokemon in pokemons) {
      stdout.writeln('Name: ${pokemon.name}');
      stdout.writeln('URL: ${pokemon.url}');
      stdout.writeln('--------------------');
    }
  } catch (error) {
    stderr.writeln('Error: $error');
    exitCode = 1;
  }
}
