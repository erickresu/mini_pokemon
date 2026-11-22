import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:mini_pokemon/domain/entities/pokemon.dart';
import 'package:mini_pokemon/domain/repositories/collection_repository.dart';
import 'package:mini_pokemon/domain/usecases/collect_pokemon.dart';

import '../fakes/fake_collection_repository.dart';

class SlowAddRepository implements CollectionRepository {
  final List<Pokemon> _items = [];
  final StreamController<List<Pokemon>> _controller =
      StreamController<List<Pokemon>>.broadcast();
  final Completer<void> gate = Completer<void>();

  @override
  Stream<List<Pokemon>> watchAll() async* {
    yield List<Pokemon>.unmodifiable(_items);
    yield* _controller.stream;
  }

  @override
  Future<void> add(Pokemon pokemon) async {
    await gate.future;
    _items.add(pokemon);
    _controller.add(List<Pokemon>.unmodifiable(_items));
  }

  @override
  Future<void> update(Pokemon pokemon) async {}

  @override
  Future<void> remove(int apiId) async {}
}

void main() {
  test('collect adds once and rejects duplicate API id', () async {
    final repo = FakeCollectionRepository();
    final collect = CollectPokemon(repo);
    final pokemon = testPokemon();

    expect(await collect(pokemon), isTrue);
    expect(await collect(pokemon), isFalse);
    expect((await repo.watchAll().first).length, 1);
  });

  test('concurrent collect adds once', () async {
    final repo = SlowAddRepository();
    final collect = CollectPokemon(repo);
    final pokemon = testPokemon();

    final first = collect(pokemon);
    final second = collect(pokemon);
    await Future<void>.delayed(Duration.zero);
    repo.gate.complete();

    expect(await first, isTrue);
    expect(await second, isFalse);
    expect((await repo.watchAll().first).length, 1);
  });
}
