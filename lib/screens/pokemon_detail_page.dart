import 'package:material_ui/material_ui.dart';

import '../models/poke_api_pokemon.dart';
import '../services/poke_api_service.dart';
import '../widgets/pokemon_network_portrait.dart';

class PokemonDetailPage extends StatefulWidget {
  const PokemonDetailPage({
    super.key,
    required this.name,
    required this.service,
  });

  final String name;
  final PokeApiService service;

  @override
  State<PokemonDetailPage> createState() => _PokemonDetailPageState();
}

class _PokemonDetailPageState extends State<PokemonDetailPage> {
  late Future<PokeApiPokemon> _request;

  @override
  void initState() {
    super.initState();
    _request = widget.service.fetchPokemon(widget.name);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Pokémon details')),
      body: FutureBuilder<PokeApiPokemon>(
        future: _request,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Unable to load Pokémon details.'),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => setState(() {
                      _request = widget.service.fetchPokemon(widget.name);
                    }),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final pokemon = snapshot.requireData;
          final stats = {
            'HP': pokemon.hp,
            'Attack': pokemon.attack,
            'Defense': pokemon.defense,
            'Special Attack': pokemon.specialAttack,
            'Special Defense': pokemon.specialDefense,
            'Speed': pokemon.speed,
          };
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              SizedBox(
                height: 200,
                child: PokemonNetworkPortrait(url: pokemon.portraitUrl),
              ),
              const SizedBox(height: 12),
              Text(
                pokemon.name.toUpperCase(),
                style: theme.textTheme.headlineMedium,
              ),
              Text(pokemon.types.join(' / ').toUpperCase()),
              const SizedBox(height: 16),
              Text('Base stats', style: theme.textTheme.titleMedium),
              for (final stat in stats.entries)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(stat.key),
                  trailing: Text('${stat.value}'),
                ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(pokemon),
                icon: const Icon(Icons.add),
                label: const Text('Collect'),
              ),
            ],
          );
        },
      ),
    );
  }
}
