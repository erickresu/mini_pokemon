import '../repositories/collection_repository.dart';

class RemovePokemon {
  final CollectionRepository _repository;

  const RemovePokemon(this._repository);

  Future<void> call(int apiId) => _repository.remove(apiId);
}
