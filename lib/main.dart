import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import 'core/theme/app_theme.dart';
import 'data/datasources/poke_api_service.dart';
import 'data/datasources/pokemon_database.dart';
import 'data/repositories/in_memory_collection_repository.dart';
import 'data/repositories/poke_api_catalog_repository.dart';
import 'data/repositories/sqlite_collection_repository.dart';
import 'domain/repositories/collection_repository.dart';
import 'domain/repositories/pokemon_catalog_repository.dart';
import 'domain/usecases/collect_pokemon.dart';
import 'domain/usecases/remove_pokemon.dart';
import 'domain/usecases/toggle_favorite.dart';
import 'domain/usecases/update_pokemon.dart';
import 'domain/usecases/watch_collection.dart';
import 'presentation/blocs/collection_bloc.dart';
import 'presentation/pages/pokemon_list_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final useSqlite = const bool.fromEnvironment('USE_SQLITE');
  CollectionRepository? collectionRepository;
  String? startupError;
  if (useSqlite) {
    try {
      collectionRepository = SqliteCollectionRepository(
        await openPokemonDatabase(),
      );
    } catch (_) {
      startupError =
          'Unable to open local storage. Running in memory this session.';
    }
  }
  collectionRepository ??= InMemoryCollectionRepository();
  final catalogRepository = PokeApiCatalogRepository(PokeApiService());

  runApp(
    MyApp(
      collectionRepository: collectionRepository,
      catalogRepository: catalogRepository,
      startupError: startupError,
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
    required this.catalogRepository,
    this.collectionRepository,
    this.startupError,
  });

  final PokemonCatalogRepository catalogRepository;
  final CollectionRepository? collectionRepository;
  final String? startupError;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late CollectionRepository _collectionRepository;
  String? _startupError;

  @override
  void initState() {
    super.initState();
    _collectionRepository =
        widget.collectionRepository ?? InMemoryCollectionRepository();
    _startupError = widget.startupError;
  }

  void _dismissStartupError() {
    setState(() => _startupError = null);
  }

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<PokemonCatalogRepository>.value(
      value: widget.catalogRepository,
      child: BlocProvider<CollectionBloc>(
        create: (context) {
          final bloc = CollectionBloc(
            watch: WatchCollection(_collectionRepository),
            collect: CollectPokemon(_collectionRepository),
            remove: RemovePokemon(_collectionRepository),
            update: UpdatePokemon(_collectionRepository),
            toggleFavorite: ToggleFavorite(_collectionRepository),
          )..add(const CollectionStarted());
          return bloc;
        },
        child: MaterialApp(
          title: 'Mini Pokemon',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          home: PokemonListPage(
            startupError: _startupError,
            onDismissStartupError: _dismissStartupError,
          ),
        ),
      ),
    );
  }
}
