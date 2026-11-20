import 'package:material_ui/material_ui.dart';

import '../models/poke_api_pokemon.dart';
import '../models/poke_api_pokemon_summary.dart';
import '../services/poke_api_service.dart';
import 'pokemon_detail_page.dart';

class PokemonDiscoverPage extends StatefulWidget {
  const PokemonDiscoverPage({super.key, this.service});

  final PokeApiService? service;

  @override
  State<PokemonDiscoverPage> createState() => _PokemonDiscoverPageState();
}

class _PokemonDiscoverPageState extends State<PokemonDiscoverPage> {
  late final PokeApiService _service = widget.service ?? PokeApiService();

  final List<PokeApiPokemonSummary> _pokemons = [];

  bool _isLoading = false;
  bool _hasMore = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPokemon();
  }

  Future<void> _loadPokemon() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final page = await _service.fetchPokemonPage(offset: _pokemons.length);

      if (!mounted) return;

      setState(() {
        _pokemons.addAll(page.results);
        _hasMore = page.hasMore;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'Unable to load Pokemon.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Discover Pokemon')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_pokemons.isEmpty && _isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_pokemons.isEmpty && _errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_errorMessage!),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _loadPokemon, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_pokemons.isEmpty) {
      return const Center(child: Text('No Pokemon found.'));
    }

    return ListView.builder(
      itemCount: _pokemons.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _pokemons.length) return _buildPaginationFooter();
        final pokemon = _pokemons[index];

        return ListTile(
          leading: const Icon(Icons.catching_pokemon),
          title: Text(pokemon.name.toUpperCase()),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _openDetail(pokemon.name),
        );
      },
    );
  }

  Future<void> _openDetail(String name) async {
    final pokemon = await Navigator.of(context).push<PokeApiPokemon>(
      MaterialPageRoute(
        builder: (context) => PokemonDetailPage(name: name, service: _service),
      ),
    );

    if (!mounted || pokemon == null) return;
    Navigator.of(context).pop(pokemon);
  }

  Widget _buildPaginationFooter() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (_errorMessage != null) Text(_errorMessage!),
          if (_isLoading)
            const CircularProgressIndicator()
          else
            OutlinedButton(
              onPressed: _loadPokemon,
              child: Text(_errorMessage == null ? 'Load more' : 'Retry'),
            ),
        ],
      ),
    );
  }
}
