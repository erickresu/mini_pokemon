import 'package:material_ui/material_ui.dart';

class PokemonNetworkPortrait extends StatelessWidget {
  const PokemonNetworkPortrait({super.key, required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    const placeholder = Icon(Icons.catching_pokemon, size: 38);
    final imageUrl = url;
    if (imageUrl == null || imageUrl.isEmpty) return placeholder;

    return Image.network(
      imageUrl,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : placeholder,
      errorBuilder: (context, error, stackTrace) => placeholder,
    );
  }
}
