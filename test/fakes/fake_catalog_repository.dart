import 'package:mini_pokemon/domain/entities/pokemon.dart';
import 'package:mini_pokemon/domain/entities/pokemon_page.dart';
import 'package:mini_pokemon/domain/entities/pokemon_summary.dart';
import 'package:mini_pokemon/domain/repositories/pokemon_catalog_repository.dart';

import 'fake_collection_repository.dart';

class FakeCatalogRepository implements PokemonCatalogRepository {
  final List<int> offsets = [];
  final List<String> names = [];
  final bool failFirst;
  final bool failNext;
  final bool failDetails;
  final String detailName;
  final List<String> catalogNames;

  bool _firstFailed = false;
  bool _nextFailed = false;
  bool _detailsFailed = false;

  FakeCatalogRepository({
    this.failFirst = false,
    this.failNext = false,
    this.failDetails = false,
    this.detailName = 'bulbasaur',
    this.catalogNames = const [
      'bulbasaur',
      'ivysaur',
      'pikachu',
      'pichu',
      'psyduck',
      'aipom',
    ],
  });

  @override
  Future<PokemonPage> fetchPage({required int offset, int limit = 20}) async {
    offsets.add(offset);

    if (limit > 20) {
      return PokemonPage(
        results: [
          for (final name in catalogNames)
            PokemonSummary(
              name: name,
              url: 'https://pokeapi.co/api/v2/pokemon/$name/',
            ),
        ],
        hasMore: false,
      );
    }

    if (failFirst && offset == 0 && !_firstFailed) {
      _firstFailed = true;
      throw Exception('First page failed.');
    }

    if (failNext && offset == 1 && !_nextFailed) {
      _nextFailed = true;
      throw Exception('Next page failed.');
    }

    final name = offset == 0 ? 'bulbasaur' : 'ivysaur';

    return PokemonPage(
      results: [
        PokemonSummary(
          name: name,
          url: 'https://pokeapi.co/api/v2/pokemon/$offset/',
        ),
      ],
      hasMore: offset == 0,
    );
  }

  @override
  Future<Pokemon> fetchDetails(String name) async {
    names.add(name);

    if (failDetails && !_detailsFailed) {
      _detailsFailed = true;
      throw Exception('Details failed.');
    }

    return testPokemon().copyWith(name: detailName);
  }
}
