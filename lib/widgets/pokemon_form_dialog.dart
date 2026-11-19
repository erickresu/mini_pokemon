import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';

import '../models/pokemon.dart';

class PokemonFormDialog extends StatefulWidget {
  const PokemonFormDialog({super.key, required this.id, this.pokemon});

  final int id;
  final Pokemon? pokemon;

  @override
  State<PokemonFormDialog> createState() => _PokemonFormDialogState();
}

class _PokemonFormDialogState extends State<PokemonFormDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _imagePath;
  String? _assetPath;

  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  final _hpController = TextEditingController();
  final _attackController = TextEditingController();
  final _defenseController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final pokemon = widget.pokemon;

    if (pokemon != null) {
      _imagePath = pokemon.imagePath;
      _assetPath = pokemon.assetPath;
      _nameController.text = pokemon.name;
      _typeController.text = pokemon.type;
      _hpController.text = pokemon.hp.toString();
      _attackController.text = pokemon.attack.toString();
      _defenseController.text = pokemon.defense.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _hpController.dispose();
    _attackController.dispose();
    _defenseController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (!mounted || image == null) return;

      setState(() {
        _imagePath = image.path;
        _assetPath = null;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to select a photo. Try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.pokemon == null ? 'Add Pokemon' : 'Edit Pokemon'),
      scrollable: true,
      backgroundColor: const Color(0xFFF5F3EC),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      content: SizedBox(
        width: 340,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 90,
                  height: 90,
                  color: const Color(0xFFE5E7DC),
                  child: _imagePath == null
                      ? (_assetPath == null
                          ? const Icon(Icons.catching_pokemon, size: 40)
                          : Image.asset(_assetPath!, fit: BoxFit.contain))
                      : Image.file(
                          File(_imagePath!),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.catching_pokemon, size: 40),
                        ),
                ),
              ),

              TextButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.photo_library),
                label: const Text('Choose Photo'),
              ),

              if (_imagePath != null || _assetPath != null)
                TextButton(
                  onPressed: () => setState(() {
                    _imagePath = null;
                    _assetPath = null;
                  }),
                  child: const Text('Remove Photo'),
                ),
              const SizedBox(height: 12),

              _buildField(_nameController, 'Name'),
              _buildField(_typeController, 'Element'),
              _buildField(_hpController, 'HP', numeric: true),
              _buildField(_attackController, 'Attack', numeric: true),
              _buildField(_defenseController, 'Defense', numeric: true),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final pokemon = Pokemon(
                id: widget.id,
                name: _nameController.text.trim(),
                type: _typeController.text.trim(),
                hp: int.parse(_hpController.text.trim()),
                attack: int.parse(_attackController.text.trim()),
                defense: int.parse(_defenseController.text.trim()),
                imagePath: _imagePath,
                assetPath: _assetPath,
              );

              Navigator.pop(context, pokemon);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label, {
    bool numeric = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label),
        keyboardType: numeric ? TextInputType.number : TextInputType.text,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Required field';
          }

          if (numeric) {
            final number = int.tryParse(value.trim());

            if (number == null || number <= 0) {
              return 'Enter a positive integer';
            }
          }

          return null;
        },
      ),
    );
  }
}
