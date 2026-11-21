# Mini Pokémon: Local Engineering Contract

## Goal and scope
Build a beginner-appropriate Flutter/Dart Pokémon app using standard Clean Architecture layers — `domain`, `data`, and `presentation` — with `flutter_bloc` for state management. PokéAPI is the only Pokémon data source. The collection starts empty; collecting from a detail page creates a local entry, and delete removes only that local entry. Do not add manual CRUD forms, seeded starters, bundled art, persistence, a backend, or writes to PokéAPI.

## Instruction hierarchy
Follow the published `main` branch of https://github.com/nickos8/portable-ai-instructions, version 2.0.0, including `MASTER_INSTRUCTIONS.md` and modules: `TEACHING_AND_REVIEW.md`, `ADHD_STUDY_PLANNING.md`, `CODING_AND_PROJECT_WORK.md`, `PROJECT_ENGINEERING.md`, `AI_COLLABORATION.md`, and `LEARNING_DOCUMENTATION.md`. If offline, follow this local contract and disclose missing instruction access. Higher-priority platform and safety requirements take precedence.

## Teaching
Teach one new concept at a time with exactly: **Simple explanation**, **Why it matters**, **Cause -> Process -> Result**, **Example**, **Your turn**. Use actual inspected code, otherwise label examples generic. Diagnose teach-back, repair misconceptions, retest, and confirm before advancing. Keep engineering verification separate from learning verification. Learning statuses: New, Practicing, Can Explain, Can Apply.

## Engineering workflow
Inspect -> Plan -> Explain -> Implement -> Test -> Verify -> Document -> Checkpoint. Before editing, read this file, `docs/PROJECT_MEMORY.md`, `docs/DECISIONS.md`, `docs/HANDOFF_CHECKLIST.md`, and relevant source/tests. Inspect actual Git status, branch, and diffs. Preserve unrelated work. Prefer small changes and Flutter-native organization.

Dependencies point inward. `domain` owns entities, repository contracts, and use cases. `data` implements contracts and talks to PokéAPI. `presentation` owns pages, widgets, events, states, and BLoCs. `lib/main.dart` is the only composition root that constructs concrete repositories.

## Verification
Use relevant checks such as `dart format lib test`, `flutter pub get`, `flutter analyze`, `flutter test`, and `flutter run -d emulator-5554`. On this machine, use Windows PowerShell for Flutter/Dart commands; the WSL launcher fails on CRLF scripts. Record exact commands and observed results; mark checks not run. A successful build or passing analyzer does not prove user mastery. `test/layer_boundaries_test.dart` must stay green.

## Git and collaboration safety
Never assume remote state equals the local working tree. Do not automatically pull, reset, rebase, clean, force-push, merge, or overwrite concurrent changes. Show proposed remote writes and obtain explicit approval first. Never commit credentials or secrets. Keep `AGENTS.md` as the local contract; assistant-specific files, if added, should only point here.

## Session checkpoint
After verified work, update `docs/PROJECT_MEMORY.md`; update `docs/DECISIONS.md` only for decisions; update learning records only after demonstrated understanding. Record local Git state, verified tests, blockers, and one next safe action. Do not invent results. The current refactor stays on its branch until the user explicitly approves integration.
