class PokeApiPokemon {
  final int id;
  final String name;
  final List<String> types;
  final int hp;
  final int attack;
  final int defense;
  final String? imageUrl;

  const PokeApiPokemon({
    required this.id,
    required this.name,
    required this.types,
    required this.hp,
    required this.attack,
    required this.defense,
    this.imageUrl,
  });

  factory PokeApiPokemon.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'] as List;

    int getStat(String name) {
      final stat = stats.firstWhere((item) => item['stat']['name'] == name);

      return stat['base_stat'] as int;
    }

    return PokeApiPokemon(
      id: json['id'],
      name: json['name'],
      types: (json['types'] as List)
          .map((item) => item['type']['name'] as String)
          .toList(),
      hp: getStat('hp'),
      attack: getStat('attack'),
      defense: getStat('defense'),
      imageUrl: json['sprites']['front_default'],
    );
  }
}
