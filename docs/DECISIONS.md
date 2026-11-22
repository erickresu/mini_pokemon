# Decisions

## 2026-11-21: API-only Pokémon source
- **Decision:** PokéAPI is the only source of Pokémon data. Read operations only; the app never writes to the API.
- **Reason:** The manual CRUD and seeded-starter model duplicated Pokémon data and required bundled images.
- **Tradeoff:** Discover and detail need network access. A missing URL or failed request shows a placeholder or error state instead of local data.
- **Revisit when:** Offline support or persistence becomes an explicit requirement.

## 2026-11-21: Clean Architecture + BLoC
- **Decision:** Use standard `domain`, `data`, and `presentation` layers with `flutter_bloc` and `bloc`.
- **Reason:** State belongs in BLoCs, files get one job, and dependencies point inward.
- **Tradeoff:** More files and explicit event/state plumbing than direct `setState`.
- **Rules:** `domain` owns entities, contracts, and use cases. `data` implements contracts. `presentation` imports domain only. `lib/main.dart` is the only place that constructs concrete repositories and use cases.

## 2026-11-21: Empty collection and local-only delete
- **Decision:** The collection starts empty. `CollectPokemon` rejects duplicate API ids. Delete removes only local entries.
- **Reason:** Create and edit forms are removed; collection entries come from API detail results.
- **Tradeoff:** No manual data entry or local editing; every collected entry mirrors a PokéAPI detail result.
- **Revisit when:** Users explicitly need custom entries or local edits.

## 2026-11-21: No bundled art or image picker
- **Decision:** Remove `assets/pokemon`, starter PNGs, `image_picker`, and all file/asset portrait paths.
- **Reason:** Artwork comes from PokéAPI URLs; a missing or failed portrait uses a placeholder.
- **Tradeoff:** No offline portrait rendering and no gallery selection.
- **Guard:** `test/layer_boundaries_test.dart` fails if the old form or asset directory returns.

## 2026-11-21: Verification environment
- **Decision:** Run Flutter/Dart commands through Windows PowerShell.
- **Reason:** WSL launcher fails with `/mnt/c/src/flutter/bin/internal/shared.sh: line 5: $'\r': command not found`.
- **Tradeoff:** Verification commands in records use `powershell.exe -NoProfile -Command ...`.
- **Scope:** Emulator checks were not run on the refactor branch; records must say so.

## Earlier decisions (historical)

### 2026-11-17: Minimal Flutter architecture
- **Decision:** Start with Flutter/Dart, an in-memory list, and built-in `setState` for Pokémon CRUD.
- **Reason:** Beginner-friendly scope and a presentation deadline of 2026-11-19.
- **Tradeoff:** Data reset on restart; persistence was out of initial scope.
- **Status:** Superseded by the 2026-11-21 Clean Architecture decision.

### 2026-11-17: Learning and engineering records
- **Decision:** Keep local instructions in `AGENTS.md`, verified project state in `docs/`, and demonstrated learning in `learning/`.
- **Reason:** Support safe collaboration, progress tracking, and independent explanation.

### 2026-11-18: Field Guide presentation and assets
- **Decision:** Preserve list, dialogs, CRUD and native `setState`; bundle three starter PNGs.
- **Status:** Superseded. Bundled art, CRUD forms, and `setState` collection state were removed in the 2026-11-21 refactor.
