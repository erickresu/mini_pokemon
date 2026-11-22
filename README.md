# Mini Pokémon | Clean Architecture Field Guide

A Flutter/Dart training app that explores PokéAPI and builds a small local collection. The app uses standard Clean Architecture layers with BLoC state management.

## Collection rules

- The collection starts empty.
- Create means **Collect**: open Discover, open a detail page, and press `Collect`.
- Search is autocomplete: one typed character suggests names starting with it; two or more suggest names containing it. The full name list is fetched once from PokéAPI and filtered locally.
- Edit changes name, types, and six stats on a collected entry. `apiId` stays fixed.
- Favorite marks a collected entry. The Favorites tab shows only favorited entries.
- Delete is local only; it never writes to PokéAPI.
- No manual create form, image picker, seeded starters, or bundled Pokémon art.
- Default storage is in memory. `--dart-define=USE_SQLITE=true` switches to a local SQLite database.
- SQLite keeps edits, favorites, and deletes across restarts. Switching modes does not move data between stores.
- No backend and no writes to the API. PokéAPI is the only source for new Pokémon data.

## Run and verify

```sh
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter run -d emulator-5554
flutter run -d emulator-5554 --dart-define=USE_SQLITE=true
```

Use an actual device ID from `flutter devices`. On this machine, use Windows PowerShell for Flutter and Dart commands; the WSL launcher fails on CRLF scripts in the installed Flutter SDK.

## Source map

- `lib/main.dart`: composition root; constructs concrete repositories and use cases, then provides them to the widget tree.
- `lib/core/theme/`: shared `AppTheme.light()`.
- `lib/domain/entities/`: `Pokemon`, `PokemonSummary`, `PokemonPage`.
- `lib/domain/repositories/`: abstract collection and catalog contracts.
- `lib/domain/usecases/`: collection and catalog use cases; duplicate API-id rejection lives in `CollectPokemon`.
- `lib/data/datasources/`: read-only PokéAPI service and SQLite opener.
- `lib/data/models/`: API DTOs and the SQLite row mapper.
- `lib/data/repositories/`: in-memory and SQLite collection repositories, and the PokéAPI catalog repository.
- `lib/presentation/blocs/`: `CollectionBloc`, `DiscoverBloc`, `DetailBloc`.
- `lib/presentation/pages/`: collection, discover, and detail pages.
- `lib/presentation/widgets/`: card, network portrait, and edit form dialog.
- `test/fakes/`: repository fakes used by unit and widget tests.
- `test/layer_boundaries_test.dart`: guard against inward dependency violations.

Dependencies point inward: `presentation` and `data` depend on `domain`; `domain` depends on neither. Presentation never imports `data`, `http`, or an API client directly.

## Verification

`flutter analyze` is clean and `flutter test` passes, including unit tests for use cases and BLoCs, SQLite row mapping and CRUD, write-failure handling, edit/favorite/search widget flows, and a layer-boundary guard. Run the emulator commands above to check live behavior; a passing test suite does not prove on-screen behavior.

Study [the Flutter reviewer](learning/FLUTTER_REVIEWER.md) for the current layers, events, states, and data flow.

## Artwork and limitations

Pokémon artwork is loaded from URLs returned by PokéAPI; a placeholder is shown when the URL is missing or fails. Pokémon character artwork belongs to its respective rights holders. This is an unofficial educational project. Stat bars use a reference scale of 150, not a combat mechanic or enforced maximum. No battle engine exists.
