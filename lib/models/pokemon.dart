class Pokemon {
  final int id;
  final String name;
  final String type;
  final int hp;
  final int attack;
  final int defense;
  final String? imagePath;

  const Pokemon({
    required this.id,
    required this.name,
    required this.type,
    required this.hp,
    required this.attack,
    required this.defense,
    this.imagePath,
  });
}
