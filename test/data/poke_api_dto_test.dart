import 'package:flutter_test/flutter_test.dart';
import 'package:mini_pokemon/data/models/poke_api_dto.dart';
import 'package:mini_pokemon/data/models/poke_api_page_dto.dart';

void main() {
  test('maps detail JSON and falls back to sprite portrait', () {
    final dto = PokeApiPokemonDto.fromJson({
      'id': 1,
      'name': 'bulbasaur',
      'types': [
        {
          'type': {'name': 'grass'},
        },
        {
          'type': {'name': 'poison'},
        },
      ],
      'stats': [
        {
          'stat': {'name': 'hp'},
          'base_stat': 45,
        },
        {
          'stat': {'name': 'attack'},
          'base_stat': 49,
        },
        {
          'stat': {'name': 'defense'},
          'base_stat': 49,
        },
        {
          'stat': {'name': 'special-attack'},
          'base_stat': 65,
        },
        {
          'stat': {'name': 'special-defense'},
          'base_stat': 65,
        },
        {
          'stat': {'name': 'speed'},
          'base_stat': 45,
        },
      ],
      'sprites': {'front_default': 'https://example.com/sprite.png'},
    });

    final pokemon = dto.toEntity();
    expect(pokemon.apiId, 1);
    expect(pokemon.types, ['grass', 'poison']);
    expect(pokemon.specialDefense, 65);
    expect(pokemon.portraitUrl, 'https://example.com/sprite.png');
  });

  test('maps page JSON and hasMore from next', () {
    final dto = PokeApiPageDto.fromJson({
      'next': 'https://pokeapi.co/api/v2/pokemon?offset=20&limit=20',
      'results': [
        {'name': 'bulbasaur', 'url': 'https://pokeapi.co/api/v2/pokemon/1/'},
      ],
    });

    final page = dto.toEntity();
    expect(page.results.single.name, 'bulbasaur');
    expect(page.results.single.url, 'https://pokeapi.co/api/v2/pokemon/1/');
    expect(page.hasMore, isTrue);
  });
}
