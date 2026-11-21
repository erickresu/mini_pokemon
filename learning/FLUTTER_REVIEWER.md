# Flutter reviewer: layers, events, states, and flow

Goal: explain responsibilities and data flow from inspected code, not memorize styling.

## 1. Composition root

**Simple explanation:** `main()` calls `runApp(const MyApp())`; `MyApp` builds `MaterialApp` with `PokemonListPage` as home.
**Why it matters:** One place constructs concrete repositories and use cases.
**Cause -> Process -> Result:** `main()` -> `runApp` -> `MyApp.build` -> `RepositoryProvider` ancestors -> pages and BLoCs.
**Example:** `lib/main.dart` builds `InMemoryCollectionRepository` and `PokeApiCatalogRepository`, then provides use cases to the tree.
**Your turn:** Which file would change to swap the API catalog for a fake?

## 2. Three layers

**Simple explanation:** `domain` owns entities, contracts, and use cases. `data` implements contracts. `presentation` owns pages, widgets, BLoCs, events, and states.
**Why it matters:** Dependencies point inward; a page never imports an HTTP client.
**Cause -> Process -> Result:** page dispatches event -> BLoC calls use case -> use case calls contract -> data implementation returns domain entity.
**Example:** `lib/domain/repositories/`, `lib/data/repositories/`, and `lib/presentation/blocs/` show the split.
**Your turn:** Why can `domain` not import `package:flutter`?

## 3. Repository contracts and use cases

**Simple explanation:** A repository contract says what data operations exist. A use case performs one operation.
**Why it matters:** BLoCs depend on behavior, not on PokéAPI or an in-memory list.
**Cause -> Process -> Result:** `CollectPokemon` reads `watchAll().first`, rejects a duplicate `apiId`, then calls `repository.add(pokemon)`.
**Example:** `lib/domain/usecases/collect_pokemon.dart` owns duplicate rejection; no page contains that rule.
**Your turn:** Where would you move duplicate rejection if the UI had two collect buttons?

## 4. BLoC events and states

**Simple explanation:** Events describe what happened. States describe what the UI should render.
**Why it matters:** Widgets stay stateless and rebuild from one state stream.
**Cause -> Process -> Result:** `DiscoverStarted` -> `DiscoverLoading` -> `DiscoverReady(results, hasMore)`; `DetailStarted(name)` -> `DetailLoading` -> `DetailReady(pokemon)`.
**Example:** `lib/presentation/blocs/discover_bloc.dart`, `detail_bloc.dart`, and `collection_bloc.dart`.
**Your turn:** What state follows a failed paged load, and which rows stay visible?

## 5. Three pages and one flow

**Simple explanation:** Collection is home; Discover lists API pages; Detail loads one API Pokémon.
**Why it matters:** Create means collect from API data, not type into a form.
**Cause -> Process -> Result:** empty Collection -> `Add New Pokemon` -> Discover row tap -> Detail -> `Collect` returns `Pokemon` -> `PokemonCollected` -> Collection shows one row -> `Delete` removes it locally.
**Example:** `lib/presentation/pages/pokemon_list_page.dart`, `pokemon_discover_page.dart`, and `pokemon_detail_page.dart`.
**Your turn:** Name the event that adds the collected Pokémon to the collection.

## 6. Widget tree

**Simple explanation:** Parent-child hierarchy that describes layout and configuration.
**Why it matters:** It explains where state is read and where callbacks go.
**Cause -> Process -> Result:** `MyApp` -> `MaterialApp` -> `PokemonListPage` -> `Scaffold` -> `BlocBuilder<CollectionBloc, CollectionState>` -> `PokemonCard`.
**Example:** `PokemonCard` and `PokemonNetworkPortrait` are stateless and receive data.
**Your turn:** Trace `Collect` from Detail back to `CollectionBloc`.

## 7. Testing architecture boundaries

**Simple explanation:** A boundary test reads source files and forbids forbidden imports or stale files.
**Why it matters:** It stops a layer from silently depending outward or an old form returning.
**Cause -> Process -> Result:** `Directory('lib/domain').listSync(recursive: true)` -> read each `.dart` -> assert no `package:flutter`, `dart:io`, `package:http`, `../data/`, or `../presentation/`.
**Example:** `test/layer_boundaries_test.dart` also rejects `package:http` and `../data/` in presentation and checks that `lib/widgets/pokemon_form_dialog.dart` and `assets/pokemon` do not exist.
**Your turn:** What would the test catch if someone imported `PokeApi` into a presentation widget?

## 8. Verification honesty

**Simple explanation:** `dart format lib test`, `flutter pub get`, `flutter analyze`, and `flutter test` are separate checks.
**Why it matters:** Passing analyzer does not prove tests pass; passing tests do not prove behavior on a device.
**Cause -> Process -> Result:** formatter -> dependency resolution -> static analysis -> 21 automated tests -> optional emulator run.
**Example:** Final refactor output was `No issues found!` and `00:02 +21: All tests passed!`. Emulator checks are still unchecked.
**Your turn:** Which claim requires emulator output before it is truthful?

## Independent practice

Draw the three layers and arrow directions. Trace `Load more` from event to state to widget. Add a boundary assertion for a new forbidden import, then explain why it belongs in that test.

## Presentation honesty

Data is in memory; PokéAPI is read-only. No CRUD forms, seeded starters, bundled art, persistence, or battle engine exists. Assistant-authored code does not prove personal mastery. Final branch runtime tests must be run locally.
