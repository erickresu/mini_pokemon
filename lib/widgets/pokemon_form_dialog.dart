import 'package:material_ui/material_ui.dart';

import '../models/pokemon.dart';

import 'dart:io';

import 'package:image_picker/image_picker.dart';

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
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (!mounted || image == null) return;

    setState(() {
      _imagePath = image.path;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.pokemon == null ? 'Add Pokemon' : 'Edit Pokemon'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 45,
                backgroundImage: _imagePath != null
                    ? FileImage(File(_imagePath!))
                    : null,
                child: _imagePath == null
                    ? const Icon(Icons.person, size: 40)
                    : null,
              ),

              TextButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.photo_library),
                label: const Text('Choose Photo'),
              ),

              const SizedBox(height: 10),

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
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final pokemon = Pokemon(
                id: widget.id,
                name: _nameController.text.trim(),
                type: _typeController.text.trim(),
                hp: int.parse(_hpController.text.trim()),
                attack: int.parse(_attackController.text.trim()),
                defense: int.parse(_defenseController.text.trim()),
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
    return TextFormField(
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
    );
  }
}
