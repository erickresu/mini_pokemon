import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../domain/entities/pokemon.dart';
import '../../domain/repositories/pokemon_catalog_repository.dart';
import '../../domain/usecases/get_pokemon_details.dart';
import '../blocs/detail_bloc.dart';
import '../widgets/pokemon_network_portrait.dart';

class PokemonDetailPage extends StatelessWidget {
  const PokemonDetailPage({super.key, required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DetailBloc>(
      create: (context) {
        final bloc = DetailBloc(
          getDetails: GetPokemonDetails(
            context.read<PokemonCatalogRepository>(),
          ),
        )..add(DetailStarted(name));
        return bloc;
      },
      child: const _DetailView(),
    );
  }
}

class _DetailView extends StatelessWidget {
  const _DetailView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pokémon details')),
      body: BlocBuilder<DetailBloc, DetailState>(
        builder: (context, state) {
          if (state is DetailInitial || state is DetailLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DetailFailure) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context.read<DetailBloc>().add(Retry()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is DetailReady) {
            return _detail(context, state.pokemon);
          }

          return const Center(child: Text('Unable to load Pokémon details.'));
        },
      ),
    );
  }

  Widget _detail(BuildContext context, Pokemon pokemon) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 180,
            color: const Color(0xFFE8E9E0),
            child: PokemonNetworkPortrait(url: pokemon.portraitUrl),
          ),
          const SizedBox(height: 16),
          Text(
            pokemon.name.toUpperCase(),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            pokemon.types.join(' / ').toUpperCase(),
            style: theme.textTheme.labelLarge?.copyWith(
              color: const Color(0xFFBA4938),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          _stat('HP', pokemon.hp),
          _stat('Attack', pokemon.attack),
          _stat('Defense', pokemon.defense),
          _stat('Special Attack', pokemon.specialAttack),
          _stat('Special Defense', pokemon.specialDefense),
          _stat('Speed', pokemon.speed),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(pokemon),
            child: const Text('Collect'),
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text('$value', style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
