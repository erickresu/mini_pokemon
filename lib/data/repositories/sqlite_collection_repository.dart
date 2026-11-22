import 'dart:async';

import 'package:sqflite/sqflite.dart';

import '../../domain/entities/pokemon.dart';
import '../../domain/repositories/collection_repository.dart';
import '../models/pokemon_row.dart';

class SqliteCollectionRepository implements CollectionRepository {
  SqliteCollectionRepository(this._database);

  final Database _database;
  final StreamController<List<Pokemon>> _controller =
      StreamController<List<Pokemon>>.broadcast();
  int _revision = 0;

  @override
  Stream<List<Pokemon>> watchAll() {
    final controller = StreamController<List<Pokemon>>();
    StreamSubscription<List<Pokemon>>? subscription;

    controller.onListen = () {
      final revisionAtListen = _revision;

      subscription = _controller.stream.listen(
        controller.add,
        onError: controller.addError,
        onDone: controller.close,
      );

      _readAll().then((pokemons) {
        if (!controller.isClosed && revisionAtListen == _revision) {
          controller.add(pokemons);
        }
      }, onError: controller.addError);
    };

    controller.onCancel = () {
      unawaited(subscription?.cancel());
      return Future<void>.value();
    };

    return controller.stream;
  }

  @override
  Future<void> add(Pokemon pokemon) {
    return _write(() {
      return _database.insert(
        PokemonRow.table,
        PokemonRow.toMap(pokemon),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    });
  }

  @override
  Future<void> update(Pokemon pokemon) {
    return _write(() {
      return _database.update(
        PokemonRow.table,
        PokemonRow.toMap(pokemon),
        where: '${PokemonRow.columnApiId} = ?',
        whereArgs: [pokemon.apiId],
      );
    });
  }

  @override
  Future<void> remove(int apiId) {
    return _write(() {
      return _database.delete(
        PokemonRow.table,
        where: '${PokemonRow.columnApiId} = ?',
        whereArgs: [apiId],
      );
    });
  }

  void dispose() {
    _controller.close();
  }

  Future<void> _write(Future<int> Function() operation) async {
    _revision++;

    try {
      await operation();
    } catch (error) {
      if (!_controller.isClosed) _controller.addError(error);
      rethrow;
    }

    await _publish();
  }

  Future<void> _publish() async {
    final pokemons = await _readAll();
    if (!_controller.isClosed) {
      _controller.add(List<Pokemon>.unmodifiable(pokemons));
    }
  }

  Future<List<Pokemon>> _readAll() async {
    final rows = await _database.query(
      PokemonRow.table,
      orderBy: '${PokemonRow.columnName} ASC',
    );

    return rows.map(PokemonRow.fromMap).toList();
  }
}
