import 'package:flutter_test/flutter_test.dart';
import 'package:mini_pokemon/domain/usecases/toggle_favorite.dart';
import 'package:mini_pokemon/domain/usecases/update_pokemon.dart';

import '../fakes/fake_collection_repository.dart';

void main() {
  test('UpdatePokemon forwards the updated entity', () async {
    final repository = FakeCollectionRepository();
    final pokemon = testPokemon();
    await repository.add(pokemon);

    await UpdatePokemon(repository)(pokemon.copyWith(name: 'Ivysaur'));

    expect((await repository.watchAll().first).single.name, 'Ivysaur');
  });

  test('ToggleFavorite flips only the favorite flag', () async {
    final repository = FakeCollectionRepository();
    final pokemon = testPokemon();
    await repository.add(pokemon);

    await ToggleFavorite(repository)(pokemon);
    final updated = (await repository.watchAll().first).single;

    expect(updated.apiId, pokemon.apiId);
    expect(updated.name, pokemon.name);
    expect(updated.isFavorite, isTrue);
  });
}
