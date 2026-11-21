import '../entities/pokemon.dart';
import '../repositories/collection_repository.dart';

class WatchCollection {
  final CollectionRepository _repository;

  const WatchCollection(this._repository);

  Stream<List<Pokemon>> call() => _repository.watchAll();
}
