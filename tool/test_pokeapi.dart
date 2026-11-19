import 'dart:io';

import 'package:mini_pokemon/services/poke_api_service.dart';

Future<void> main() async {
  final service = PokeApiService();

  try {
    final pokemon = await service.fetchPokemon('charmander');

    stdout.writeln('API request successful!');
    stdout.writeln('ID: ${pokemon.id}');
    stdout.writeln('Name: ${pokemon.name}');
    stdout.writeln('Types: ${pokemon.types.join(', ')}');
    stdout.writeln('HP: ${pokemon.hp}');
    stdout.writeln('Attack: ${pokemon.attack}');
    stdout.writeln('Defense: ${pokemon.defense}');
    stdout.writeln('Image: ${pokemon.imageUrl}');
  } catch (error) {
    stderr.writeln('Error: $error');
    exitCode = 1;
  }
}
