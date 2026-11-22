import 'package:flutter_test/flutter_test.dart';

import 'package:mini_pokemon/domain/usecases/collect_pokemon.dart';
import 'package:mini_pokemon/domain/usecases/remove_pokemon.dart';

import '../fakes/fake_collection_repository.dart';

void main() {
  test('remove deletes by API id', () async {
    final repo = FakeCollectionRepository();
    final collect = CollectPokemon(repo);
    final remove = RemovePokemon(repo);

    await collect(testPokemon());
    await remove(1);
    expect(await repo.watchAll().first, isEmpty);
  });
}
