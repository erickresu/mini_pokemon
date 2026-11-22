# API-only Pokémon collection with Clean Architecture and BLoC

Date: 2026-11-21
Status: Draft for approval
Target branch: `refactor/clean-architecture-api-only` (not created yet)
Base: `feature/pokeapi-integration` at `b5bc104`
Size: project-sized refactor, not a small change.

## Intent and why

The project currently mixes three jobs in a few widget classes: screen state, HTTP data access, and navigation. The goal is to learn the structure the senior asked for, Clean Architecture plus BLoC, by applying it to one small app while keeping the code easy to verify.

The app will stop acting like a hand-entered CRUD demo. PokéAPI becomes the only source of Pokémon data. The collection starts empty. A user discovers a Pokémon, opens its detail page, and collects it. The user can remove collected entries locally. There is no manual add form, no manual edit form, and no seeded starter data.

This change is for learning as much as for structure. Files get one job. Dependencies point inward. State lives outside widgets. After each layer, the learner tests the flow and explains the concept back before the next layer starts.

## Goals

- Create an isolated branch without touching `feature/pokeapi-integration`.
- Keep the current working tree intact, including uncommitted work.
- Remove the three seeded Pokémon and their bundled PNG assets.
- Remove `PokemonFormDialog`, the FAB, gallery image picking, and manual create/edit behavior.
- Make Discover, Detail, and Collection use clean layers and BLoC state.
- Keep all data in memory. Collection resets when the app restarts.
- Keep tests runnable after each layer.
- Record exact verification commands and results.
- Update project docs and learning records only when claims are true.

## Non-goals

- No writes to PokéAPI. Its docs state that it is consumption-only and that only GET, HEAD, and OPTIONS requests are allowed.
- No backend, database, local storage, or persistence.
- No battle engine or combat rules.
- No gallery picker or bundled starter portraits.
- No merge into `main` or any remote write without explicit approval.
- No learning status marked as mastered merely because code exists.

## Anti-goals

- A big-bang rewrite of all files before any teaching checkpoint.
- Two competing sources of truth, such as seeded entries plus API entries.
- Widgets that call HTTP services or own business rules.
- Domain code that imports Flutter, `dart:io`, or `http`.

## Constraints

- Current branch: `feature/pokeapi-integration`, HEAD `b5bc104`.
- Working tree contains widespread CRLF-only differences plus one real two-line change in `pokemon_list_page.dart`. Do not run `git clean`, `git reset`, rebase, pull, force push, or overwrite unrelated work.
- The local engineering contract is `AGENTS.md`. It defines the teaching format, engineering workflow, verification expectations, and Git safety rules.
- WSL Flutter launcher previously failed on CRLF in installed SDK scripts. Windows shell may be required for `dart format`, `flutter analyze`, `flutter test`, and `flutter run`.
- Existing tests depend on the three starters and the manual form. They must be rewritten, not merely patched around.
- PokéAPI is read-only. "CRUD" here means API read plus local create and delete. Update is removed.

## Approaches considered

### 1. Full rewrite of all features at once

Move every model, service, screen, and widget into clean layers in one pass. BLoC handles list, discover, and detail together.

Tradeoff: many files change before the learner sees one boundary work. Verification is harder and teaching becomes archaeology. Rejected.

### 2. Discover slice first, keep manual CRUD

Refactor only Discover into domain, data, and presentation. Leave the manual form and seeded entries in place.

Tradeoff: good learning pace, but it keeps two sources of truth and the manual CRUD the learner wants removed. Rejected after the new requirement arrived.

### 3. API-only clean architecture in one isolated branch

Remove manual CRUD and seeded data, then structure the remaining app as domain, data, and presentation. Use BLoC for Collection, Discover, and Detail. Keep the change inside one branch and teach one layer at a time.

Tradeoff: wider than a single flow, but bounded by a small app and an isolated branch. It matches the requested end state and avoids maintaining two styles. Chosen.

## Target structure

```
lib/
  main.dart
  core/
    theme/app_theme.dart
  domain/
    entities/pokemon.dart
    entities/pokemon_summary.dart
    entities/pokemon_page.dart
    repositories/collection_repository.dart
    repositories/pokemon_catalog_repository.dart
    usecases/collect_pokemon.dart
    usecases/remove_pokemon.dart
    usecases/watch_collection.dart
    usecases/fetch_pokemon_page.dart
    usecases/get_pokemon_details.dart
  data/
    datasources/poke_api_service.dart
    models/poke_api_dto.dart
    models/poke_api_page_dto.dart
    repositories/in_memory_collection_repository.dart
    repositories/poke_api_catalog_repository.dart
  presentation/
    blocs/collection_bloc.dart
    blocs/discover_bloc.dart
    blocs/detail_bloc.dart
    pages/pokemon_list_page.dart
    pages/pokemon_discover_page.dart
    pages/pokemon_detail_page.dart
    widgets/pokemon_card.dart
    widgets/pokemon_network_portrait.dart
```

## Layer rules

### domain

Pure Dart. No Flutter, no `http`, no `dart:io`, no `BuildContext`.

`Pokemon` is the full app entity. It holds API id, name, types, six base stats, and portrait URL. `PokemonSummary` is the small entity for a Discover row. `PokemonPage` holds a list of summaries plus `hasMore`. These three replace the current mix of local `Pokemon`, `PokeApiPokemon`, `PokeApiPokemonSummary`, `PokeApiPokemonPage`, `imagePath`, `assetPath`, and `officialData`.

Repository interfaces describe capabilities, not HTTP details:

- `CollectionRepository`: watch all collected Pokémon, add one, remove one by API id.
- `PokemonCatalogRepository`: fetch a `PokemonPage`, fetch a full `Pokemon` by name.

One use case per business action. Each use case depends on one repository interface. Duplicate rejection by API id is a business rule. It lives in the `CollectPokemon` use case, not in the repository. The use case reads the current collection through `CollectionRepository.watchAll()` and refuses to add an existing API id.

### data

Implements the repository interfaces from `domain`.

`PokeApiService` keeps HTTP GET calls and timeouts. It returns raw decoded JSON or DTOs. DTOs map PokéAPI JSON into domain entities. DTOs do not appear in widgets.

`InMemoryCollectionRepository` owns the local list. It stores and removes entries only. It does not apply business rules.

`PokeApiCatalogRepository` maps service results into `PokemonSummary`, `PokemonPage`, and `Pokemon` entities. DTOs convert JSON; the repository converts DTOs to domain entities.

### presentation

Pages, widgets, and BLoCs. Depends on `domain` only.

Pages are stateless. They provide or read BLoCs, render states, and send events. Widgets receive entities and callbacks. No widget calls `PokeApiService` or a repository.

`CollectionBloc` handles `CollectionStarted`, `PokemonCollected`, and `PokemonRemoved`. It emits loading and ready states containing the collected list.

`DiscoverBloc` handles `DiscoverStarted`, `LoadMore`, and `Retry`. It emits loading, ready, and failure states containing the current list, `hasMore`, and error message. Failed loads retry the same offset.

`DetailBloc` handles `DetailStarted` and `Retry`. It emits loading, ready, and failure states for one Pokémon.

`main.dart` creates repositories and injects them into BLoCs. This is the only composition root.

## Flow after the change

1. App starts with an empty collection.
2. User taps Add New Pokemon. Collection pushes Discover.
3. DiscoverBloc fetches the first page through `FetchPokemonPage`.
4. User taps a summary. Discover pushes Detail.
5. DetailBloc fetches details through `GetPokemonDetails`.
6. User taps Collect. Detail sends `PokemonCollected` to CollectionBloc through the catalog repository and pops with the entity.
7. CollectionBloc calls `CollectPokemon`. The use case rejects duplicate API ids.
8. Collection page shows the new entry.
9. User taps Delete. CollectionBloc calls `RemovePokemon`.

Update no longer exists as a user action. Delete affects only the in-memory collection.

## Tests

Replace the current widget tests rather than forcing them to fit.

- `test/domain/collect_pokemon_test.dart`: use case adds once and rejects duplicate API id.
- `test/domain/remove_pokemon_test.dart`: use case removes by API id.
- `test/data/poke_api_dto_test.dart`: JSON maps to `Pokemon`, `PokemonSummary`, and `PokemonPage`, including types, six stats, and portrait URL fallback.
- `test/presentation/collection_bloc_test.dart`: start, collect, duplicate, remove.
- `test/presentation/discover_bloc_test.dart`: first load, pagination, same-offset retry, end of list.
- `test/presentation/detail_bloc_test.dart`: load and retry.
- `test/widget_test.dart`: empty collection state, discover, collect, delete. Use fake repositories, not a fake HTTP service.

Remove tests for manual validation, gallery image paths, and bundled asset removal.

## File and asset removal

- Delete `lib/widgets/pokemon_form_dialog.dart`.
- Delete `assets/pokemon/bulbasaur.png`, `charmander.png`, and `squirtle.png`.
- Remove the assets entry from `pubspec.yaml`.
- Remove `image_picker` from `pubspec.yaml` if nothing else uses it.
- Add `flutter_bloc` and `bloc`.
- Remove `PokeApiPokemon`, `PokeApiPokemonSummary`, and `PokeApiPokemonPage` after their DTO replacements exist.
- Update `tool/test_pokeapi.dart` and `tool/test_pokeapi_list.dart` to use the new service and DTO API. Their current calls to `fetchPokemonList`, `imageUrl`, and `url` will not compile after the refactor. Deleting them is not the default.

## Documentation updates

- `README.md`: new source map, empty start, no manual CRUD, no bundled assets, no persistence.
- `docs/DECISIONS.md`: add the API-only decision and the clean architecture decision, including tradeoffs.
- `docs/HANDOFF_CHECKLIST.md`: update verification items for the new flow.
- `docs/PROJECT_MEMORY.md`: add a checkpoint only after commands actually run.
- `learning/FLUTTER_REVIEWER.md`: rewrite around layers, BLoC events and states, and the new flow.
- `learning/MASTERY_TRACKER.md`: add new topics as New. Upgrade only after demonstrated explanation.

## Teaching loop

Use the format in `AGENTS.md`: Simple explanation, Why it matters, Cause to Process to Result, Example, Your turn.

Order:

1. Domain entity and repository interface.
2. Data DTOs and repository implementations.
3. Use cases.
4. CollectionBloc and stateless Collection page.
5. DiscoverBloc and stateless Discover page.
6. DetailBloc and stateless Detail page.
7. Tests and verification.

After each step, stop. The learner runs or observes the relevant flow and explains it back. Do not advance on "looks right" alone. Each teaching step is a hard gate.

Emulator checks are separate gates. Run one after Collection is runnable, one after Discover is runnable, and one after Detail is runnable, then a final full flow check. Engineering verification and learning verification stay separate.

## Verification

Run and record exact commands and results:

```
dart format lib test
flutter pub get
flutter analyze
flutter test
flutter run -d emulator-5554 --no-resident
```

A successful build or analyzer run does not prove CRUD behavior or learning. Manual emulator checks cover empty start, Discover loading, pagination, Detail, Collect, duplicate rejection, and Delete.

## Git safety

- Create the new branch in a separate Git worktree from current HEAD. This leaves the current worktree and its uncommitted CRLF differences untouched.
- Do not copy the two-line label change into the new branch. Fix the label mismatch inside the new branch as part of the refactor.
- Show the proposed worktree, branch, and file list before any operation outside that worktree.
- Show the proposed branch and file list before any remote operation.
- Do not pull, reset, rebase, clean, force push, or merge without explicit approval.
- Keep commits small and aligned with teaching steps.

## Left to the builder

- Exact package versions after `flutter pub get`.
- Exact file creation and deletion order.
- Exact test names and fake repository shapes.
- Exact commit messages and commit boundaries.
- Whether Windows shell is needed for each Flutter command, decided from actual command output.
