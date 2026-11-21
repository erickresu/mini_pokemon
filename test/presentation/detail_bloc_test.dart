import 'package:flutter_test/flutter_test.dart' hide Retry;
import 'package:mini_pokemon/domain/usecases/get_pokemon_details.dart';
import 'package:mini_pokemon/presentation/blocs/detail_bloc.dart';

import '../fakes/fake_catalog_repository.dart';

void main() {
  test('loads detail and retries the same name', () async {
    final catalog = FakeCatalogRepository(failDetails: true);
    final bloc = DetailBloc(getDetails: GetPokemonDetails(catalog));

    final failure = bloc.stream.firstWhere((s) => s is DetailFailure);
    bloc.add(const DetailStarted('bulbasaur'));
    await failure.timeout(const Duration(seconds: 1));

    final ready = bloc.stream.firstWhere((s) => s is DetailReady);
    bloc.add(Retry());
    final state =
        await ready.timeout(const Duration(seconds: 1)) as DetailReady;

    expect(state.pokemon.apiId, 1);
    expect(catalog.names, ['bulbasaur', 'bulbasaur']);
    await bloc.close();
  });
}
