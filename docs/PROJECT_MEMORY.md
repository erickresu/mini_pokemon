# Project Memory

Last updated: 2026-11-17

## Goal
Prepare a demonstrable Flutter Mini Pokémon CRUD application for Thursday, 2026-11-19, while learning to explain the implementation independently.

## Verified evidence from shared terminal output
- Flutter project created at `C:\dev\mini_pokemon`.
- `lib/main.dart` exists.
- Android NDK `28.2.13676358` detected locally.
- `flutter run -d emulator-5554` built `app-debug.apk`, installed it, and connected the Dart VM Service on 2026-11-17.
- VS Code screenshot shows the default Flutter starter `main.dart` open.

## Verified GitHub checkpoint
- Repository: https://github.com/nickos8/mini_pokemon (public, `main`).
- Initial local commit and uploaded remote commit: `25144e0fe137438649e03a9af97ddac9ecd0a5e1` (`Initial Flutter project with learning documentation`), verified from shared local output and GitHub commit search.
- GitHub source inspected: `lib/main.dart` still shows the Flutter starter counter app; `test/widget_test.dart` tests counter increments.
- Earlier shared terminal output reported `flutter analyze`: no issues; `flutter test`: 1 passing starter test. Not rerun after documentation changes.
- The user approved a documentation-only GitHub update to correct encoding, record checkpoints and learning evidence.

## Not yet verified
- Current Windows working-tree status after GitHub documentation updates (remote writes are not automatically on the laptop).
- Visual confirmation of the starter screen.
- Any Pokémon CRUD implementation or CRUD tests.

## Engineering state
Starter Android build: verified from user-provided terminal output.
Pokémon CRUD: not started / not verified.

## Learning state
Guided teach-back supports "Can Explain" for startup roles of `main()`, `runApp()`, `MyApp` and `MaterialApp`. `MaterialApp.home` is still Practicing pending the follow-up question. Widget fundamentals and CRUD are New. See `learning/MASTERY_TRACKER.md`.

## Next safe action
On the Windows laptop, inspect `git status`, `git log -1 --oneline`, and `git remote -v` before synchronizing approved GitHub documentation updates with local work; do not assume local and remote histories are identical.