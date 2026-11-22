import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/pokemon.dart';
import '../../domain/usecases/collect_pokemon.dart';
import '../../domain/usecases/remove_pokemon.dart';
import '../../domain/usecases/toggle_favorite.dart';
import '../../domain/usecases/update_pokemon.dart';
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

class PokemonUpdated extends CollectionEvent {
  final Pokemon pokemon;

  const PokemonUpdated(this.pokemon);
}

class PokemonFavoriteToggled extends CollectionEvent {
  final Pokemon pokemon;

  const PokemonFavoriteToggled(this.pokemon);
}

class PokemonRemoved extends CollectionEvent {
  final int apiId;

  const PokemonRemoved(this.apiId);
}

class CollectionFilterChanged extends CollectionEvent {
  final bool favoritesOnly;

  const CollectionFilterChanged({required this.favoritesOnly});
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
  final bool favoritesOnly;
  final String? notice;

  const CollectionReady({
    required this.pokemons,
    this.favoritesOnly = false,
    this.notice,
  });
}

class CollectionBloc extends Bloc<CollectionEvent, CollectionState> {
  final WatchCollection watch;
  final CollectPokemon collect;
  final RemovePokemon remove;
  final UpdatePokemon update;
  final ToggleFavorite toggleFavorite;

  StreamSubscription<List<Pokemon>>? _subscription;
  List<Pokemon> _all = const [];
  bool _favoritesOnly = false;

  CollectionBloc({
    required this.watch,
    required this.collect,
    required this.remove,
    required this.update,
    required this.toggleFavorite,
  }) : super(const CollectionInitial()) {
    on<CollectionStarted>(_onStarted);
    on<PokemonCollected>(_onCollected);
    on<PokemonUpdated>(_onUpdated);
    on<PokemonFavoriteToggled>(_onFavoriteToggled);
    on<PokemonRemoved>(_onRemoved);
    on<CollectionFilterChanged>(_onFilterChanged);
    on<_CollectionUpdated>(_onCollectionUpdated);
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

  void _onCollectionUpdated(
    _CollectionUpdated event,
    Emitter<CollectionState> emit,
  ) {
    _all = event.pokemons;
    _emitReady(emit);
  }

  void _onFailed(_CollectionFailed event, Emitter<CollectionState> emit) {
    _emitReady(emit, notice: 'Unable to load collection.');
  }

  Future<void> _onCollected(
    PokemonCollected event,
    Emitter<CollectionState> emit,
  ) async {
    late final bool added;
    try {
      added = await collect(event.pokemon);
    } catch (_) {
      if (emit.isDone) return;
      _emitReady(emit, notice: 'Unable to save collection.');
      return;
    }

    if (emit.isDone) return;

    if (added && !_all.any((item) => item.apiId == event.pokemon.apiId)) {
      _all = [..._all, event.pokemon];
    }

    _emitReady(
      emit,
      notice: added
          ? 'Added to your collection.'
          : 'Already in your collection.',
    );
  }

  Future<void> _onUpdated(
    PokemonUpdated event,
    Emitter<CollectionState> emit,
  ) async {
    try {
      await update(event.pokemon);
    } catch (_) {
      if (emit.isDone) return;
      _emitReady(emit, notice: 'Unable to save collection.');
      return;
    }

    if (emit.isDone) return;

    _all = _all
        .map((item) => item.apiId == event.pokemon.apiId ? event.pokemon : item)
        .toList();

    _emitReady(emit, notice: 'Updated ${event.pokemon.name}.');
  }

  Future<void> _onFavoriteToggled(
    PokemonFavoriteToggled event,
    Emitter<CollectionState> emit,
  ) async {
    final toggled = event.pokemon.copyWith(
      isFavorite: !event.pokemon.isFavorite,
    );
    try {
      await toggleFavorite(event.pokemon);
    } catch (_) {
      if (emit.isDone) return;
      _emitReady(emit, notice: 'Unable to save collection.');
      return;
    }

    if (emit.isDone) return;

    _all = _all
        .map((item) => item.apiId == toggled.apiId ? toggled : item)
        .toList();

    _emitReady(emit);
  }

  Future<void> _onRemoved(
    PokemonRemoved event,
    Emitter<CollectionState> emit,
  ) async {
    try {
      await remove(event.apiId);
    } catch (_) {
      if (emit.isDone) return;
      _emitReady(emit, notice: 'Unable to save collection.');
      return;
    }

    if (emit.isDone) return;

    _all = _all.where((item) => item.apiId != event.apiId).toList();

    _emitReady(emit);
  }

  void _onFilterChanged(
    CollectionFilterChanged event,
    Emitter<CollectionState> emit,
  ) {
    _favoritesOnly = event.favoritesOnly;
    _emitReady(emit);
  }

  void _emitReady(Emitter<CollectionState> emit, {String? notice}) {
    final visible = _favoritesOnly
        ? _all.where((pokemon) => pokemon.isFavorite).toList()
        : _all;

    emit(
      CollectionReady(
        pokemons: visible,
        favoritesOnly: _favoritesOnly,
        notice: notice,
      ),
    );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    await super.close();
  }
}
