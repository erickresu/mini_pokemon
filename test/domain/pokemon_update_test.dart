import 'package:flutter_test/flutter_test.dart';
import 'package:mini_pokemon/data/repositories/in_memory_collection_repository.dart';

import '../fakes/fake_collection_repository.dart';

void main() {
  test('copyWith changes editable fields and keeps apiId', () {
    final original = testPokemon();
    final updated = original.copyWith(name: 'Ivysaur', hp: 60, isFavorite: true);

    expect(updated.apiId, original.apiId);
    expect(updated.name, 'Ivysaur');
    expect(updated.hp, 60);
    expect(updated.isFavorite, isTrue);
    expect(original.isFavorite, isFalse);
  });

  test('repository update replaces by apiId and broadcasts', () async {
    final repository = InMemoryCollectionRepository();
    final original = testPokemon();

    final counts = <int>[];
    final names = <String>[];
    final subscription = repository.watchAll().listen((items) {
      counts.add(items.length);
      if (items.isNotEmpty) names.add(items.single.name);
    });
    await Future<void>.delayed(Duration.zero);

    await repository.add(original);
    await repository.update(original.copyWith(name: 'Ivysaur'));
    await Future<void>.delayed(Duration.zero);

    expect(counts, [0, 1, 1]);
    expect(names, ['bulbasaur', 'Ivysaur']);
    await subscription.cancel();
    repository.dispose();
  });
}
