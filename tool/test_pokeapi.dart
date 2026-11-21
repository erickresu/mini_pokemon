import 'dart:io';

import 'package:mini_pokemon/data/datasources/poke_api_service.dart';

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
    stdout.writeln('Special Attack: ${pokemon.specialAttack}');
    stdout.writeln('Special Defense: ${pokemon.specialDefense}');
    stdout.writeln('Speed: ${pokemon.speed}');
    stdout.writeln('Portrait: ${pokemon.portraitUrl}');
  } catch (error) {
    stderr.writeln('Error: $error');
    exitCode = 1;
  }
}
