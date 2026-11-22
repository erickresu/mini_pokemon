import 'package:flutter_test/flutter_test.dart';
import 'package:mini_pokemon/domain/entities/pokemon_summary.dart';
import 'package:mini_pokemon/domain/usecases/search_pokemon.dart';

import '../fakes/fake_catalog_repository.dart';

void main() {
  test('SearchPokemon maps detail to a summary row', () async {
    final catalog = FakeCatalogRepository();

    final result = await SearchPokemon(catalog)('bulbasaur');

    expect(result, isA<PokemonSummary>());
    expect(result.name, 'bulbasaur');
    expect(catalog.names, ['bulbasaur']);
  });
}
