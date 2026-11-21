import 'dart:async';

import '../../domain/entities/pokemon.dart';
import '../../domain/repositories/collection_repository.dart';

class InMemoryCollectionRepository implements CollectionRepository {
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
