import 'package:flutter_test/flutter_test.dart';
import 'package:mini_pokemon/domain/entities/pokemon.dart';
import 'package:mini_pokemon/domain/entities/pokemon_page.dart';
import 'package:mini_pokemon/domain/entities/pokemon_summary.dart';

void main() {
  test('entities expose the fields the app needs', () {
    const pokemon = Pokemon(
      apiId: 1,
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

    expect(pokemon.apiId, 1);
    expect(pokemon.types, ['grass', 'poison']);
    expect(pokemon.specialDefense, 65);
    expect(pokemon.portraitUrl, 'https://example.com/artwork.png');

    const row = PokemonSummary(name: 'ivysaur', url: 'https://example.com/2');
    final page = PokemonPage(results: const [row], hasMore: true);
    expect(page.results.single.name, 'ivysaur');
    expect(page.hasMore, isTrue);
  });
}
