import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/pokemon_row.dart';

const String createPokemonTableSql = '''
CREATE TABLE ${PokemonRow.table} (
  ${PokemonRow.columnApiId} INTEGER PRIMARY KEY,
  ${PokemonRow.columnName} TEXT NOT NULL,
  ${PokemonRow.columnTypes} TEXT NOT NULL,
  ${PokemonRow.columnHp} INTEGER NOT NULL,
  ${PokemonRow.columnAttack} INTEGER NOT NULL,
  ${PokemonRow.columnDefense} INTEGER NOT NULL,
  ${PokemonRow.columnSpecialAttack} INTEGER NOT NULL,
  ${PokemonRow.columnSpecialDefense} INTEGER NOT NULL,
  ${PokemonRow.columnSpeed} INTEGER NOT NULL,
  ${PokemonRow.columnPortraitUrl} TEXT,
  ${PokemonRow.columnIsFavorite} INTEGER NOT NULL DEFAULT 0
)
''';

Future<Database> openPokemonDatabase() async {
  final path = p.join(await getDatabasesPath(), 'mini_pokemon.db');

  return openDatabase(
    path,
    version: 1,
    onCreate: (db, _) async {
      await db.execute(createPokemonTableSql);
    },
  );
}
