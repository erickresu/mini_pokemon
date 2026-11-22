import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/pokemon_summary.dart';
import '../../domain/usecases/fetch_pokemon_page.dart';
import '../../domain/usecases/search_pokemon.dart';

abstract class DiscoverEvent {
  const DiscoverEvent();
}

class DiscoverStarted extends DiscoverEvent {
  const DiscoverStarted();
}

class LoadMore extends DiscoverEvent {
  const LoadMore();
}

class Retry extends DiscoverEvent {
  const Retry();
}

class SearchSubmitted extends DiscoverEvent {
  final String query;

  const SearchSubmitted(this.query);
}

class SearchCleared extends DiscoverEvent {
  const SearchCleared();
}

abstract class DiscoverState {
  const DiscoverState();
}

class DiscoverInitial extends DiscoverState {
  const DiscoverInitial();
}

class DiscoverLoading extends DiscoverState {
  const DiscoverLoading();
}

class DiscoverReady extends DiscoverState {
  final List<PokemonSummary> results;
  final bool hasMore;
  final bool isLoadingMore;
  final String? errorMessage;
  final bool isSearch;

  const DiscoverReady({
    required this.results,
    required this.hasMore,
    this.isLoadingMore = false,
    this.errorMessage,
    this.isSearch = false,
  });
}

class DiscoverFailure extends DiscoverState {
  final String message;
  final bool isSearch;

  const DiscoverFailure(this.message, {this.isSearch = false});
}

class DiscoverBloc extends Bloc<DiscoverEvent, DiscoverState> {
  final FetchPokemonPage fetchPage;
  final SearchPokemon search;

  String? _searchQuery;

  DiscoverBloc({required this.fetchPage, required this.search})
    : super(const DiscoverInitial()) {
    on<DiscoverStarted>(_onStarted);
    on<LoadMore>(_onLoadMore);
    on<Retry>(_onRetry);
    on<SearchSubmitted>(_onSearchSubmitted);
    on<SearchCleared>(_onSearchCleared);
  }

  Future<void> _onStarted(
    DiscoverStarted event,
    Emitter<DiscoverState> emit,
  ) async {
    emit(const DiscoverLoading());
    await _fetch(offset: 0, results: const [], hasMore: true, emit: emit);
  }

  Future<void> _onLoadMore(LoadMore event, Emitter<DiscoverState> emit) async {
    final current = state;

    if (current is! DiscoverReady ||
        current.isLoadingMore ||
        !current.hasMore) {
      return;
    }

    emit(
      DiscoverReady(
        results: current.results,
        hasMore: current.hasMore,
        isLoadingMore: true,
      ),
    );

    await _fetch(
      offset: current.results.length,
      results: current.results,
      hasMore: current.hasMore,
      emit: emit,
    );
  }

  Future<void> _onRetry(Retry event, Emitter<DiscoverState> emit) async {
    final current = state;

    if (current is DiscoverFailure && current.isSearch) {
      await _runSearch(_searchQuery ?? '', emit);
      return;
    }

    if (current is DiscoverReady) {
      if (current.isLoadingMore || !current.hasMore) return;

      emit(
        DiscoverReady(
          results: current.results,
          hasMore: current.hasMore,
          isLoadingMore: true,
        ),
      );

      await _fetch(
        offset: current.results.length,
        results: current.results,
        hasMore: current.hasMore,
        emit: emit,
      );
      return;
    }

    if (current is DiscoverFailure) {
      emit(const DiscoverLoading());
      await _fetch(offset: 0, results: const [], hasMore: true, emit: emit);
    }
  }

  Future<void> _onSearchSubmitted(
    SearchSubmitted event,
    Emitter<DiscoverState> emit,
  ) async {
    final query = event.query.trim();
    if (query.isEmpty) return;

    _searchQuery = query;
    await _runSearch(query, emit);
  }

  void _onSearchCleared(SearchCleared event, Emitter<DiscoverState> emit) {
    _searchQuery = null;
    add(const DiscoverStarted());
  }

  Future<void> _runSearch(String query, Emitter<DiscoverState> emit) async {
    emit(const DiscoverLoading());

    try {
      final summary = await search(query);

      if (emit.isDone) return;

      emit(DiscoverReady(results: [summary], hasMore: false, isSearch: true));
    } catch (_) {
      if (emit.isDone) return;

      emit(const DiscoverFailure('Unable to find Pokemon.', isSearch: true));
    }
  }

  Future<void> _fetch({
    required int offset,
    required List<PokemonSummary> results,
    required bool hasMore,
    required Emitter<DiscoverState> emit,
  }) async {
    try {
      final page = await fetchPage(offset: offset);

      if (emit.isDone) return;

      emit(
        DiscoverReady(
          results: [...results, ...page.results],
          hasMore: page.hasMore,
        ),
      );
    } catch (_) {
      if (emit.isDone) return;

      if (results.isEmpty) {
        emit(const DiscoverFailure('Unable to load Pokemon.'));
        return;
      }

      emit(
        DiscoverReady(
          results: results,
          hasMore: hasMore,
          isLoadingMore: false,
          errorMessage: 'Unable to load Pokemon.',
        ),
      );
    }
  }
}
