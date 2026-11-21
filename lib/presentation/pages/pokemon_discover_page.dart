import 'package:material_ui/material_ui.dart';

class PokemonDiscoverPage extends StatelessWidget {
  const PokemonDiscoverPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Discover Pokemon')),
      body: const Center(child: Text('Discover flow next.')),
    );
  }
}
