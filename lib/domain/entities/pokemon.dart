class Pokemon {
  final int apiId;
  final String name;
  final List<String> types;
  final int hp;
  final int attack;
  final int defense;
  final int specialAttack;
  final int specialDefense;
  final int speed;
  final String? portraitUrl;

  const Pokemon({
    required this.apiId,
    required this.name,
    required this.types,
    required this.hp,
    required this.attack,
    required this.defense,
    required this.specialAttack,
    required this.specialDefense,
    required this.speed,
    this.portraitUrl,
  });
}
