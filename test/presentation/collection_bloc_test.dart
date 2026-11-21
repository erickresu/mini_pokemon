import 'package:flutter_test/flutter_test.dart';
import 'package:mini_pokemon/domain/usecases/collect_pokemon.dart';
import 'package:mini_pokemon/domain/usecases/remove_pokemon.dart';
import 'package:mini_pokemon/domain/usecases/watch_collection.dart';
import 'package:mini_pokemon/presentation/blocs/collection_bloc.dart';

import '../fakes/fake_collection_repository.dart';

void main() {
  test('starts, collects, rejects duplicates, and removes', () async {
    final repo = FakeCollectionRepository();
    final pokemon = testPokemon();
    final bloc = CollectionBloc(
      watch: WatchCollection(repo),
      collect: CollectPokemon(repo),
      remove: RemovePokemon(repo),
    );
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
}
