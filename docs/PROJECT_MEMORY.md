# Project Memory

## Current checkpoint: Clean Architecture + API-only refactor

- Worktree: `C:\dev\mini_pokemon_clean_architecture`
- Branch: `refactor/clean-architecture-api-only`, base `b5bc104`
- Original checkout `C:\dev\mini_pokemon` is untouched.
- User decision: keep the branch only; no merge, push, pull, rebase, clean, or remote write.
- User waiver: teaching gates and emulator gates skipped for this pass. Engineering verification still required.
- Source shape: standard `domain`, `data`, `presentation` layers plus `lib/core/theme/`; `lib/main.dart` is the only composition root.
- Behavior: collection starts empty; Discover loads PokéAPI pages; Detail loads one API Pokémon; `Collect` adds locally; Delete removes locally; no persistence and no API writes.
- Dependencies: `flutter_bloc` and `bloc` added; `image_picker`, manual forms, seeded starters, and bundled PNGs removed.

Verified from Windows PowerShell (WSL launcher fails on CRLF scripts):

```powershell
Set-Location 'C:\dev\mini_pokemon_clean_architecture'
dart format lib test
flutter pub get
flutter analyze
flutter test
```

Observed on the final tree:

- `dart format lib test` → `Formatted 37 files (0 changed)`.
- `flutter pub get` → `Got dependencies!`; only routine newer-version notices.
- `flutter analyze` → `No issues found!`.
- `flutter test` → `00:02 +21: All tests passed!`.
- `flutter test test/layer_boundaries_test.dart` → passed earlier in this task.
- Task 9 review found an Important `watchAll()` handoff race; fixed in `e31409d` with a single-subscription controller plus a two-test regression file.

Blockers:

- No emulator output exists for this branch. Runtime checks are not verified; `docs/HANDOFF_CHECKLIST.md` leaves them unchecked.
- Live PokéAPI calls were not exercised on a device; widget tests use fakes and DTO fixtures.

Next safe action: user reviews the branch and decides whether to approve integration. Do not merge or push without explicit approval.

## Earlier checkpoints (historical)

### V2 details and collection artwork

- Branch `feature/pokeapi-integration` at `df72278`. Milestone changes remained unstaged and uncommitted at that checkpoint.
- User reported milestone 1 working on the emulator. Discover opened details with artwork, types, and six base stats; Collect returned to Collection with an in-memory entry.
- Windows `dart format` covered the two models, detail and Discover screens, network portrait widget, and focused test file. `flutter analyze` was clean; nine widget tests passed.
- `flutter run -d emulator-5554 --no-resident` built and launched the debug app. Live artwork rendering and learning verification were not tested in that pass.
- Those files and behaviors were replaced by the 2026-11-21 refactor. Do not use that checkpoint as current state.

### V2 milestone 1: Discovery and pagination

- Local branch `feature/pokeapi-integration` at `df72278`; changes unstaged, CRLF-only differences preserved.
- Discover appended pages on demand, retried the same offset, and stopped when PokéAPI provided no next page.
- Windows `flutter test` passed eight widget tests; `flutter devices` detected `emulator-5554`.
- WSL Flutter launcher failed on CRLF in SDK scripts. Flutter/Dart commands must run through Windows PowerShell.
- That implementation predates Clean Architecture and is superseded.

### Earlier Field Guide checkpoint

- Goal then: learn five Flutter fundamentals through a small Pokémon CRUD project for the November 19 presentation.
- Field Guide redesign followed the 2026-11-18 handoff. CRUD, `setState`, dialogs, and three bundled PNGs were later removed.
- Historical evidence included a screenshot-confirmed gallery preview and user-reported CRUD working.
- No persistence, live API, or battle engine existed at that checkpoint.
