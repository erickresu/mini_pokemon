import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../../domain/entities/pokemon.dart';
import '../../domain/entities/pokemon_summary.dart';
import '../../domain/repositories/pokemon_catalog_repository.dart';
import '../../domain/usecases/fetch_pokemon_page.dart';
import '../../domain/usecases/search_pokemon.dart';
import '../blocs/collection_bloc.dart';
import '../blocs/discover_bloc.dart';
import 'pokemon_detail_page.dart';

class PokemonDiscoverPage extends StatelessWidget {
  const PokemonDiscoverPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DiscoverBloc>(
      create: (context) {
        final catalog = context.read<PokemonCatalogRepository>();
        final bloc = DiscoverBloc(
          fetchPage: FetchPokemonPage(catalog),
          search: SearchPokemon(catalog),
        )..add(const DiscoverStarted());
        return bloc;
      },
      child: const _DiscoverView(),
    );
  }
}

class _DiscoverView extends StatefulWidget {
  const _DiscoverView();

  @override
  State<_DiscoverView> createState() => _DiscoverViewState();
}

class _DiscoverViewState extends State<_DiscoverView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openDetail(BuildContext context, PokemonSummary summary) async {
    final collectionBloc = context.read<CollectionBloc>();

    final pokemon = await Navigator.of(context).push<Pokemon>(
      MaterialPageRoute<Pokemon>(
        builder: (context) => PokemonDetailPage(name: summary.name),
      ),
    );

    if (!context.mounted || pokemon == null) return;

    collectionBloc.add(PokemonCollected(pokemon));
    Navigator.of(context).pop();
  }

  void _submit() {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    context.read<DiscoverBloc>().add(SearchSubmitted(query));
  }

  void _clear() {
    _searchController.clear();
    context.read<DiscoverBloc>().add(const SearchCleared());
  }

  bool _isSearching(DiscoverState state) {
    return (state is DiscoverReady && state.isSearch) ||
        (state is DiscoverFailure && state.isSearch);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DiscoverBloc, DiscoverState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: SizedBox(
              height: 40,
              child: TextField(
                key: const Key('search-field'),
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onChanged: (value) =>
                    context.read<DiscoverBloc>().add(SearchQueryChanged(value)),
                onSubmitted: (_) => _submit(),
                decoration: const InputDecoration(
                  hintText: 'Search by name',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: _submit, child: const Text('Search')),
              if (_isSearching(state))
                TextButton(onPressed: _clear, child: const Text('Clear')),
            ],
          ),
          body: _body(context, state),
        );
      },
    );
  }

  Widget _body(BuildContext context, DiscoverState state) {
    if (state is DiscoverInitial || state is DiscoverLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is DiscoverFailure) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(state.message),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.read<DiscoverBloc>().add(Retry()),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state is! DiscoverReady) {
      return const Center(child: Text('Unable to load Pokemon.'));
    }

    if (state.isSearch && state.results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(state.errorMessage ?? 'No Pokemon found.'),
            if (state.errorMessage != null && state.query != null) ...[
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => context.read<DiscoverBloc>().add(
                  SearchQueryChanged(state.query!),
                ),
                child: const Text('Retry'),
              ),
            ],
          ],
        ),
      );
    }

    final results = state.results;
    final showFooter =
        !state.isSearch &&
        (state.hasMore || state.isLoadingMore || state.errorMessage != null);

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      itemCount: results.length + (showFooter ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == results.length) {
          return _footer(context, state);
        }

        final summary = results[index];
        return ListTile(
          leading: const Icon(Icons.catching_pokemon),
          title: Text(summary.name.toUpperCase()),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _openDetail(context, summary),
        );
      },
    );
  }

  Widget _footer(BuildContext context, DiscoverReady state) {
    final bloc = context.read<DiscoverBloc>();

    if (state.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (state.errorMessage != null) ...[
            Text(state.errorMessage!),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => bloc.add(Retry()),
              child: const Text('Retry'),
            ),
          ] else if (state.hasMore)
            OutlinedButton(
              onPressed: () => bloc.add(LoadMore()),
              child: const Text('Load more'),
            ),
        ],
      ),
    );
  }
}
