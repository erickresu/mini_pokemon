import '../entities/pokemon.dart';
import '../repositories/collection_repository.dart';

class UpdatePokemon {
  final CollectionRepository _repository;

  const UpdatePokemon(this._repository);

  Future<void> call(Pokemon pokemon) => _repository.update(pokemon);
}
