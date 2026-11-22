import 'dart:io';

import 'package:mini_pokemon/data/datasources/poke_api_service.dart';

Future<void> main() async {
  final service = PokeApiService();

  try {
    final page = await service.fetchPage(limit: 10, offset: 0);

    stdout.writeln('Pokemon catalog retrieved!');
    stdout.writeln('Total retrieved: ${page.results.length}');
    stdout.writeln('');

    for (final pokemon in page.results) {
      stdout.writeln('Name: ${pokemon.name}');
      stdout.writeln('URL: ${pokemon.url}');
      stdout.writeln('--------------------');
    }
  } catch (error) {
    stderr.writeln('Error: $error');
    exitCode = 1;
  }
}
