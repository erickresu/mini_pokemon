import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mini_pokemon/models/poke_api_pokemon.dart';
import 'package:mini_pokemon/models/poke_api_pokemon_page.dart';
import 'package:mini_pokemon/models/poke_api_pokemon_summary.dart';
import 'package:mini_pokemon/screens/pokemon_discover_page.dart';
import 'package:mini_pokemon/screens/pokemon_list_page.dart';
import 'package:mini_pokemon/services/poke_api_service.dart';
import 'package:mini_pokemon/widgets/pokemon_card.dart';
import 'package:mini_pokemon/widgets/pokemon_network_portrait.dart';

class _CatalogService extends PokeApiService {
  _CatalogService({this.failFirst = false, this.failNext = false});

  bool failFirst;
  bool failNext;
  final offsets = <int>[];

  @override
  Future<PokeApiPokemon> fetchPokemon(String name) async => PokeApiPokemon(
    id: 1,
    name: name,
    types: const ['grass', 'poison'],
    hp: 45,
    attack: 49,
    defense: 49,
    specialAttack: 65,
    specialDefense: 65,
    speed: 45,
    imageUrl: 'https://example.com/sprite.png',
    artworkUrl: 'https://example.com/artwork.png',
  );

  @override
  Future<PokeApiPokemonPage> fetchPokemonPage({
    int limit = 20,
    int offset = 0,
  }) async {
    offsets.add(offset);
    if (offset == 0 && failFirst) {
      failFirst = false;
      throw StateError('First page unavailable');
    }
    if (offset == 1 && failNext) {
      failNext = false;
      throw StateError('Next page unavailable');
    }
    return PokeApiPokemonPage(
      results: [
        PokeApiPokemonSummary(
          name: offset == 0 ? 'bulbasaur' : 'ivysaur',
          url: '',
        ),
      ],
      hasMore: offset == 0,
    );
  }
}

void main() {
  testWidgets(
    'Collects from detail and displays official artwork on the card',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: PokemonListPage(discoveryService: _CatalogService())),
      );
      await tester.tap(find.text('Discover'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('BULBASAUR'));
      await tester.pumpAndSettle();
      expect(find.text('Special Attack'), findsOneWidget);
      expect(find.text('GRASS / POISON'), findsOneWidget);

      final collect = find.text('Collect');
      await tester.drag(find.byType(ListView), const Offset(0, -350));
      await tester.pumpAndSettle();
      await tester.tap(collect);
      await tester.pumpAndSettle();

      expect(find.text('4 Pokemon'), findsOneWidget);
      final card = find.byKey(const ValueKey(4));
      await tester.scrollUntilVisible(card, 150);
      expect(tester.widget<PokemonCard>(card).pokemon.officialData?.id, 1);
      final portrait = tester.widget<PokemonNetworkPortrait>(
        find.descendant(
          of: card,
          matching: find.byType(PokemonNetworkPortrait),
        ),
      );
      expect(portrait.url, 'https://example.com/artwork.png');
    },
  );

  testWidgets('Retries the initial page', (tester) async {
    final service = _CatalogService(failFirst: true);
    await tester.pumpWidget(
      MaterialApp(home: PokemonDiscoverPage(service: service)),
    );
    await tester.pumpAndSettle();
    expect(find.text('Unable to load Pokemon.'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(service.offsets, [0, 0]);
    expect(find.text('BULBASAUR'), findsOneWidget);
  });

  testWidgets('Retries the same next page and stops at the end', (
    tester,
  ) async {
    final service = _CatalogService(failNext: true);
    await tester.pumpWidget(
      MaterialApp(home: PokemonDiscoverPage(service: service)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Load more'));
    await tester.pumpAndSettle();
    expect(find.text('BULBASAUR'), findsOneWidget);
    expect(find.text('Unable to load Pokemon.'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(service.offsets, [0, 1, 1]);
    expect(find.text('BULBASAUR'), findsOneWidget);
    expect(find.text('IVYSAUR'), findsOneWidget);
    expect(find.text('Load more'), findsNothing);
  });
}
