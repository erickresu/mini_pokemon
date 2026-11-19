class PokeApiPokemonSummary {
  final String name;
  final String url;

  const PokeApiPokemonSummary({required this.name, required this.url});

  factory PokeApiPokemonSummary.fromJson(Map<String, dynamic> json) {
    return PokeApiPokemonSummary(
      name: json['name'] as String,
      url: json['url'] as String,
    );
  }
}
