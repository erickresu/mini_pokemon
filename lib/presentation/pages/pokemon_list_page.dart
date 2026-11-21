import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../domain/entities/pokemon.dart';
import '../blocs/collection_bloc.dart';
import '../widgets/pokemon_card.dart';
import 'pokemon_discover_page.dart';

class PokemonListPage extends StatelessWidget {
  const PokemonListPage({super.key});

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
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Collection'),
          actions: [
            TextButton(
              onPressed: () => _openDiscover(context),
              child: const Text('Add New Pokemon'),
            ),
          ],
        ),
        body: BlocBuilder<CollectionBloc, CollectionState>(
          builder: (context, state) {
            if (state is CollectionInitial || state is CollectionLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is! CollectionReady) {
              return const Center(child: Text('Unable to load collection.'));
            }

            final pokemons = state.pokemons;

            return Column(
              children: [
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
                      ? const Center(
                          child: Text('No Pokemon yet. Add your first one!'),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          itemCount: pokemons.length,
                          itemBuilder: (context, index) {
                            final pokemon = pokemons[index];
                            return PokemonCard(
                              pokemon: pokemon,
                              onDelete: () => _confirmDelete(context, pokemon),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
