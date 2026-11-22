import '../entities/pokemon.dart';
import '../repositories/pokemon_catalog_repository.dart';

class GetPokemonDetails {
  final PokemonCatalogRepository _repository;

  const GetPokemonDetails(this._repository);

  Future<Pokemon> call(String name) => _repository.fetchDetails(name);
}
