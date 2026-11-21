import 'package:flutter_test/flutter_test.dart';

import 'package:mini_pokemon/domain/usecases/collect_pokemon.dart';

import '../fakes/fake_collection_repository.dart';

void main() {
  test('collect adds once and rejects duplicate API id', () async {
    final repo = FakeCollectionRepository();
    final collect = CollectPokemon(repo);
    final pokemon = testPokemon();

    expect(await collect(pokemon), isTrue);
    expect(await collect(pokemon), isFalse);
    expect((await repo.watchAll().first).length, 1);
  });
}
