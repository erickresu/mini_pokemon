import 'package:flutter_test/flutter_test.dart' hide Retry;
import 'package:mini_pokemon/domain/usecases/fetch_pokemon_page.dart';
import 'package:mini_pokemon/domain/usecases/search_pokemon.dart';
import 'package:mini_pokemon/presentation/blocs/discover_bloc.dart';

import '../fakes/fake_catalog_repository.dart';

DiscoverBloc _bloc(FakeCatalogRepository catalog) {
  return DiscoverBloc(
    fetchPage: FetchPokemonPage(catalog),
    search: SearchPokemon(catalog),
  );
}

void main() {
  test('starts with first page', () async {
    final catalog = FakeCatalogRepository();
    final bloc = _bloc(catalog);

    final ready = bloc.stream.firstWhere(
      (s) => s is DiscoverReady && s.results.length == 1 && s.hasMore,
    );
    bloc.add(DiscoverStarted());
    final state =
        await ready.timeout(const Duration(seconds: 1)) as DiscoverReady;

    expect(state.results.single.name, 'bulbasaur');
    expect(catalog.offsets, [0]);
    await bloc.close();
  });

  test('load more appends and records next offset', () async {
    final catalog = FakeCatalogRepository();
    final bloc = _bloc(catalog);

    final firstReady = bloc.stream.firstWhere((s) => s is DiscoverReady);
    bloc.add(DiscoverStarted());
    await firstReady.timeout(const Duration(seconds: 1));

    final secondReady = bloc.stream.firstWhere(
      (s) => s is DiscoverReady && s.results.length == 2,
    );
    bloc.add(LoadMore());
    final state =
        await secondReady.timeout(const Duration(seconds: 1)) as DiscoverReady;

    expect(state.results.map((item) => item.name), ['bulbasaur', 'ivysaur']);
    expect(catalog.offsets, [0, 1]);
    await bloc.close();
  });

  test('initial failure retries the same offset', () async {
    final catalog = FakeCatalogRepository(failFirst: true);
    final bloc = _bloc(catalog);

    final failure = bloc.stream.firstWhere((s) => s is DiscoverFailure);
    bloc.add(DiscoverStarted());
    await failure.timeout(const Duration(seconds: 1));

    final ready = bloc.stream.firstWhere((s) => s is DiscoverReady);
    bloc.add(Retry());
    await ready.timeout(const Duration(seconds: 1));

    expect(catalog.offsets, [0, 0]);
    await bloc.close();
  });

  test('paged failure retries same offset and keeps prior rows', () async {
    final catalog = FakeCatalogRepository(failNext: true);
    final bloc = _bloc(catalog);

    final firstReady = bloc.stream.firstWhere((s) => s is DiscoverReady);
    bloc.add(DiscoverStarted());
    await firstReady.timeout(const Duration(seconds: 1));

    final failedPage = bloc.stream.firstWhere(
      (s) => s is DiscoverReady && s.errorMessage != null,
    );
    bloc.add(LoadMore());
    final failed =
        await failedPage.timeout(const Duration(seconds: 1)) as DiscoverReady;
    expect(failed.results, hasLength(1));

    final recovered = bloc.stream.firstWhere(
      (s) => s is DiscoverReady && s.results.length == 2,
    );
    bloc.add(Retry());
    await recovered.timeout(const Duration(seconds: 1));

    expect(catalog.offsets, [0, 1, 1]);
    await bloc.close();
  });

  test('search shows one result and hides paging', () async {
    final catalog = FakeCatalogRepository();
    final bloc = _bloc(catalog);

    bloc.add(SearchSubmitted('bulbasaur'));
    final state =
        await bloc.stream
                .firstWhere((s) => s is DiscoverReady)
                .timeout(const Duration(seconds: 1))
            as DiscoverReady;

    expect(state.results.single.name, 'bulbasaur');
    expect(state.isSearch, isTrue);
    expect(state.hasMore, isFalse);
    expect(catalog.offsets, isEmpty);
    await bloc.close();
  });

  test('search failure reports a search-specific message', () async {
    final catalog = FakeCatalogRepository(failDetails: true);
    final bloc = _bloc(catalog);

    bloc.add(SearchSubmitted('missingno'));
    final state =
        await bloc.stream
                .firstWhere((s) => s is DiscoverFailure)
                .timeout(const Duration(seconds: 1))
            as DiscoverFailure;

    expect(state.message, 'Unable to find Pokemon.');
    expect(state.isSearch, isTrue);
    await bloc.close();
  });

  test(
    'search retry repeats the same query and clear restarts paging',
    () async {
      final catalog = FakeCatalogRepository(failDetails: true);
      final bloc = _bloc(catalog);

      bloc.add(SearchSubmitted('missingno'));
      final failure =
          await bloc.stream
                  .firstWhere((s) => s is DiscoverFailure)
                  .timeout(const Duration(seconds: 1))
              as DiscoverFailure;
      expect(failure.isSearch, isTrue);
      expect(catalog.names, ['missingno']);

      bloc.add(Retry());
      final searched =
          await bloc.stream
                  .firstWhere((s) => s is DiscoverReady && s.isSearch)
                  .timeout(const Duration(seconds: 1))
              as DiscoverReady;
      expect(searched.results, hasLength(1));
      expect(catalog.names, ['missingno', 'missingno']);

      bloc.add(SearchCleared());
      final paged =
          await bloc.stream
                  .firstWhere((s) => s is DiscoverReady && !s.isSearch)
                  .timeout(const Duration(seconds: 1))
              as DiscoverReady;
      expect(paged.hasMore, isTrue);
      expect(catalog.offsets, [0]);
      await bloc.close();
    },
  );

  test('one character suggests only names with that prefix', () async {
    final catalog = FakeCatalogRepository();
    final bloc = _bloc(catalog);

    bloc.add(SearchQueryChanged('p'));
    final state =
        await bloc.stream
                .firstWhere((s) => s is DiscoverReady && s.isSearch)
                .timeout(const Duration(seconds: 1))
            as DiscoverReady;

    expect(state.results.map((item) => item.name), [
      'pikachu',
      'pichu',
      'psyduck',
    ]);
    expect(state.results.any((item) => item.name == 'aipom'), isFalse);
    await bloc.close();
  });

  test('two characters suggest names containing the text', () async {
    final catalog = FakeCatalogRepository();
    final bloc = _bloc(catalog);

    bloc.add(SearchQueryChanged('pi'));
    final state =
        await bloc.stream
                .firstWhere((s) => s is DiscoverReady && s.isSearch)
                .timeout(const Duration(seconds: 1))
            as DiscoverReady;

    expect(state.results.map((item) => item.name), ['pikachu', 'pichu']);
    await bloc.close();
  });

  test('a second keystroke reuses the cached name catalog', () async {
    final catalog = FakeCatalogRepository();
    final bloc = _bloc(catalog);

    bloc.add(SearchQueryChanged('p'));
    await bloc.stream
        .firstWhere((s) => s is DiscoverReady && s.isSearch)
        .timeout(const Duration(seconds: 1));

    bloc.add(SearchQueryChanged('pi'));
    final state =
        await bloc.stream
                .firstWhere(
                  (s) =>
                      s is DiscoverReady && s.isSearch && s.results.length == 2,
                )
                .timeout(const Duration(seconds: 1))
            as DiscoverReady;

    expect(state.results.map((item) => item.name), ['pikachu', 'pichu']);
    expect(catalog.offsets, [0]);
    await bloc.close();
  });
}
