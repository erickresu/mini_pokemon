import '../entities/pokemon.dart';
import '../repositories/collection_repository.dart';

class ToggleFavorite {
  final CollectionRepository _repository;

  const ToggleFavorite(this._repository);

  Future<void> call(Pokemon pokemon) {
    return _repository.update(
      pokemon.copyWith(isFavorite: !pokemon.isFavorite),
    );
  }
}
