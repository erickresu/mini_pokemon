import 'package:material_ui/material_ui.dart';

import '../models/pokemon.dart';
import '../widgets/pokemon_form_dialog.dart';
import '../widgets/pokemon_card.dart';

class PokemonListPage extends StatefulWidget {
  const PokemonListPage({super.key});

  @override
  State<PokemonListPage> createState() => _PokemonListPageState();
}

class _PokemonListPageState extends State<PokemonListPage> {
  final List<Pokemon> _pokemons = [
    const Pokemon(
      id: 1,
      name: 'Charmander',
      type: 'Fire',
      hp: 100,
      attack: 52,
      defense: 43,
    ),
    const Pokemon(
      id: 2,
      name: 'Squirtle',
      type: 'Water',
      hp: 110,
      attack: 48,
      defense: 65,
    ),
    const Pokemon(
      id: 3,
      name: 'Bulbasaur',
      type: 'Grass',
      hp: 90,
      attack: 49,
      defense: 49,
    ),
  ];
  int _nextId = 4;

  Future<void> _showAddPokemonDialog() async {
    final pokemon = await showDialog<Pokemon>(
      context: context,
      builder: (dialogContext) {
        return PokemonFormDialog(id: _nextId);
      },
    );

    if (!mounted || pokemon == null) return;

    setState(() {
      _pokemons.add(pokemon);
      _nextId++;
    });
  }

  Future<void> _showEditPokemonDialog(int index) async {
    final pokemon = _pokemons[index];

    final updatedPokemon = await showDialog<Pokemon>(
      context: context,
      builder: (dialogContext) {
        return PokemonFormDialog(id: pokemon.id, pokemon: pokemon);
      },
    );

    if (!mounted || updatedPokemon == null) return;

    setState(() {
      _pokemons[index] = updatedPokemon;
    });
  }

  Future<void> _deletePokemon(int index) async {
    final pokemon = _pokemons[index];

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Pokemon'),
          content: Text('Are you sure you want to delete ${pokemon.name}?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmed != true) return;

    setState(() {
      _pokemons.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: const Text('Mini Pokemon'),
        backgroundColor: const Color(0xFFF4F6F8),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: Icon(Icons.catching_pokemon, size: 30),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddPokemonDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Pokemon'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('MY COLLECTION', style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(height: 6),
                Text('${_pokemons.length} Pokemon', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 4),
                const Text('Build and manage your team.'),
              ],
            ),
          ),
          Expanded(
            child: _pokemons.isEmpty
                ? const Center(child: Text('No Pokemon yet. Add your first one!'))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                    itemCount: _pokemons.length,
                    itemBuilder: (context, index) {
                      final pokemon = _pokemons[index];
                      return PokemonCard(
                        key: ValueKey(pokemon.id),
                        pokemon: pokemon,
                        onEdit: () => _showEditPokemonDialog(index),
                        onDelete: () => _deletePokemon(index),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
