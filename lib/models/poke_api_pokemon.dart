class PokeApiPokemon {
  final int id;
  final String name;
  final List<String> types;
  final int hp;
  final int attack;
  final int defense;
  final int specialAttack;
  final int specialDefense;
  final int speed;
  final String? imageUrl;
  final String? artworkUrl;

  String? get portraitUrl => artworkUrl ?? imageUrl;

  const PokeApiPokemon({
    required this.id,
    required this.name,
    required this.types,
    required this.hp,
    required this.attack,
    required this.defense,
    required this.specialAttack,
    required this.specialDefense,
    required this.speed,
    this.imageUrl,
    this.artworkUrl,
  });

  factory PokeApiPokemon.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'] as List;

    int getStat(String name) {
      final stat = stats.firstWhere((item) => item['stat']['name'] == name);

      return stat['base_stat'] as int;
    }

    final sprites = json['sprites'] as Map<String, dynamic>;
    final other = sprites['other'] as Map<String, dynamic>?;
    final artwork = other?['official-artwork'] as Map<String, dynamic>?;

    return PokeApiPokemon(
      id: json['id'],
      name: json['name'],
      types: (json['types'] as List)
          .map((item) => item['type']['name'] as String)
          .toList(),
      hp: getStat('hp'),
      attack: getStat('attack'),
      defense: getStat('defense'),
      specialAttack: getStat('special-attack'),
      specialDefense: getStat('special-defense'),
      speed: getStat('speed'),
      imageUrl: sprites['front_default'] as String?,
      artworkUrl: artwork?['front_default'] as String?,
    );
  }
}
