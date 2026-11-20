import 'dart:ui' show ImageFilter;

import 'package:material_ui/material_ui.dart';

import '../models/poke_api_pokemon.dart';
import '../models/pokemon.dart';
import '../services/poke_api_service.dart';
import '../widgets/pokemon_form_dialog.dart';
import '../widgets/pokemon_card.dart';
import 'pokemon_discover_page.dart';

class PokemonListPage extends StatefulWidget {
  const PokemonListPage({super.key, this.discoveryService});

  final PokeApiService? discoveryService;

  @override
  State<PokemonListPage> createState() => _PokemonListPageState();
}

class _PokemonListPageState extends State<PokemonListPage> {
  final List<Pokemon> _pokemons = [
    const Pokemon(
      id: 1,
      name: 'Charmander',
      assetPath: 'assets/pokemon/charmander.png',
      type: 'Fire',
      hp: 100,
      attack: 52,
      defense: 43,
    ),
    const Pokemon(
      id: 2,
      name: 'Squirtle',
      assetPath: 'assets/pokemon/squirtle.png',
      type: 'Water',
      hp: 110,
      attack: 48,
      defense: 65,
    ),
    const Pokemon(
      id: 3,
      name: 'Bulbasaur',
      assetPath: 'assets/pokemon/bulbasaur.png',
      type: 'Grass',
      hp: 90,
      attack: 49,
      defense: 49,
    ),
  ];
  int _nextId = 4;

  Future<void> _openDiscovery() async {
    final officialData = await Navigator.of(context).push<PokeApiPokemon>(
      MaterialPageRoute(
        builder: (context) =>
            PokemonDiscoverPage(service: widget.discoveryService),
      ),
    );

    if (!mounted || officialData == null) return;
    if (_pokemons.any((pokemon) => pokemon.officialData?.id == officialData.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Already in your collection.')),
      );
      return;
    }

    setState(() {
      _pokemons.add(
        Pokemon(
          id: _nextId,
          name: officialData.name[0].toUpperCase() + officialData.name.substring(1),
          type: officialData.types.join(' / '),
          hp: officialData.hp,
          attack: officialData.attack,
          defense: officialData.defense,
          officialData: officialData,
        ),
      );
      _nextId++;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Added to your collection.')),
    );
  }

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
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3EC),
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.catching_pokemon, color: Color(0xFFBA4938)),
            SizedBox(width: 10),
            Text('POKEMON', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _openDiscovery,
            child: const Text('Discover'),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 20),
            child: Center(child: Text('FIELD GUIDE', style: TextStyle(fontSize: 11, letterSpacing: 1))),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddPokemonDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Pokemon'),
      ),
      body: Stack(
        children: [
          const Positioned(
            top: 0,
            right: -60,
            child: Icon(Icons.catching_pokemon, size: 230, color: Color(0x0C394038)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    width: double.infinity,
                    color: const Color(0xD9F5F3EC),
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(color: Color(0xFF394038)),
                        Text('Collection', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Expanded(child: Text('Your Pokemon roster')),
                            Text('${_pokemons.length} Pokemon', style: const TextStyle(color: Color(0xFFBA4938), fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ],
                    ),
                  ),
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
        ],
      ),
    );
  }
}
