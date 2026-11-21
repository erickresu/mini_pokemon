import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/pokemon.dart';
import '../../domain/usecases/get_pokemon_details.dart';

abstract class DetailEvent {
  const DetailEvent();
}

class DetailStarted extends DetailEvent {
  final String name;

  const DetailStarted(this.name);
}

class Retry extends DetailEvent {
  const Retry();
}

abstract class DetailState {
  const DetailState();
}

class DetailInitial extends DetailState {
  const DetailInitial();
}

class DetailLoading extends DetailState {
  const DetailLoading();
}

class DetailReady extends DetailState {
  final Pokemon pokemon;

  const DetailReady(this.pokemon);
}

class DetailFailure extends DetailState {
  final String message;

  const DetailFailure(this.message);
}

class DetailBloc extends Bloc<DetailEvent, DetailState> {
  final GetPokemonDetails getDetails;

  String? _name;

  DetailBloc({required this.getDetails}) : super(const DetailInitial()) {
    on<DetailStarted>(_onStarted);
    on<Retry>(_onRetry);
  }

  Future<void> _onStarted(
    DetailStarted event,
    Emitter<DetailState> emit,
  ) async {
    _name = event.name;
    await _load(emit);
  }

  Future<void> _onRetry(Retry event, Emitter<DetailState> emit) async {
    final name = _name;
    if (name == null) return;
    await _load(emit);
  }

  Future<void> _load(Emitter<DetailState> emit) async {
    final name = _name;
    if (name == null) return;

    emit(const DetailLoading());

    try {
      final pokemon = await getDetails(name);

      if (emit.isDone) return;

      emit(DetailReady(pokemon));
    } catch (_) {
      if (emit.isDone) return;

      emit(const DetailFailure('Unable to load Pokémon details.'));
    }
  }
}
