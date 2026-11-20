import 'dart:io';

import 'package:material_ui/material_ui.dart';

import '../models/pokemon.dart';
import 'pokemon_network_portrait.dart';

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
    'fire' => const Color(0xFFAA5136),
    'water' => const Color(0xFF48788B),
    'grass' || 'earth' => const Color(0xFF4A7456),
    'electric' => const Color(0xFF806000),
    _ => const Color(0xFF526477),
  };

  @override
  Widget build(BuildContext context) {
    final accent = _accent;
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: const Color(0xFFFAF9F4),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFFC8CBBF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: const Color(0xFFE8E9E0),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Text(
                  'ENTRY / ${pokemon.id.toString().padLeft(3, '0')}',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    pokemon.type.toUpperCase(),
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: accent,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    width: 96,
                    height: 108,
                    color: accent.withAlpha(25),
                    padding: const EdgeInsets.all(6),
                    child: _portrait(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pokemon.name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      _stat('HP', pokemon.hp),
                      _stat('ATK', pokemon.attack),
                      _stat('DEF', pokemon.defense),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFD9DBD0)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Edit'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF414B40),
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Delete'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF9C4032),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _portrait() {
    final path = pokemon.imagePath;
    final asset = pokemon.assetPath;
    if (path != null) {
      return Image.file(
        File(path),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => _placeholder(),
      );
    }
    if (asset != null) {
      return Image.asset(
        asset,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => _placeholder(),
      );
    }
    final officialData = pokemon.officialData;
    if (officialData != null) {
      return PokemonNetworkPortrait(url: officialData.portraitUrl);
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return Icon(Icons.catching_pokemon, color: _accent, size: 38);
  }

  Widget _stat(String label, int value) {
    // A visual reference scale, not a gameplay maximum.
    final fraction = (value / 150).clamp(0.0, 1.0).toDouble();
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(label, style: const TextStyle(fontSize: 11)),
          ),
          Expanded(
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 5,
              color: _accent,
              backgroundColor: const Color(0xFFE1E4DB),
            ),
          ),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              '$value',
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
