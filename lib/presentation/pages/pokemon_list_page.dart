import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../domain/entities/pokemon.dart';
import '../blocs/collection_bloc.dart';
import '../widgets/pokemon_card.dart';
import '../widgets/pokemon_form_dialog.dart';
import 'pokemon_discover_page.dart';

class PokemonListPage extends StatelessWidget {
  const PokemonListPage({
    super.key,
    this.startupError,
    this.onDismissStartupError,
  });

  final String? startupError;
  final VoidCallback? onDismissStartupError;

  Future<void> _confirmDelete(BuildContext context, Pokemon pokemon) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Delete ${pokemon.name}?'),
          content: const Text(
            'This removes the entry from your local collection.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      context.read<CollectionBloc>().add(PokemonRemoved(pokemon.apiId));
    }
  }

  Future<void> _edit(BuildContext context, Pokemon pokemon) async {
    final updated = await PokemonFormDialog.edit(context, pokemon);

    if (updated != null && context.mounted) {
      context.read<CollectionBloc>().add(PokemonUpdated(updated));
    }
  }

  void _openDiscover(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const PokemonDiscoverPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CollectionBloc, CollectionState>(
      listener: (context, state) {
        if (state is CollectionReady && state.notice != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.notice!)));
        }
      },
      child: BlocBuilder<CollectionBloc, CollectionState>(
        builder: (context, state) {
          final ready = state is CollectionReady ? state : null;
          final favoritesOnly = ready?.favoritesOnly ?? false;
          final pokemons = ready?.pokemons ?? const <Pokemon>[];

          return Scaffold(
            appBar: AppBar(title: const Text('My Collection')),
            body: _body(context, state, pokemons, favoritesOnly),
            bottomNavigationBar: NavigationBar(
              selectedIndex: favoritesOnly ? 2 : 0,
              onDestinationSelected: (index) {
                if (index == 1) {
                  _openDiscover(context);
                  return;
                }
                context.read<CollectionBloc>().add(
                  CollectionFilterChanged(favoritesOnly: index == 2),
                );
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.catching_pokemon_outlined),
                  label: 'Collection',
                ),
                NavigationDestination(
                  icon: Icon(Icons.add_circle_outline),
                  label: 'Add Pokemon',
                ),
                NavigationDestination(
                  icon: Icon(Icons.star_border),
                  selectedIcon: Icon(Icons.star),
                  label: 'Favorites',
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _body(
    BuildContext context,
    CollectionState state,
    List<Pokemon> pokemons,
    bool favoritesOnly,
  ) {
    if (state is CollectionInitial || state is CollectionLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is! CollectionReady) {
      return const Center(child: Text('Unable to load collection.'));
    }

    return Column(
      children: [
        if (startupError != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: MaterialBanner(
              content: Text(startupError!),
              leading: const Icon(Icons.warning_amber_rounded),
              actions: [
                TextButton(
                  onPressed: onDismissStartupError,
                  child: const Text('Dismiss'),
                ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${pokemons.length} Pokemon',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ),
        Expanded(
          child: pokemons.isEmpty
              ? Center(
                  child: Text(
                    favoritesOnly
                        ? 'No favorites yet. Star a Pokemon to see it here.'
                        : 'No Pokemon yet. Add your first one!',
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: pokemons.length,
                  itemBuilder: (context, index) {
                    final pokemon = pokemons[index];
                    return PokemonCard(
                      pokemon: pokemon,
                      onDelete: () => _confirmDelete(context, pokemon),
                      onEdit: () => _edit(context, pokemon),
                      onFavoriteToggled: () => context
                          .read<CollectionBloc>()
                          .add(PokemonFavoriteToggled(pokemon)),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
