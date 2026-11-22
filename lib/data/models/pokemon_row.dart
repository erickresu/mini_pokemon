import 'dart:convert';

import '../../domain/entities/pokemon.dart';

class PokemonRow {
  static const table = 'pokemon';
  static const columnApiId = 'api_id';
  static const columnName = 'name';
  static const columnTypes = 'types';
  static const columnHp = 'hp';
  static const columnAttack = 'attack';
  static const columnDefense = 'defense';
  static const columnSpecialAttack = 'special_attack';
  static const columnSpecialDefense = 'special_defense';
  static const columnSpeed = 'speed';
  static const columnPortraitUrl = 'portrait_url';
  static const columnIsFavorite = 'is_favorite';

  static Map<String, Object?> toMap(Pokemon pokemon) {
    return <String, Object?>{
      columnApiId: pokemon.apiId,
      columnName: pokemon.name,
      columnTypes: jsonEncode(pokemon.types),
      columnHp: pokemon.hp,
      columnAttack: pokemon.attack,
      columnDefense: pokemon.defense,
      columnSpecialAttack: pokemon.specialAttack,
      columnSpecialDefense: pokemon.specialDefense,
      columnSpeed: pokemon.speed,
      columnPortraitUrl: pokemon.portraitUrl,
      columnIsFavorite: pokemon.isFavorite ? 1 : 0,
    };
  }

  static Pokemon fromMap(Map<String, Object?> row) {
    final encodedTypes = row[columnTypes] as String;
    final decodedTypes = jsonDecode(encodedTypes) as List<dynamic>;

    return Pokemon(
      apiId: row[columnApiId] as int,
      name: row[columnName] as String,
      types: decodedTypes.map((type) => type as String).toList(),
      hp: row[columnHp] as int,
      attack: row[columnAttack] as int,
      defense: row[columnDefense] as int,
      specialAttack: row[columnSpecialAttack] as int,
      specialDefense: row[columnSpecialDefense] as int,
      speed: row[columnSpeed] as int,
      portraitUrl: row[columnPortraitUrl] as String?,
      isFavorite: row[columnIsFavorite] == 1,
    );
  }
}
