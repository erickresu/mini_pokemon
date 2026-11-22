import 'dart:async';

import '../../domain/entities/pokemon.dart';
import '../../domain/repositories/collection_repository.dart';

class InMemoryCollectionRepository implements CollectionRepository {
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
    _items.add(pokemon);
    _controller.add(List.unmodifiable(_items));
  }

  @override
  Future<void> update(Pokemon pokemon) async {
    final index = _items.indexWhere((item) => item.apiId == pokemon.apiId);
    if (index == -1) return;

    _items[index] = pokemon;
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
