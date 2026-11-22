import '../entities/pokemon.dart';
import '../repositories/collection_repository.dart';

class CollectPokemon {
  final CollectionRepository _repository;
  final Set<int> _inFlightApiIds = <int>{};

  CollectPokemon(this._repository);

  Future<bool> call(Pokemon pokemon) async {
    if (!_inFlightApiIds.add(pokemon.apiId)) return false;
    try {
      final current = await _repository.watchAll().first;

      if (current.any((item) => item.apiId == pokemon.apiId)) {
        return false;
      }

      await _repository.add(pokemon);
      return true;
    } finally {
      _inFlightApiIds.remove(pokemon.apiId);
    }
  }
}
