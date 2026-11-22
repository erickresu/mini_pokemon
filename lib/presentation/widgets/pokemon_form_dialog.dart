import 'package:material_ui/material_ui.dart';

import '../../domain/entities/pokemon.dart';

class PokemonFormDialog extends StatefulWidget {
  const PokemonFormDialog._({required this.pokemon});

  final Pokemon pokemon;

  static Future<Pokemon?> edit(BuildContext context, Pokemon pokemon) {
    return showDialog<Pokemon>(
      context: context,
      builder: (dialogContext) => PokemonFormDialog._(pokemon: pokemon),
    );
  }

  @override
  State<PokemonFormDialog> createState() => _PokemonFormDialogState();
}

class _PokemonFormDialogState extends State<PokemonFormDialog> {
  late final TextEditingController _name;
  late final TextEditingController _types;
  late final TextEditingController _hp;
  late final TextEditingController _attack;
  late final TextEditingController _defense;
  late final TextEditingController _specialAttack;
  late final TextEditingController _specialDefense;
  late final TextEditingController _speed;
  late final TextEditingController _portraitUrl;
  String? _error;

  @override
  void initState() {
    super.initState();
    final pokemon = widget.pokemon;
    _name = TextEditingController(text: pokemon.name);
    _types = TextEditingController(text: pokemon.types.join(', '));
    _hp = TextEditingController(text: '${pokemon.hp}');
    _attack = TextEditingController(text: '${pokemon.attack}');
    _defense = TextEditingController(text: '${pokemon.defense}');
    _specialAttack = TextEditingController(text: '${pokemon.specialAttack}');
    _specialDefense = TextEditingController(text: '${pokemon.specialDefense}');
    _speed = TextEditingController(text: '${pokemon.speed}');
    _portraitUrl = TextEditingController(text: pokemon.portraitUrl ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _types.dispose();
    _hp.dispose();
    _attack.dispose();
    _defense.dispose();
    _specialAttack.dispose();
    _specialDefense.dispose();
    _speed.dispose();
    _portraitUrl.dispose();
    super.dispose();
  }

  void _save() {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Name is required.');
      return;
    }

    final types = _types.text
        .split(',')
        .map((type) => type.trim())
        .where((type) => type.isNotEmpty)
        .toList();
    if (types.isEmpty) {
      setState(() => _error = 'At least one type is required.');
      return;
    }

    final statControllers = [
      _hp,
      _attack,
      _defense,
      _specialAttack,
      _specialDefense,
      _speed,
    ];
    final stats = <int>[];
    for (final controller in statControllers) {
      final value = int.tryParse(controller.text.trim());
      if (value == null || value < 0) {
        setState(() => _error = 'Stats must be whole numbers of zero or more.');
        return;
      }
      stats.add(value);
    }

    Navigator.of(context).pop(
      widget.pokemon.copyWith(
        name: name,
        types: types,
        hp: stats[0],
        attack: stats[1],
        defense: stats[2],
        specialAttack: stats[3],
        specialDefense: stats[4],
        speed: stats[5],
        portraitUrl: _portraitUrl.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Pokemon'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              key: const Key('edit-name'),
              controller: _name,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _types,
              decoration: const InputDecoration(
                labelText: 'Types (comma separated)',
              ),
            ),
            _statField('HP', _hp),
            _statField('Attack', _attack),
            _statField('Defense', _defense),
            _statField('Special Attack', _specialAttack),
            _statField('Special Defense', _specialDefense),
            _statField('Speed', _speed),
            TextField(
              controller: _portraitUrl,
              decoration: const InputDecoration(
                labelText: 'Portrait URL (optional)',
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Color(0xFFBA4938))),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }

  Widget _statField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label),
    );
  }
}
