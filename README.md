# Mini Pokémon | Field Guide

A Flutter/Dart training project: manage an in-memory Pokémon collection with Create, Read, Update and Delete, native setState, and optional gallery portraits.

## Run on Android
```sh
flutter pub get
flutter analyze
flutter test
flutter run -d emulator-5554
```
Use your actual device ID from flutter devices. This branch requires local verification.

## Source map
- lib/main.dart: root widget and theme.
- lib/models/pokemon.dart: immutable data object.
- lib/screens/pokemon_list_page.dart: collection state and CRUD.
- lib/widgets/pokemon_card.dart: reusable stateless presentation.
- lib/widgets/pokemon_form_dialog.dart: input, validation and image selection.

Study [the Flutter reviewer](learning/FLUTTER_REVIEWER.md).

## Artwork and limitations
Starter PNGs are bundled locally from [PokeAPI/sprites official-artwork](https://github.com/PokeAPI/sprites/tree/master/sprites/pokemon/other/official-artwork): IDs 4 (Charmander), 7 (Squirtle), 1 (Bulbasaur). Pokémon character artwork belongs to its respective rights holders; this is an unofficial educational project, not a claim of artwork ownership or commercial usage rights. No live API requests.

Data resets on restart. Gallery paths may be temporary. Android is the intended target; dart:io image handling is not a web implementation. Stat bars use a reference scale of 150, not a combat mechanic or enforced maximum. No database or battle engine.
