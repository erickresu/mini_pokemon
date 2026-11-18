import 'package:material_ui/material_ui.dart';

import '../models/pokemon.dart';
import '../widgets/pokemon_form_dialog.dart';

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
      appBar: AppBar(title: const Text('Mini Pokemon')),

      floatingActionButton: FloatingActionButton(
        onPressed: _showAddPokemonDialog,
        child: const Icon(Icons.add),
      ),

      body: ListView.builder(
        itemCount: _pokemons.length,
        itemBuilder: (context, index) {
          final pokemon = _pokemons[index];

          return ListTile(
            title: Text(pokemon.name),
            subtitle: Text('${pokemon.type} | HP: ${pokemon.hp}'),

            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    _showEditPokemonDialog(index);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  color: Colors.red,
                  onPressed: () {
                    _deletePokemon(index);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
