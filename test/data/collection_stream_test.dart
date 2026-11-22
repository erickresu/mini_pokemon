import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mini_pokemon/data/repositories/in_memory_collection_repository.dart';
import 'package:mini_pokemon/domain/entities/pokemon.dart';
import 'package:mini_pokemon/domain/repositories/collection_repository.dart';

import '../fakes/fake_collection_repository.dart';

Future<void> _checkSnapshotThenUpdate(CollectionRepository repository) async {
  final counts = <int>[];
  late final StreamSubscription<List<Pokemon>> subscription;

  subscription = repository.watchAll().listen((items) {
    counts.add(items.length);
    if (items.isEmpty) {
      unawaited(repository.add(testPokemon()));
    }
  });

  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
  await subscription.cancel();

  expect(counts, [0, 1]);
}

void main() {
  test('production repository emits snapshot and immediate update', () async {
    final repository = InMemoryCollectionRepository();
    await _checkSnapshotThenUpdate(repository);
    repository.dispose();
  });

  test('fake repository emits snapshot and immediate update', () async {
    final repository = FakeCollectionRepository();
    await _checkSnapshotThenUpdate(repository);
    repository.dispose();
  });
}
