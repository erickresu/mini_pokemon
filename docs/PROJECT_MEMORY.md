# Project Memory

## V2 details and collection artwork

- Branch `feature/pokeapi-integration` at `df72278`. Milestone changes remain unstaged and uncommitted.
- The user reported milestone 1 working on the emulator. Discover now opens details with artwork, types, and six base stats. Collect returns to Collection and adds an in-memory entry with official artwork.
- Windows `dart format` completed on the two models, detail and Discover screens, network portrait widget, and focused test file. `flutter analyze` found no issues. Final `flutter test` passed all nine widget tests, including a fake-service test of the artwork collection flow. Initial test attempts needed a scroll gesture to bring Collect into view.
- `flutter run -d emulator-5554 --no-resident` built, installed, and launched the debug app. Live artwork rendering, release runtime, and learning verification were not tested in this pass.
- Next safe action: manually open a Pokémon in Discover, Collect it, and confirm its artwork appears in Collection.

## V2 milestone 1: Discovery and pagination

- Local branch: `feature/pokeapi-integration` at `df72278`. Milestone changes are unstaged and uncommitted. Pre-existing CRLF-only working-tree differences were preserved.
- Collection opens the existing Discover screen. Discover appends pages on demand, retries the same offset after failures, and stops when PokéAPI provides no next page.
- Windows SDK: `dart format lib/models/poke_api_pokemon_page.dart lib/screens/pokemon_discover_page.dart lib/services/poke_api_service.dart test/pokemon_discover_page_test.dart` formatted four files. `flutter analyze` reported no issues. `flutter test` passed all eight widget tests. `flutter devices` detected `emulator-5554`.
- WSL Flutter launcher failed on CRLF in the installed SDK scripts. Live API scripts and learning verification were not run for this checkpoint.
- `flutter run -d emulator-5554 --no-resident` built, installed, and launched the Android debug app. Next safe action: user manually checks Discover, Load more, retry, and return to Collection on the emulator.

## Earlier Field Guide checkpoint

Checkpoint: Field Guide redesign, following 2026-11-18 handoff.

## Goal
Learn five Flutter fundamentals through a small Pokémon CRUD project for the November 19 presentation.

## Evidence
- User pushed main at ce0474f; local status showed only untracked "tatus --short". Subsequent local state unknown.
- User reported CRUD working and flutter analyze clean on earlier implementation. Screenshot confirmed gallery photo preview.
- UI-polish base 6e09d9407cee5951c218032a9f0d981852e3b9b4 inspected. Field Guide branch created from that base.
- Field Guide app changes and six widget tests authored; no Dart/Flutter execution in remote editing environment.
- Three official-artwork PNG blobs retrieved from public sprite repository and stored as local assets. Image paths and manifest connected in source.
- Model gained optional assetPath so built-in portraits can be preserved, replaced or removed independently of gallery file paths.
- Original add/edit/delete methods and list state retained.

## Verification boundaries
New branch formatting, analyzer, widget tests, actual Android gallery selection, layout and blur performance remain pending. Earlier checks do not verify this branch. No persistence or live API.

## Next safe action
Inspect local git status and fetch/switch to feat/pokemon-field-guide, then run local analyzer, tests and emulator checks before merging.
