import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mini_pokemon/data/datasources/pokemon_database.dart';
import 'package:mini_pokemon/data/models/pokemon_row.dart';
import 'package:mini_pokemon/data/repositories/sqlite_collection_repository.dart';
import 'package:mini_pokemon/domain/entities/pokemon.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Pokemon sample({int apiId = 7, String name = 'wartortle', bool favorite = false}) {
  return Pokemon(
    apiId: apiId,
    name: name,
    types: const ['water'],
    hp: 59,
    attack: 63,
    defense: 80,
    specialAttack: 65,
    specialDefense: 63,
    speed: 58,
    portraitUrl: 'https://example.com/artwork.png',
    isFavorite: favorite,
  );
}

void main() {
  setUpAll(() => sqfliteFfiInit());

  late Database database;
  late SqliteCollectionRepository repository;

  setUp(() async {
    database = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, _) async {
          await db.execute(createPokemonTableSql);
        },
      ),
    );
    repository = SqliteCollectionRepository(database);
  });

  tearDown(() async {
    repository.dispose();
    await database.close();
  });

  test('watchAll emits the stored snapshot and updates after writes', () async {
    final iterator = StreamIterator<List<Pokemon>>(repository.watchAll());
    addTearDown(iterator.cancel);

    expect(await iterator.moveNext(), isTrue);
    expect(iterator.current, isEmpty);

    final afterAdd = iterator.moveNext();
    await repository.add(sample());
    expect(await afterAdd, isTrue);
    expect(iterator.current.single.name, 'wartortle');

    final afterUpdate = iterator.moveNext();
    await repository.update(sample(name: 'blastoise', favorite: true));
    expect(await afterUpdate, isTrue);
    expect(iterator.current.single.name, 'blastoise');
    expect(iterator.current.single.isFavorite, isTrue);

    final afterRemove = iterator.moveNext();
    await repository.remove(7);
    expect(await afterRemove, isTrue);
    expect(iterator.current, isEmpty);
  });

  test('add ignores a duplicate api id', () async {
    await repository.add(sample(name: 'wartortle'));
    await repository.add(sample(name: 'other-name'));

    final rows = await repository.watchAll().first;
    expect(rows, hasLength(1));
    expect(rows.single.name, 'wartortle');
  });

  test('favorite flag is stored as zero or one', () async {
    await repository.add(sample(favorite: true));

    var rows = await database.query(PokemonRow.table);
    expect(rows.single[PokemonRow.columnIsFavorite], 1);

    await repository.update(sample(favorite: false));

    rows = await database.query(PokemonRow.table);
    expect(rows.single[PokemonRow.columnIsFavorite], 0);
  });
}
