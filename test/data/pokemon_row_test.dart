import 'package:flutter_test/flutter_test.dart';
import 'package:mini_pokemon/data/models/pokemon_row.dart';
import 'package:mini_pokemon/domain/entities/pokemon.dart';

Pokemon sample({String? portraitUrl, bool isFavorite = false}) {
  return Pokemon(
    apiId: 7,
    name: 'wartortle',
    types: const ['water'],
    hp: 59,
    attack: 63,
    defense: 80,
    specialAttack: 65,
    specialDefense: 63,
    speed: 58,
    portraitUrl: portraitUrl,
    isFavorite: isFavorite,
  );
}

void expectSamePokemon(Pokemon actual, Pokemon expected) {
  expect(actual.apiId, expected.apiId);
  expect(actual.name, expected.name);
  expect(actual.types, expected.types);
  expect(actual.hp, expected.hp);
  expect(actual.attack, expected.attack);
  expect(actual.defense, expected.defense);
  expect(actual.specialAttack, expected.specialAttack);
  expect(actual.specialDefense, expected.specialDefense);
  expect(actual.speed, expected.speed);
  expect(actual.portraitUrl, expected.portraitUrl);
  expect(actual.isFavorite, expected.isFavorite);
}

void main() {
  test('stores types as JSON and favorite as an integer', () {
    final pokemon = sample(
      portraitUrl: 'https://example.com/artwork.png',
      isFavorite: true,
    );

    final row = PokemonRow.toMap(pokemon);

    expect(row[PokemonRow.columnTypes], '["water"]');
    expect(row[PokemonRow.columnIsFavorite], 1);
    expectSamePokemon(PokemonRow.fromMap(row), pokemon);
  });

  test('round trips a null portrait and an unfavorited Pokemon', () {
    final pokemon = sample();

    final row = PokemonRow.toMap(pokemon);

    expect(row[PokemonRow.columnPortraitUrl], isNull);
    expect(row[PokemonRow.columnIsFavorite], 0);
    expectSamePokemon(PokemonRow.fromMap(row), pokemon);
  });
}
