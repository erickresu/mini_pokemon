import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import 'core/theme/app_theme.dart';
import 'data/datasources/poke_api_service.dart';
import 'data/repositories/in_memory_collection_repository.dart';
import 'data/repositories/poke_api_catalog_repository.dart';
import 'domain/repositories/collection_repository.dart';
import 'domain/repositories/pokemon_catalog_repository.dart';
import 'domain/usecases/collect_pokemon.dart';
import 'domain/usecases/remove_pokemon.dart';
import 'domain/usecases/watch_collection.dart';
import 'presentation/blocs/collection_bloc.dart';
import 'presentation/pages/pokemon_list_page.dart';

void main() {
  final collectionRepository = InMemoryCollectionRepository();
  final catalogRepository = PokeApiCatalogRepository(PokeApiService());

  runApp(
    MyApp(
      collectionRepository: collectionRepository,
      catalogRepository: catalogRepository,
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.collectionRepository,
    required this.catalogRepository,
  });

  final CollectionRepository collectionRepository;
  final PokemonCatalogRepository catalogRepository;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<PokemonCatalogRepository>.value(
      value: catalogRepository,
      child: BlocProvider<CollectionBloc>(
        create: (context) {
          final bloc = CollectionBloc(
            watch: WatchCollection(collectionRepository),
            collect: CollectPokemon(collectionRepository),
            remove: RemovePokemon(collectionRepository),
          )..add(const CollectionStarted());
          return bloc;
        },
        child: MaterialApp(
          title: 'Mini Pokemon',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          home: const PokemonListPage(),
        ),
      ),
    );
  }
}
