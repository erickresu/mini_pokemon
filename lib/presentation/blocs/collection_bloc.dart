import 'dart:async';

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

class _CollectionUpdated extends CollectionEvent {
  final List<Pokemon> pokemons;

  const _CollectionUpdated(this.pokemons);
}

class _CollectionFailed extends CollectionEvent {
  const _CollectionFailed();
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

  StreamSubscription<List<Pokemon>>? _subscription;
  List<Pokemon> _current = const [];

  CollectionBloc({
    required this.watch,
    required this.collect,
    required this.remove,
  }) : super(const CollectionInitial()) {
    on<CollectionStarted>(_onStarted);
    on<PokemonCollected>(_onCollected);
    on<PokemonRemoved>(_onRemoved);
    on<_CollectionUpdated>(_onUpdated);
    on<_CollectionFailed>(_onFailed);
  }

  Future<void> _onStarted(
    CollectionStarted event,
    Emitter<CollectionState> emit,
  ) async {
    emit(const CollectionLoading());
    await _subscription?.cancel();

    _subscription = watch().listen(
      (pokemons) {
        if (!isClosed) add(_CollectionUpdated(pokemons));
      },
      onError: (Object error, StackTrace stackTrace) {
        if (!isClosed) add(const _CollectionFailed());
      },
    );
  }

  void _onUpdated(_CollectionUpdated event, Emitter<CollectionState> emit) {
    _current = event.pokemons;
    emit(CollectionReady(pokemons: _current));
  }

  void _onFailed(_CollectionFailed event, Emitter<CollectionState> emit) {
    emit(
      CollectionReady(pokemons: _current, notice: 'Unable to load collection.'),
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

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    await super.close();
  }
}
