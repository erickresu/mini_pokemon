import 'package:flutter_test/flutter_test.dart';
import 'package:mini_pokemon/domain/usecases/collect_pokemon.dart';
import 'package:mini_pokemon/domain/usecases/remove_pokemon.dart';
import 'package:mini_pokemon/domain/usecases/toggle_favorite.dart';
import 'package:mini_pokemon/domain/usecases/update_pokemon.dart';
import 'package:mini_pokemon/domain/usecases/watch_collection.dart';
import 'package:mini_pokemon/presentation/blocs/collection_bloc.dart';

import '../fakes/fake_collection_repository.dart';

CollectionBloc _bloc(FakeCollectionRepository repo) {
  return CollectionBloc(
    watch: WatchCollection(repo),
    collect: CollectPokemon(repo),
    remove: RemovePokemon(repo),
    update: UpdatePokemon(repo),
    toggleFavorite: ToggleFavorite(repo),
  );
}

void main() {
  test('starts, collects, rejects duplicates, and removes', () async {
    final repo = FakeCollectionRepository();
    final pokemon = testPokemon();
    final bloc = _bloc(repo);
    final readyEmpty = bloc.stream.firstWhere(
      (s) => s is CollectionReady && s.pokemons.isEmpty,
    );
    bloc.add(CollectionStarted());
    await readyEmpty.timeout(const Duration(seconds: 1));

    final readyOne = bloc.stream.firstWhere(
      (s) => s is CollectionReady && s.pokemons.length == 1,
    );
    bloc.add(PokemonCollected(pokemon));
    await readyOne.timeout(const Duration(seconds: 1));

    final readyDuplicate = bloc.stream.firstWhere(
      (s) => s is CollectionReady && s.notice == 'Already in your collection.',
    );
    bloc.add(PokemonCollected(pokemon));
    final duplicate = await readyDuplicate.timeout(
      const Duration(seconds: 1),
    ) as CollectionReady;
    expect(duplicate.pokemons, hasLength(1));

    final readyRemoved = bloc.stream.firstWhere(
      (s) => s is CollectionReady && s.pokemons.isEmpty,
    );
    bloc.add(PokemonRemoved(1));
    await readyRemoved.timeout(const Duration(seconds: 1));
    await bloc.close();
  });

  test(
    'restarting does not create duplicate collection subscriptions',
    () async {
      final repo = FakeCollectionRepository();
      final bloc = _bloc(repo);
      var oneItemEmissions = 0;
      final subscription = bloc.stream.listen((state) {
        if (state is CollectionReady && state.pokemons.length == 1) {
          oneItemEmissions++;
        }
      });

      final firstReady = bloc.stream.firstWhere(
        (s) => s is CollectionReady && s.pokemons.isEmpty,
      );
      bloc.add(CollectionStarted());
      await firstReady.timeout(const Duration(seconds: 1));

      final secondReady = bloc.stream.firstWhere(
        (s) => s is CollectionReady && s.pokemons.isEmpty,
      );
      bloc.add(CollectionStarted());
      await secondReady.timeout(const Duration(seconds: 1));

      final oneItemReady = bloc.stream.firstWhere(
        (s) => s is CollectionReady && s.pokemons.length == 1,
      );
      await repo.add(testPokemon());
      await oneItemReady.timeout(const Duration(seconds: 1));
      await Future<void>.delayed(Duration.zero);

      expect(oneItemEmissions, 1);
      await subscription.cancel();
      await bloc.close();
    },
  );

  test('update emits notice and the changed list', () async {
    final repo = FakeCollectionRepository();
    final pokemon = testPokemon();
    await repo.add(pokemon);
    final bloc = _bloc(repo);
    final ready = bloc.stream.firstWhere(
      (s) => s is CollectionReady && s.pokemons.length == 1,
    );
    bloc.add(CollectionStarted());
    await ready.timeout(const Duration(seconds: 1));

    final updatedReady = bloc.stream.firstWhere(
      (s) => s is CollectionReady && s.notice == 'Updated Ivysaur.',
    );
    bloc.add(PokemonUpdated(pokemon.copyWith(name: 'Ivysaur')));
    final state = await updatedReady.timeout(
      const Duration(seconds: 1),
    ) as CollectionReady;

    expect(state.pokemons.single.name, 'Ivysaur');
    await bloc.close();
  });

  test('collect write failure keeps the collection unchanged', () async {
    final repo = FakeCollectionRepository()..failAdd = true;
    final bloc = _bloc(repo);
    final ready = bloc.stream.firstWhere(
      (s) => s is CollectionReady && s.pokemons.isEmpty,
    );
    bloc.add(CollectionStarted());
    await ready.timeout(const Duration(seconds: 1));

    final failed = bloc.stream.firstWhere(
      (s) => s is CollectionReady && s.notice == 'Unable to save collection.',
    );
    bloc.add(PokemonCollected(testPokemon()));
    final state =
        await failed.timeout(const Duration(seconds: 1)) as CollectionReady;

    expect(state.pokemons, isEmpty);
    await bloc.close();
  });

  test('update write failure keeps the old values', () async {
    final repo = FakeCollectionRepository();
    await repo.add(testPokemon());
    repo.failUpdate = true;
    final bloc = _bloc(repo);
    final ready = bloc.stream.firstWhere(
      (s) => s is CollectionReady && s.pokemons.length == 1,
    );
    bloc.add(CollectionStarted());
    await ready.timeout(const Duration(seconds: 1));

    final failed = bloc.stream.firstWhere(
      (s) => s is CollectionReady && s.notice == 'Unable to save collection.',
    );
    bloc.add(PokemonUpdated(testPokemon().copyWith(name: 'Ivysaur')));
    final state =
        await failed.timeout(const Duration(seconds: 1)) as CollectionReady;

    expect(state.pokemons.single.name, 'bulbasaur');
    await bloc.close();
  });

  test('favorite write failure keeps the old flag', () async {
    final repo = FakeCollectionRepository();
    await repo.add(testPokemon());
    repo.failUpdate = true;
    final bloc = _bloc(repo);
    final ready = bloc.stream.firstWhere(
      (s) => s is CollectionReady && s.pokemons.length == 1,
    );
    bloc.add(CollectionStarted());
    await ready.timeout(const Duration(seconds: 1));

    final failed = bloc.stream.firstWhere(
      (s) => s is CollectionReady && s.notice == 'Unable to save collection.',
    );
    bloc.add(PokemonFavoriteToggled(testPokemon()));
    final state =
        await failed.timeout(const Duration(seconds: 1)) as CollectionReady;

    expect(state.pokemons.single.isFavorite, isFalse);
    await bloc.close();
  });

  test('remove write failure keeps the Pokemon', () async {
    final repo = FakeCollectionRepository();
    await repo.add(testPokemon());
    repo.failRemove = true;
    final bloc = _bloc(repo);
    final ready = bloc.stream.firstWhere(
      (s) => s is CollectionReady && s.pokemons.length == 1,
    );
    bloc.add(CollectionStarted());
    await ready.timeout(const Duration(seconds: 1));

    final failed = bloc.stream.firstWhere(
      (s) => s is CollectionReady && s.notice == 'Unable to save collection.',
    );
    bloc.add(const PokemonRemoved(1));
    final state =
        await failed.timeout(const Duration(seconds: 1)) as CollectionReady;

    expect(state.pokemons, hasLength(1));
    await bloc.close();
  });

  test(
    'favorites filter hides non favorites and survives stream updates',
    () async {
      final repo = FakeCollectionRepository();
      await repo.add(testPokemon(apiId: 1));
      await repo.add(testPokemon(apiId: 2));
      final bloc = _bloc(repo);
      final ready = bloc.stream.firstWhere(
        (s) => s is CollectionReady && s.pokemons.length == 2,
      );
      bloc.add(CollectionStarted());
      await ready.timeout(const Duration(seconds: 1));

      bloc.add(const CollectionFilterChanged(favoritesOnly: true));
      await Future<void>.delayed(Duration.zero);
      final first = (await repo.watchAll().first).first;
      await repo.update(first.copyWith(isFavorite: true));
      await Future<void>.delayed(Duration.zero);

      final state = bloc.state as CollectionReady;
      expect(state.favoritesOnly, isTrue);
      expect(state.pokemons.map((item) => item.apiId), [1]);
      await bloc.close();
    },
  );
}
