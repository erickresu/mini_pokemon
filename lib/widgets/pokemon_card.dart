import 'dart:io';

import 'package:material_ui/material_ui.dart';

import '../models/pokemon.dart';

class PokemonCard extends StatelessWidget {
  const PokemonCard({
    super.key,
    required this.pokemon,
    required this.onEdit,
    required this.onDelete,
  });

  final Pokemon pokemon;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  Color get _accent => switch (pokemon.type.trim().toLowerCase()) {
    'fire' => const Color(0xFF9E451F),
    'water' => const Color(0xFF245F9B),
    'grass' || 'earth' => const Color(0xFF356E40),
    'electric' => const Color(0xFF806000),
    _ => const Color(0xFF526477),
  };

  @override
  Widget build(BuildContext context) {
    final accent = _accent;
    final path = pokemon.imagePath;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFE0E5E9)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 68,
                    height: 68,
                    color: accent.withAlpha(24),
                    child: path == null
                        ? Icon(Icons.catching_pokemon, color: accent, size: 34)
                        : Image.file(
                            File(path),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(Icons.catching_pokemon, color: accent),
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('#${pokemon.id}', style: Theme.of(context).textTheme.labelSmall),
                      Text(
                        pokemon.name,
                        style: Theme.of(context).textTheme.titleLarge,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(pokemon.type, style: TextStyle(color: accent, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Edit ${pokemon.name}',
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  tooltip: 'Delete ${pokemon.name}',
                  onPressed: onDelete,
                  color: Theme.of(context).colorScheme.error,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            Row(
              children: [
                Expanded(child: _stat(context, 'HP', pokemon.hp, Icons.favorite_border)),
                Expanded(child: _stat(context, 'ATK', pokemon.attack, Icons.flash_on_outlined)),
                Expanded(child: _stat(context, 'DEF', pokemon.defense, Icons.shield_outlined)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(BuildContext context, String label, int value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 18, color: _accent),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        Text('$value', style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}
