# API-only Pokémon collection with Clean Architecture and BLoC Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace manual CRUD and seeded Pokémon with an API-only, in-memory collection built from Clean Architecture layers and BLoC state.

**Architecture:** `domain` holds pure Dart entities, repository contracts, and use cases. `data` implements those contracts with PokéAPI DTOs, an HTTP service, and in-memory storage. `presentation` holds BLoCs, pages, and widgets; it depends on `domain` only. `main.dart` is the only composition root.

**Tech Stack:** Flutter, Dart 3.14, `flutter_bloc`, `bloc`, `http`, `material_ui`, `flutter_test`.

**Spec:** `docs/superpowers/specs/2026-11-21-clean-architecture-api-only-design.md`

## Global Constraints

- Base: `feature/pokeapi-integration` at `b5bc104`.
- Worktree: `/mnt/c/dev/mini_pokemon_clean_architecture`.
- Branch: `refactor/clean-architecture-api-only`.
- Current worktree has 102 modified paths, mostly CRLF-only, plus a real two-line label change. Do not reset, clean, rebase, pull, force push, merge, or overwrite it.
- Do not copy the two-line label change. The new page uses `Add New Pokemon` from the start.
- Copy only the approved spec and this plan into the new worktree. Do not copy other uncommitted files.
- Add only `flutter_bloc` and `bloc`. Remove `image_picker`. Keep `http`, `material_ui`, and `cupertino_icons`.
- Remove `assets/pokemon/` and its `pubspec.yaml` entry.
- Collection starts empty. Data is in memory only. Collection resets on restart.
- PokéAPI is read-only. No POST, PUT, PATCH, DELETE, DB, backend, or persistence.
- Duplicate rejection by API id lives in `CollectPokemon`, not in a repository.
- `lib/domain` must not import Flutter, `dart:io`, `http`, `data`, or `presentation`.
- `lib/presentation` must not import `data` or `http`.
- Teaching steps are hard gates. Stop for teach-back before the next teaching step.
- Emulator checks are separate gates. Engineering verification does not replace them.
- Verification commands: `dart format lib test`, `flutter pub get`, `flutter analyze`, `flutter test`, `flutter run -d emulator-5554 --no-resident`.
- WSL Flutter launcher previously failed on CRLF in installed SDK scripts. Use Windows shell if a command fails for that reason.
- No remote writes or merge without explicit approval.

## Review Focus

- Missing `other.official-artwork` in PokéAPI JSON must fall back to `sprites.front_default`. Test: `test/data/poke_api_dto_test.dart` in Task 3.
- Same Pokémon collected twice from different detail pages must stay single in collection. Test: `test/domain/collect_pokemon_test.dart` in Task 4 and `test/presentation/collection_bloc_test.dart` in Task 5.
- Failed `Load more` must retry the same offset and must not duplicate rows. Test: `test/presentation/discover_bloc_test.dart` in Task 6.
- App restart must show an empty collection because storage is in memory only. Test: `test/widget_test.dart` in Task 8 and emulator gate in Task 9.
- Layer boundaries must stay one-way; no DTO, service, or HTTP type in widgets or domain. Test: `test/layer_boundaries_test.dart` in Task 10.

---

### Task 1: Isolated worktree, dependencies, and theme

**Files:**
- Create worktree: `/mnt/c/dev/mini_pokemon_clean_architecture`
- Copy: `docs/superpowers/specs/2026-11-21-clean-architecture-api-only-design.md`
- Copy: `docs/superpowers/plans/2026-11-21-clean-architecture-api-only.md`
- Modify: `pubspec.yaml`
- Create: `lib/core/theme/app_theme.dart`

**Interfaces:**
- Consumes: existing `main.dart` theme values at lines 14-39.
- Produces: `AppTheme.light()` returning `ThemeData`; dependencies `flutter_bloc` and `bloc` available.

- [ ] **Step 1: Create the isolated worktree**

```bash
git worktree add -b refactor/clean-architecture-api-only /mnt/c/dev/mini_pokemon_clean_architecture b5bc104
```

Expected: new worktree on `refactor/clean-architecture-api-only`. Original worktree status unchanged.

- [ ] **Step 2: Copy only the approved spec and plan**

Copy the two Markdown files listed in Files into the same relative paths in the new worktree. Do not copy any other uncommitted file.

- [ ] **Step 3: Change dependencies**

In the new worktree, run:

```bash
flutter pub add flutter_bloc bloc
```

Remove `image_picker` from `dependencies`. Remove the `assets:` block containing `- assets/pokemon/`. Leave `http: ^1.6.0`, `material_ui: ^1.1.0`, and `cupertino_icons: ^1.0.8`.

- [ ] **Step 4: Extract theme**

Create `lib/core/theme/app_theme.dart`. Move the existing `ink`, `paper`, `red`, `ColorScheme`, `ThemeData`, `appBarTheme`, `floatingActionButtonTheme`, and `inputDecorationTheme` values from `main.dart` into:

```dart
class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    // Return the existing ThemeData from main.dart lines 14-39.
    throw UnimplementedError();
  }
}
```

Do not change colors or theme values. Do not modify `main.dart` in this task.

- [ ] **Step 5: Verify setup**

Run in the new worktree:

```bash
dart format lib/core/theme/app_theme.dart
flutter pub get
flutter analyze
```

Expected: `flutter analyze` reports no issues caused by this task.

- [ ] **Step 6: Commit**

```bash
git add pubspec.yaml lib/core/theme/app_theme.dart docs/superpowers
git commit -m "chore: create clean architecture worktree and add bloc deps"
```

---

### Task 2: Domain entities and repository contracts

**Files:**
- Create: `lib/domain/entities/pokemon.dart`
- Create: `lib/domain/entities/pokemon_summary.dart`
- Create: `lib/domain/entities/pokemon_page.dart`
- Create: `lib/domain/repositories/collection_repository.dart`
- Create: `lib/domain/repositories/pokemon_catalog_repository.dart`
- Test: `test/domain/entities_test.dart`

**Interfaces:**
- Consumes: nothing outside this task.
- Produces:
  - `Pokemon({required int apiId, required String name, required List<String> types, required int hp, required int attack, required int defense, required int specialAttack, required int specialDefense, required int speed, String? portraitUrl})`
  - `PokemonSummary({required String name, required String url})`
  - `PokemonPage({required List<PokemonSummary> results, required bool hasMore})`
  - `abstract class CollectionRepository { Stream<List<Pokemon>> watchAll(); Future<void> add(Pokemon pokemon); Future<void> remove(int apiId); }`
  - `abstract class PokemonCatalogRepository { Future<PokemonPage> fetchPage({required int offset, int limit = 20}); Future<Pokemon> fetchDetails(String name); }`

- [ ] **Step 1: Write failing entity test**

```dart
test('entities expose the fields the app needs', () {
  const pokemon = Pokemon(
    apiId: 1,
    name: 'bulbasaur',
    types: ['grass', 'poison'],
    hp: 45,
    attack: 49,
    defense: 49,
    specialAttack: 65,
    specialDefense: 65,
    speed: 45,
    portraitUrl: 'https://example.com/artwork.png',
  );

  expect(pokemon.apiId, 1);
  expect(pokemon.types, ['grass', 'poison']);
  expect(pokemon.specialDefense, 65);
  expect(pokemon.portraitUrl, 'https://example.com/artwork.png');

  const row = PokemonSummary(name: 'ivysaur', url: 'https://example.com/2');
  final page = PokemonPage(results: const [row], hasMore: true);
  expect(page.results.single.name, 'ivysaur');
  expect(page.hasMore, isTrue);
});
```

- [ ] **Step 2: Run it to verify failure**

Run: `flutter test test/domain/entities_test.dart`
Expected: FAIL because the entity classes do not exist.

- [ ] **Step 3: Implement entities and contracts**

Create the five production files with exactly the constructor fields and method signatures in Interfaces. No Flutter, `dart:io`, `http`, `data`, or `presentation` imports.

- [ ] **Step 4: Run the test and analyzer**

Run:

```bash
flutter test test/domain/entities_test.dart
flutter analyze
```

Expected: PASS; analyzer clean.

- [ ] **Step 5: Teaching gate**

Present the five-part explanation for **domain layer and dependency direction** using the files just created. Ask the learner to explain why `domain` cannot import `data` or Flutter. Stop until the learner explains it back.

- [ ] **Step 6: Commit**

```bash
git add lib/domain test/domain
git commit -m "feat(domain): add entities and repository contracts"
```

---

### Task 3: Data DTOs, API service, and repository implementations

**Files:**
- Create: `lib/data/models/poke_api_dto.dart`
- Create: `lib/data/models/poke_api_page_dto.dart`
- Create: `lib/data/datasources/poke_api_service.dart`
- Create: `lib/data/repositories/in_memory_collection_repository.dart`
- Create: `lib/data/repositories/poke_api_catalog_repository.dart`
- Modify: `tool/test_pokeapi.dart`
- Modify: `tool/test_pokeapi_list.dart`
- Test: `test/data/poke_api_dto_test.dart`

**Interfaces:**
- Consumes: Task 2 entities and repository contracts.
- Produces:
  - `PokeApiPokemonDto.fromJson(Map<String, dynamic> json)`
  - `PokeApiPokemonDto.toEntity() -> Pokemon`
  - `PokeApiPokemonDto.portraitUrl -> String?` with `artworkUrl ?? imageUrl`
  - `PokeApiPokemonSummaryDto.fromJson(Map<String, dynamic> json)`
  - `PokeApiPokemonSummaryDto.toEntity() -> PokemonSummary`
  - `PokeApiPageDto.fromJson(Map<String, dynamic> json)`
  - `PokeApiPageDto.toEntity() -> PokemonPage`
  - `PokeApiService.fetchPokemon(String name) -> Future<PokeApiPokemonDto>`
  - `PokeApiService.fetchPage({int limit = 20, int offset = 0}) -> Future<PokeApiPageDto>`
  - `InMemoryCollectionRepository implements CollectionRepository`, plus `void dispose()`
  - `PokeApiCatalogRepository(PokeApiService service) implements PokemonCatalogRepository`

- [ ] **Step 1: Write failing DTO test**

Use a JSON map with `id: 1`, `name: 'bulbasaur'`, `types` containing `grass` and `poison`, six `stats` entries named `hp`, `attack`, `defense`, `special-attack`, `special-defense`, `speed`, `sprites.front_default`, and no `sprites.other.official-artwork.front_default`.

```dart
test('maps detail JSON and falls back to sprite portrait', () {
  final dto = PokeApiPokemonDto.fromJson({
    'id': 1,
    'name': 'bulbasaur',
    'types': [
      {'type': {'name': 'grass'}},
      {'type': {'name': 'poison'}},
    ],
    'stats': [
      {'stat': {'name': 'hp'}, 'base_stat': 45},
      {'stat': {'name': 'attack'}, 'base_stat': 49},
      {'stat': {'name': 'defense'}, 'base_stat': 49},
      {'stat': {'name': 'special-attack'}, 'base_stat': 65},
      {'stat': {'name': 'special-defense'}, 'base_stat': 65},
      {'stat': {'name': 'speed'}, 'base_stat': 45},
    ],
    'sprites': {'front_default': 'https://example.com/sprite.png'},
  });

  final pokemon = dto.toEntity();
  expect(pokemon.apiId, 1);
  expect(pokemon.types, ['grass', 'poison']);
  expect(pokemon.specialDefense, 65);
  expect(pokemon.portraitUrl, 'https://example.com/sprite.png');
});

test('maps page JSON and hasMore from next', () {
  final dto = PokeApiPageDto.fromJson({
    'next': 'https://pokeapi.co/api/v2/pokemon?offset=20&limit=20',
    'results': [
      {'name': 'bulbasaur', 'url': 'https://pokeapi.co/api/v2/pokemon/1/'},
    ],
  });

  final page = dto.toEntity();
  expect(page.results.single.name, 'bulbasaur');
  expect(page.results.single.url, 'https://pokeapi.co/api/v2/pokemon/1/');
  expect(page.hasMore, isTrue);
});
```

- [ ] **Step 2: Run it to verify failure**

Run: `flutter test test/data/poke_api_dto_test.dart`
Expected: FAIL because DTO classes do not exist.

- [ ] **Step 3: Implement DTOs**

Create the DTO classes. Keep `http` and Flutter out of DTO files. `PokeApiPageDto.fromJson` must return `hasMore: json['next'] != null`.

- [ ] **Step 4: Implement service and repositories**

`PokeApiService` keeps GET only and a 15-second timeout. Use error text `Failed to fetch Pokemon: ${response.statusCode}` for detail and `Failed to fetch Pokemon list: ${response.statusCode}` for pages.

`InMemoryCollectionRepository` uses a private `List<Pokemon>` and a broadcast `StreamController<List<Pokemon>>`. `watchAll()` returns `Stream.value(List.unmodifiable(_items)).followedBy(_controller.stream)`. `add` and `remove` mutate the list, then emit `List.unmodifiable(_items)`. `remove` uses API id. No dedupe here.

`PokeApiCatalogRepository` converts DTOs to entities. It holds no Flutter or widget state.

- [ ] **Step 5: Update tool scripts**

`tool/test_pokeapi.dart`: call `PokeApiService.fetchPokemon('charmander')` and print `apiId`, `name`, `types`, six stats, and `portraitUrl`.

`tool/test_pokeapi_list.dart`: call `fetchPage(limit: 10, offset: 0)` and print each result's `name` and `url`. Do not call removed methods.

- [ ] **Step 6: Verify data layer**

Run:

```bash
flutter test test/data/poke_api_dto_test.dart
flutter analyze
```

Expected: PASS; analyzer clean.

- [ ] **Step 7: Teaching gate**

Present the five-part explanation for **DTOs vs entities and repository implementations** using `PokeApiPokemonDto` and `PokeApiCatalogRepository`. Ask the learner to explain why DTOs never reach widgets. Stop until explained back.

- [ ] **Step 8: Commit**

```bash
git add lib/data tool test/data
git commit -m "feat(data): add pokeapi DTOs and repositories"
```

---

### Task 4: Use cases and fake repositories

**Files:**
- Create: `lib/domain/usecases/watch_collection.dart`
- Create: `lib/domain/usecases/collect_pokemon.dart`
- Create: `lib/domain/usecases/remove_pokemon.dart`
- Create: `lib/domain/usecases/fetch_pokemon_page.dart`
- Create: `lib/domain/usecases/get_pokemon_details.dart`
- Create: `test/fakes/fake_collection_repository.dart`
- Create: `test/fakes/fake_catalog_repository.dart`
- Test: `test/domain/collect_pokemon_test.dart`
- Test: `test/domain/remove_pokemon_test.dart`

**Interfaces:**
- Consumes: Task 2 repository contracts; Task 3 entity shapes.
- Produces:
  - `WatchCollection(CollectionRepository repository)` with `Stream<List<Pokemon>> call()`
  - `CollectPokemon(CollectionRepository repository)` with `Future<bool> call(Pokemon pokemon)`; returns `false` on duplicate, `true` after add
  - `RemovePokemon(CollectionRepository repository)` with `Future<void> call(int apiId)`
  - `FetchPokemonPage(PokemonCatalogRepository repository)` with `Future<PokemonPage> call({required int offset, int limit = 20})`
  - `GetPokemonDetails(PokemonCatalogRepository repository)` with `Future<Pokemon> call(String name)`
  - `FakeCollectionRepository implements CollectionRepository`
  - Top-level `Pokemon testPokemon({int apiId = 1})` in `test/fakes/fake_collection_repository.dart`
  - `FakeCatalogRepository({bool failFirst = false, bool failNext = false, bool failDetails = false}) implements PokemonCatalogRepository` with `offsets`, `names`, `failFirst`, `failNext`, `failDetails`

- [ ] **Step 1: Write failing use-case tests**

```dart
test('collect adds once and rejects duplicate API id', () async {
  final repo = FakeCollectionRepository();
  final collect = CollectPokemon(repo);
  final pokemon = testPokemon();

  expect(await collect(pokemon), isTrue);
  expect(await collect(pokemon), isFalse);
  expect((await repo.watchAll().first).length, 1);
});

test('remove deletes by API id', () async {
  final repo = FakeCollectionRepository();
  final collect = CollectPokemon(repo);
  final remove = RemovePokemon(repo);

  await collect(testPokemon());
  await remove(1);
  expect(await repo.watchAll().first, isEmpty);
});
```

- [ ] **Step 2: Run them to verify failure**

Run: `flutter test test/domain/collect_pokemon_test.dart test/domain/remove_pokemon_test.dart`
Expected: FAIL because use cases and fakes do not exist.

- [ ] **Step 3: Implement fakes**

`FakeCollectionRepository` mirrors `InMemoryCollectionRepository` behavior: `watchAll()` returns current list followed by a broadcast controller; `add` and `remove` emit a new unmodifiable list. Add top-level `testPokemon({int apiId = 1})` in the same file with the fixed field values used in Task 2.

`FakeCatalogRepository` records every `offset` in `offsets` and every detail `name` in `names`. It returns one summary per page. `failFirst` throws once at offset 0. `failNext` throws once at offset 1. `failDetails` throws once. It returns `testPokemon()` for details.

- [ ] **Step 4: Implement use cases**

`CollectPokemon` reads `await _repository.watchAll().first`, checks `apiId`, calls `add`, and returns the bool. No other class performs duplicate rejection.

- [ ] **Step 5: Verify use cases**

Run:

```bash
flutter test test/domain
flutter analyze
```

Expected: PASS; analyzer clean.

- [ ] **Step 6: Teaching gate**

Present the five-part explanation for **use cases as one business action**. Use `CollectPokemon` to show why duplicate rejection belongs there, not in the repository. Stop until the learner explains it back.

- [ ] **Step 7: Commit**

```bash
git add lib/domain/usecases test/fakes test/domain
git commit -m "feat(domain): add collection and catalog use cases"
```

---

### Task 5: CollectionBloc

**Files:**
- Create: `lib/presentation/blocs/collection_bloc.dart`
- Test: `test/presentation/collection_bloc_test.dart`

**Interfaces:**
- Consumes: `WatchCollection`, `CollectPokemon`, `RemovePokemon`, `Pokemon`.
- Produces:
  - Events: `CollectionStarted`, `PokemonCollected(Pokemon pokemon)`, `PokemonRemoved(int apiId)`
  - States: `CollectionInitial`, `CollectionLoading`, `CollectionReady({required List<Pokemon> pokemons, String? notice})`
  - `CollectionBloc({required WatchCollection watch, required CollectPokemon collect, required RemovePokemon remove})`

- [ ] **Step 1: Write failing bloc test**

Use `bloc.stream.firstWhere(...)` with a one-second `timeout` for each expected state. Do not add a `bloc_test` dependency.

```dart
test('starts, collects, rejects duplicates, and removes', () async {
  final repo = FakeCollectionRepository();
  final pokemon = testPokemon();
  final bloc = CollectionBloc(
    watch: WatchCollection(repo),
    collect: CollectPokemon(repo),
    remove: RemovePokemon(repo),
  );
  final readyEmpty = bloc.stream.firstWhere((s) => s is CollectionReady && s.pokemons.isEmpty);
  bloc.add(CollectionStarted());
  await readyEmpty.timeout(const Duration(seconds: 1));

  final readyOne = bloc.stream.firstWhere((s) => s is CollectionReady && s.pokemons.length == 1);
  bloc.add(PokemonCollected(pokemon));
  await readyOne.timeout(const Duration(seconds: 1));

  final readyDuplicate = bloc.stream.firstWhere(
    (s) => s is CollectionReady && s.notice == 'Already in your collection.',
  );
  bloc.add(PokemonCollected(pokemon));
  final duplicate = await readyDuplicate.timeout(const Duration(seconds: 1)) as CollectionReady;
  expect(duplicate.pokemons, hasLength(1));

  final readyRemoved = bloc.stream.firstWhere((s) => s is CollectionReady && s.pokemons.isEmpty);
  bloc.add(PokemonRemoved(1));
  await readyRemoved.timeout(const Duration(seconds: 1));
  await bloc.close();
});
```

- [ ] **Step 2: Run it to verify failure**

Run: `flutter test test/presentation/collection_bloc_test.dart`
Expected: FAIL because `CollectionBloc` does not exist.

- [ ] **Step 3: Implement CollectionBloc**

Use `on<CollectionStarted>` to emit `CollectionLoading`, cancel any prior subscription, then subscribe to `watch()` and emit `CollectionReady(list)` on each list event. Keep the latest list in a private field. On `PokemonCollected`, call `collect`; emit ready with `Added to your collection.` or `Already in your collection.` and the current list. On `PokemonRemoved`, call `remove` with `apiId`; clear `notice`. Cancel the subscription in `close()` before `super.close()`.

- [ ] **Step 4: Verify bloc**

Run:

```bash
flutter test test/presentation/collection_bloc_test.dart
flutter analyze
```

Expected: PASS; analyzer clean.

- [ ] **Step 5: Teaching gate**

Present the five-part explanation for **BLoC events and states** using `CollectionBloc`. Ask the learner to explain why widgets send events instead of mutating the list. Stop until explained back.

- [ ] **Step 6: Commit**

```bash
git add lib/presentation/blocs test/presentation
git commit -m "feat(presentation): add CollectionBloc"
```

---

### Task 6: DiscoverBloc

**Files:**
- Create: `lib/presentation/blocs/discover_bloc.dart`
- Test: `test/presentation/discover_bloc_test.dart`

**Interfaces:**
- Consumes: `FetchPokemonPage`, `PokemonSummary`, `PokemonPage`.
- Produces:
  - Events: `DiscoverStarted`, `LoadMore`, `Retry`
  - States: `DiscoverInitial`, `DiscoverLoading`, `DiscoverReady({required List<PokemonSummary> results, required bool hasMore, bool isLoadingMore = false, String? errorMessage})`, `DiscoverFailure(String message)`
  - `DiscoverBloc({required FetchPokemonPage fetchPage})`

- [ ] **Step 1: Write failing bloc tests**

Cover four behaviors with `bloc.stream.firstWhere(...)` and one-second timeouts:

1. `DiscoverStarted` emits `DiscoverReady` with one row and `hasMore: true`.
2. `LoadMore` appends a second row and records offsets `[0, 1]`.
3. Initial failure emits `DiscoverFailure`; `Retry` records offsets `[0, 0]`.
4. Failure on offset 1 emits `DiscoverReady(errorMessage: 'Unable to load Pokemon.')`; `Retry` records `[0, 1, 1]`; success with `hasMore: false` leaves no more rows.

Use `FakeCatalogRepository` from Task 4.

- [ ] **Step 2: Run it to verify failure**

Run: `flutter test test/presentation/discover_bloc_test.dart`
Expected: FAIL because `DiscoverBloc` does not exist.

- [ ] **Step 3: Implement DiscoverBloc**

`DiscoverStarted` emits `DiscoverLoading`, then calls `fetchPage(offset: 0)`. `LoadMore` and `Retry` share one handler. Ignore requests when current ready state has `isLoadingMore` true or `hasMore` false. Compute offset from `state.results.length`. On success, append results and set `hasMore` from the page. On failure with empty results, emit `DiscoverFailure('Unable to load Pokemon.')`; otherwise emit `DiscoverReady` with `errorMessage: 'Unable to load Pokemon.'` and `isLoadingMore: false`.

- [ ] **Step 4: Verify bloc**

Run:

```bash
flutter test test/presentation/discover_bloc_test.dart
flutter analyze
```

Expected: PASS; analyzer clean.

- [ ] **Step 5: Teaching gate**

Present the five-part explanation for **pagination state and same-offset retry**. Ask the learner to explain why offset comes from `results.length`, not a widget counter. Stop until explained back.

- [ ] **Step 6: Commit**

```bash
git add lib/presentation/blocs/discover_bloc.dart test/presentation/discover_bloc_test.dart
git commit -m "feat(presentation): add DiscoverBloc"
```

---

### Task 7: DetailBloc

**Files:**
- Create: `lib/presentation/blocs/detail_bloc.dart`
- Test: `test/presentation/detail_bloc_test.dart`

**Interfaces:**
- Consumes: `GetPokemonDetails`, `Pokemon`.
- Produces:
  - Events: `DetailStarted(String name)`, `Retry`
  - States: `DetailInitial`, `DetailLoading`, `DetailReady(Pokemon pokemon)`, `DetailFailure(String message)`
  - `DetailBloc({required GetPokemonDetails getDetails})`

- [ ] **Step 1: Write failing bloc test**

Use `FakeCatalogRepository` with `failDetails: true` for one call. Assert:

```dart
test('loads detail and retries the same name', () async {
  final catalog = FakeCatalogRepository(failDetails: true);
  final bloc = DetailBloc(getDetails: GetPokemonDetails(catalog));

  final failure = bloc.stream.firstWhere((s) => s is DetailFailure);
  bloc.add(const DetailStarted('bulbasaur'));
  await failure.timeout(const Duration(seconds: 1));

  final ready = bloc.stream.firstWhere((s) => s is DetailReady);
  bloc.add(Retry());
  final state = await ready.timeout(const Duration(seconds: 1)) as DetailReady;

  expect(state.pokemon.apiId, 1);
  expect(catalog.names, ['bulbasaur', 'bulbasaur']);
  await bloc.close();
});
```

- [ ] **Step 2: Run it to verify failure**

Run: `flutter test test/presentation/detail_bloc_test.dart`
Expected: FAIL because `DetailBloc` does not exist.

- [ ] **Step 3: Implement DetailBloc**

Store the name from `DetailStarted` in a private field. `Retry` calls the same loader with that stored name. Emit `DetailLoading`, then `DetailReady`, or `DetailFailure('Unable to load Pokémon details.')` on error.

- [ ] **Step 4: Verify bloc**

Run:

```bash
flutter test test/presentation/detail_bloc_test.dart
flutter analyze
```

Expected: PASS; analyzer clean.

- [ ] **Step 5: Teaching gate**

Present the five-part explanation for **retry with stored event data**. Ask the learner to explain why `Retry` carries no name. Stop until explained back.

- [ ] **Step 6: Commit**

```bash
git add lib/presentation/blocs/detail_bloc.dart test/presentation/detail_bloc_test.dart
git commit -m "feat(presentation): add DetailBloc"
```

---

### Task 8: Empty collection page and composition root

**Files:**
- Create: `lib/presentation/pages/pokemon_list_page.dart`
- Create: `lib/presentation/pages/pokemon_discover_page.dart` as a temporary placeholder
- Create: `lib/presentation/widgets/pokemon_card.dart`
- Create: `lib/presentation/widgets/pokemon_network_portrait.dart`
- Modify: `lib/main.dart`
- Delete: `lib/models/`, `lib/services/`, `lib/screens/`, `lib/widgets/pokemon_form_dialog.dart`
- Delete: `assets/pokemon/bulbasaur.png`, `charmander.png`, `squirtle.png`
- Rewrite: `test/widget_test.dart`
- Delete: `test/pokemon_discover_page_test.dart`

**Interfaces:**
- Consumes: `AppTheme.light()`, `CollectionBloc`, `CollectionReady`, `CollectionStarted`, `Pokemon`, `CollectionRepository`, `PokemonCatalogRepository`.
- Produces:
  - `MyApp({super.key, required CollectionRepository collectionRepository, required PokemonCatalogRepository catalogRepository})`
  - `PokemonListPage` stateless page reading `CollectionBloc` from context
  - `PokemonCard({required Pokemon pokemon, required VoidCallback onDelete})` with no `onEdit`
  - Temporary `PokemonDiscoverPage` with AppBar `Discover Pokemon` and body text `Discover flow next.`

- [ ] **Step 1: Write failing widget test**

```dart
testWidgets('starts with an empty collection and no manual form', (tester) async {
  await tester.pumpWidget(MyApp(
    collectionRepository: FakeCollectionRepository(),
    catalogRepository: FakeCatalogRepository(),
  ));
  await tester.pumpAndSettle();

  expect(find.text('0 Pokemon'), findsOneWidget);
  expect(find.text('No Pokemon yet. Add your first one!'), findsOneWidget);
  expect(find.byType(FloatingActionButton), findsNothing);
  expect(find.text('Add Pokemon'), findsNothing);
  expect(find.text('Edit'), findsNothing);
});
```

Add a second widget test that creates a fake repo, calls `await repo.add(testPokemon())` before pumping `MyApp`, taps `Delete`, confirms, and expects `0 Pokemon`.

- [ ] **Step 2: Run it to verify failure**

Run: `flutter test test/widget_test.dart`
Expected: FAIL because `MyApp` does not accept repositories and the new page does not exist.

- [ ] **Step 3: Build presentation widgets and collection page**

Move `PokemonNetworkPortrait` logic unchanged. Rewrite `PokemonCard` to take domain `Pokemon`, show `pokemon.apiId` as `ENTRY / 001`, show `pokemon.name.toUpperCase()`, show `types.join(' / ').toUpperCase()`, keep the three visible stats, and keep only `Delete`. No `dart:io`, no image picker, no asset path, no edit button.

`PokemonListPage` is a `StatelessWidget`. It uses `BlocBuilder<CollectionBloc, CollectionState>` for list and count, and `BlocListener` to show `notice` in a `SnackBar`. AppBar action remains `TextButton` labeled `Add New Pokemon`. Tapping it pushes the temporary `PokemonDiscoverPage`. No FAB.

- [ ] **Step 4: Wire composition root**

`main()` creates `PokeApiService`, `PokeApiCatalogRepository`, and `InMemoryCollectionRepository`. `MyApp` wraps `MaterialApp` in `RepositoryProvider<PokemonCatalogRepository>` and `BlocProvider<CollectionBloc>`. The bloc is created with the three use cases and immediately receives `CollectionStarted`. Use `AppTheme.light()`.

- [ ] **Step 5: Remove old implementation and tests**

Delete all old files listed in Files. Remove leftover imports of `package:mini_pokemon/models`, `services`, or `screens`. Keep only new paths.

- [ ] **Step 6: Verify collection slice**

Run:

```bash
dart format lib test
flutter analyze
flutter test test/widget_test.dart
```

Expected: PASS; analyzer clean.

- [ ] **Step 7: Teaching gate**

Present the five-part explanation for **stateless pages and the composition root**. Ask the learner to explain why `main.dart` is the only place that knows concrete repositories. Stop until explained back.

- [ ] **Step 8: Emulator gate 1**

Run: `flutter run -d emulator-5554 --no-resident`
Check: collection is empty on launch; no FAB; no edit form; `Add New Pokemon` opens the placeholder. Delete works only if a row is injected by test code, not yet through UI. Record observed result.

- [ ] **Step 9: Commit**

```bash
git add -A
git commit -m "feat(presentation): wire empty collection page"
```

---

### Task 9: Discover and detail flow

**Files:**
- Modify: `lib/presentation/pages/pokemon_discover_page.dart` (replace placeholder)
- Create: `lib/presentation/pages/pokemon_detail_page.dart`
- Modify: `test/widget_test.dart`

**Interfaces:**
- Consumes: `DiscoverBloc`, `DetailBloc`, `CollectionBloc`, `PokemonCatalogRepository`, `PokemonSummary`, `Pokemon`.
- Produces:
  - `PokemonDiscoverPage` stateless page that creates `DiscoverBloc` from `context.read<PokemonCatalogRepository>()`
  - `PokemonDetailPage({required String name})` stateless page that creates `DetailBloc` from `context.read<PokemonCatalogRepository>()`
  - Detail `Collect` button pops `Pokemon`; Discover adds `PokemonCollected(pokemon)` to `CollectionBloc`

- [ ] **Step 1: Write failing integration widget test**

Using `FakeCollectionRepository` and `FakeCatalogRepository`, assert the full flow:

```dart
testWidgets('discovers, collects, and deletes from collection', (tester) async {
  await tester.pumpWidget(MyApp(
    collectionRepository: FakeCollectionRepository(),
    catalogRepository: FakeCatalogRepository(),
  ));
  await tester.pumpAndSettle();

  await tester.tap(find.text('Add New Pokemon'));
  await tester.pumpAndSettle();
  expect(find.text('BULBASAUR'), findsOneWidget);
  expect(find.text('Load more'), findsOneWidget);

  await tester.tap(find.text('BULBASAUR'));
  await tester.pumpAndSettle();
  expect(find.text('Special Attack'), findsOneWidget);
  expect(find.text('GRASS / POISON'), findsOneWidget);

  await tester.tap(find.text('Collect'));
  await tester.pumpAndSettle();
  expect(find.text('1 Pokemon'), findsOneWidget);

  await tester.tap(find.text('Delete'));
  await tester.pumpAndSettle();
  await tester.tap(find.descendant(of: find.byType(AlertDialog), matching: find.text('Delete')));
  await tester.pumpAndSettle();
  expect(find.text('0 Pokemon'), findsOneWidget);
});
```

- [ ] **Step 2: Run it to verify failure**

Run: `flutter test test/widget_test.dart`
Expected: FAIL because placeholder Discover has no rows and Detail page does not exist.

- [ ] **Step 3: Implement Discover page**

`PokemonDiscoverPage` is stateless. `BlocProvider(create: ...)` creates `DiscoverBloc(fetchPage: FetchPokemonPage(context.read<PokemonCatalogRepository>()))` and adds `DiscoverStarted`. Render `DiscoverLoading`, `DiscoverFailure`, and `DiscoverReady` with a `ListView.builder`. Show `Load more` only when `hasMore` is true and not loading more. Show `Retry` after a failed paged load. A row tap pushes `PokemonDetailPage(name: summary.name)`.

- [ ] **Step 4: Implement Detail page**

`PokemonDetailPage` is stateless. `BlocProvider(create: ...)` creates `DetailBloc(getDetails: GetPokemonDetails(context.read<PokemonCatalogRepository>()))` and adds `DetailStarted(name)`. Render loading, failure with `Retry`, and ready with six base stats and `PokemonNetworkPortrait(url: pokemon.portraitUrl)`. `Collect` pops the `Pokemon` entity.

In Discover, after the pushed route returns a `Pokemon`, check `context.mounted`, then add `PokemonCollected(pokemon)` to the inherited `CollectionBloc`.

- [ ] **Step 5: Verify full widget flow**

Run:

```bash
dart format lib test
flutter analyze
flutter test
```

Expected: all tests PASS; analyzer clean.

- [ ] **Step 6: Teaching gate for Discover**

Present the five-part explanation for **BLoC-driven list rendering** using `DiscoverBloc` and `DiscoverReady`. Ask the learner to explain why the page has no `_pokemons` list. Stop until explained back.

- [ ] **Step 7: Teaching gate for Detail**

Present the five-part explanation for **navigation result as an event**. Ask the learner to explain why detail pops an entity and Discover sends `PokemonCollected`. Stop until explained back.

- [ ] **Step 8: Emulator gates 2, 3, and 4**

Run once: `flutter run -d emulator-5554 --no-resident`. Then check and record three separate results:

- Discover: first page loads; `Load more` appends; failure retries same offset.
- Detail: detail loads; `Retry` works; `Collect` returns to collection.
- Full flow: empty start, Discover, Detail, Collect, duplicate rejection, Delete.

- [ ] **Step 9: Commit**

```bash
git add -A
git commit -m "feat(presentation): wire discover and detail flow"
```

---

### Task 10: Boundary test, docs, and final verification

**Files:**
- Create: `test/layer_boundaries_test.dart`
- Modify: `README.md`
- Modify: `AGENTS.md`
- Modify: `docs/DECISIONS.md`
- Modify: `docs/HANDOFF_CHECKLIST.md`
- Modify: `docs/PROJECT_MEMORY.md`
- Modify: `learning/FLUTTER_REVIEWER.md`
- Modify: `learning/MASTERY_TRACKER.md`

**Interfaces:**
- Consumes: final source tree from Tasks 1-9 and recorded verification output.
- Produces: source boundary guard and truthful project records.

- [ ] **Step 1: Write boundary test first**

`test/layer_boundaries_test.dart` reads Dart files under `lib/domain` and `lib/presentation` using `Directory(...).listSync(recursive: true)`. Assert:

- No file under `lib/domain` contains `package:flutter`, `dart:io`, `package:http`, `../data/`, or `../presentation/`.
- No file under `lib/presentation` contains `../data/` or `package:http`.
- No file under `lib/presentation/widgets` contains `PokeApi`.
- `lib/widgets/pokemon_form_dialog.dart` and `assets/pokemon` do not exist.

- [ ] **Step 2: Run it to verify it passes against current tree**

Run: `flutter test test/layer_boundaries_test.dart`
Expected: PASS. If FAIL, fix the violating import or stale file before writing docs.

- [ ] **Step 3: Update docs truthfully**

`README.md`: new folder map, empty start, no manual CRUD, no bundled assets, no persistence, API-only source.

`AGENTS.md`: update scope and verification so it no longer says the app is `setState` CRUD with no API. Keep teaching format and Git safety rules.

`docs/DECISIONS.md`: add API-only decision and Clean Architecture + BLoC decision, with tradeoffs.

`docs/HANDOFF_CHECKLIST.md`: replace CRUD checklist with new flow checks and exact commands.

`docs/PROJECT_MEMORY.md`: add checkpoint with branch, worktree, verified commands, observed results, blockers, and next safe action. Mark emulator checks not run if no device output exists.

`learning/FLUTTER_REVIEWER.md`: rewrite around layers, events, states, and the new flow.

`learning/MASTERY_TRACKER.md`: add new architecture and BLoC topics as `New`. Do not upgrade status without teach-back evidence.

- [ ] **Step 4: Final engineering verification**

Run and record exact output:

```bash
dart format lib test
flutter pub get
flutter analyze
flutter test
```

Expected: formatter makes no meaningful changes; `flutter analyze` clean; `flutter test` PASS.

- [ ] **Step 5: Teaching gate 7**

Present the five-part explanation for **testing architecture boundaries**. Ask the learner to explain what the boundary test prevents. Stop until explained back.

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "docs: record clean architecture refactor and verify"
```

- [ ] **Step 7: No merge or remote write**

Stop at the branch. Show `git status --short` and `git log --oneline -7`. Do not merge, push, pull, rebase, or clean without explicit approval.
