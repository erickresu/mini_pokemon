import 'dart:async';

import 'package:mini_pokemon/domain/entities/pokemon.dart';
import 'package:mini_pokemon/domain/repositories/collection_repository.dart';

class FakeCollectionRepository implements CollectionRepository {
  final List<Pokemon> _items = [];
  final StreamController<List<Pokemon>> _controller =
      StreamController<List<Pokemon>>.broadcast();

  @override
  Stream<List<Pokemon>> watchAll() async* {
    yield List<Pokemon>.unmodifiable(_items);
    yield* _controller.stream;
  }

  @override
  Future<void> add(Pokemon pokemon) async {
    _items.add(pokemon);
    _controller.add(List.unmodifiable(_items));
  }

  @override
  Future<void> remove(int apiId) async {
    _items.removeWhere((pokemon) => pokemon.apiId == apiId);
    _controller.add(List.unmodifiable(_items));
  }

  void dispose() {
    _controller.close();
  }
}

Pokemon testPokemon({int apiId = 1}) {
  return Pokemon(
    apiId: apiId,
    name: 'bulbasaur',
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
