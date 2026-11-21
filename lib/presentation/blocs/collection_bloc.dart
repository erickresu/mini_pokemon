import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/pokemon.dart';
import '../../domain/usecases/collect_pokemon.dart';
import '../../domain/usecases/remove_pokemon.dart';
import '../../domain/usecases/watch_collection.dart';

abstract class CollectionEvent {
  const CollectionEvent();
}

class CollectionStarted extends CollectionEvent {
  const CollectionStarted();
}

class PokemonCollected extends CollectionEvent {
  final Pokemon pokemon;

  const PokemonCollected(this.pokemon);
}

class PokemonRemoved extends CollectionEvent {
  final int apiId;

  const PokemonRemoved(this.apiId);
}

abstract class CollectionState {
  const CollectionState();
}

class CollectionInitial extends CollectionState {
  const CollectionInitial();
}

class CollectionLoading extends CollectionState {
  const CollectionLoading();
}

class CollectionReady extends CollectionState {
  final List<Pokemon> pokemons;
  final String? notice;

  const CollectionReady({required this.pokemons, this.notice});
}

class CollectionBloc extends Bloc<CollectionEvent, CollectionState> {
  final WatchCollection watch;
  final CollectPokemon collect;
  final RemovePokemon remove;

  List<Pokemon> _current = const [];

  CollectionBloc({
    required this.watch,
    required this.collect,
    required this.remove,
  }) : super(const CollectionInitial()) {
    on<CollectionStarted>(_onStarted);
    on<PokemonCollected>(_onCollected);
    on<PokemonRemoved>(_onRemoved);
  }

  Future<void> _onStarted(
    CollectionStarted event,
    Emitter<CollectionState> emit,
  ) async {
    emit(const CollectionLoading());

    await emit.forEach<List<Pokemon>>(
      watch(),
      onData: (pokemons) {
        _current = pokemons;
        return CollectionReady(pokemons: pokemons);
      },
      onError: (error, stackTrace) {
        return CollectionReady(
          pokemons: _current,
          notice: 'Unable to load collection.',
        );
      },
    );
  }

  Future<void> _onCollected(
    PokemonCollected event,
    Emitter<CollectionState> emit,
  ) async {
    final added = await collect(event.pokemon);

    if (emit.isDone) return;

    emit(
      CollectionReady(
        pokemons: _current,
        notice: added
            ? 'Added to your collection.'
            : 'Already in your collection.',
      ),
    );
  }

  Future<void> _onRemoved(
    PokemonRemoved event,
    Emitter<CollectionState> emit,
  ) async {
    await remove(event.apiId);

    if (emit.isDone) return;

    emit(CollectionReady(pokemons: _current));
  }
}
