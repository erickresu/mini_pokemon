import 'package:flutter_test/flutter_test.dart' hide Retry;
import 'package:mini_pokemon/domain/usecases/fetch_pokemon_page.dart';
import 'package:mini_pokemon/presentation/blocs/discover_bloc.dart';

import '../fakes/fake_catalog_repository.dart';

void main() {
  test('starts with first page', () async {
    final catalog = FakeCatalogRepository();
    final bloc = DiscoverBloc(fetchPage: FetchPokemonPage(catalog));

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
    final bloc = DiscoverBloc(fetchPage: FetchPokemonPage(catalog));

    final firstReady = bloc.stream.firstWhere((s) => s is DiscoverReady);
    bloc.add(DiscoverStarted());
    await firstReady.timeout(const Duration(seconds: 1));

    final twoRows = bloc.stream.firstWhere(
      (s) => s is DiscoverReady && s.results.length == 2,
    );
    bloc.add(LoadMore());
    final state =
        await twoRows.timeout(const Duration(seconds: 1)) as DiscoverReady;

    expect(state.hasMore, isFalse);
    expect(catalog.offsets, [0, 1]);
    await bloc.close();
  });

  test('initial failure retries the same offset', () async {
    final catalog = FakeCatalogRepository(failFirst: true);
    final bloc = DiscoverBloc(fetchPage: FetchPokemonPage(catalog));

    final failure = bloc.stream.firstWhere((s) => s is DiscoverFailure);
    bloc.add(DiscoverStarted());
    await failure.timeout(const Duration(seconds: 1));

    final ready = bloc.stream.firstWhere(
      (s) => s is DiscoverReady && s.results.length == 1,
    );
    bloc.add(Retry());
    await ready.timeout(const Duration(seconds: 1));

    expect(catalog.offsets, [0, 0]);
    await bloc.close();
  });

  test('paged failure retries same offset and keeps prior rows', () async {
    final catalog = FakeCatalogRepository(failNext: true);
    final bloc = DiscoverBloc(fetchPage: FetchPokemonPage(catalog));

    final firstReady = bloc.stream.firstWhere((s) => s is DiscoverReady);
    bloc.add(DiscoverStarted());
    await firstReady.timeout(const Duration(seconds: 1));

    final readyWithError = bloc.stream.firstWhere(
      (s) => s is DiscoverReady && s.errorMessage == 'Unable to load Pokemon.',
    );
    bloc.add(LoadMore());
    final failed = await readyWithError.timeout(
      const Duration(seconds: 1),
    ) as DiscoverReady;

    expect(failed.results, hasLength(1));
    expect(catalog.offsets, [0, 1]);

    final success = bloc.stream.firstWhere(
      (s) =>
          s is DiscoverReady &&
          s.results.length == 2 &&
          s.hasMore == false &&
          s.errorMessage == null,
    );
    bloc.add(Retry());
    final state =
        await success.timeout(const Duration(seconds: 1)) as DiscoverReady;

    expect(state.results.length, 2);
    expect(catalog.offsets, [0, 1, 1]);
    await bloc.close();
  });
}
