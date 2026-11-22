import '../entities/pokemon.dart';

abstract class CollectionRepository {
  Stream<List<Pokemon>> watchAll();

  Future<void> add(Pokemon pokemon);

  Future<void> update(Pokemon pokemon);

  Future<void> remove(int apiId);
}
