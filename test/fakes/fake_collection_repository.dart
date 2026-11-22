import 'dart:async';

import 'package:mini_pokemon/domain/entities/pokemon.dart';
import 'package:mini_pokemon/domain/repositories/collection_repository.dart';

class FakeCollectionRepository implements CollectionRepository {
  bool failAdd = false;
  bool failUpdate = false;
  bool failRemove = false;

  final List<Pokemon> _items = [];
  final StreamController<List<Pokemon>> _controller =
      StreamController<List<Pokemon>>.broadcast();

  @override
  Stream<List<Pokemon>> watchAll() {
    final controller = StreamController<List<Pokemon>>();
    StreamSubscription<List<Pokemon>>? subscription;

    controller.onListen = () {
      subscription = _controller.stream.listen(
        controller.add,
        onError: controller.addError,
        onDone: controller.close,
      );
      scheduleMicrotask(() {
        if (!controller.isClosed) {
          controller.add(List<Pokemon>.unmodifiable(_items));
        }
      });
    };
    controller.onCancel = () {
      unawaited(subscription?.cancel());
      return Future<void>.value();
    };

    return controller.stream;
  }

  @override
  Future<void> add(Pokemon pokemon) async {
    if (failAdd) throw StateError('add failed');
    _items.add(pokemon);
    _controller.add(List.unmodifiable(_items));
  }

  @override
  Future<void> update(Pokemon pokemon) async {
    if (failUpdate) throw StateError('update failed');
    final index = _items.indexWhere((item) => item.apiId == pokemon.apiId);
    if (index == -1) return;

    _items[index] = pokemon;
    _controller.add(List.unmodifiable(_items));
  }

  @override
  Future<void> remove(int apiId) async {
    if (failRemove) throw StateError('remove failed');
    _items.removeWhere((pokemon) => pokemon.apiId == apiId);
    _controller.add(List.unmodifiable(_items));
  }

  void dispose() {
    _controller.close();
  }
}

Pokemon testPokemon({int apiId = 1, String name = 'bulbasaur'}) {
  return Pokemon(
    apiId: apiId,
    name: name,
    types: ['grass', 'poison'],
    hp: 45,
    attack: 49,
    defense: 49,
    specialAttack: 65,
    specialDefense: 65,
    speed: 45,
    portraitUrl: 'https://example.com/artwork.png',
  );
}
