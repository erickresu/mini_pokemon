import '../entities/pokemon.dart';
import '../repositories/collection_repository.dart';

class CollectPokemon {
  final CollectionRepository _repository;

  const CollectPokemon(this._repository);

  Future<bool> call(Pokemon pokemon) async {
    final current = await _repository.watchAll().first;

    if (current.any((item) => item.apiId == pokemon.apiId)) {
      return false;
    }

    await _repository.add(pokemon);
    return true;
  }
}
