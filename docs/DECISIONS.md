# Decisions

## 2026-11-17: Minimal Flutter architecture
- **Decision:** Start with Flutter/Dart, an in-memory list, and built-in `setState` for Pokémon CRUD.
- **Reason:** Beginner-friendly scope and a presentation deadline of 2026-11-19.
- **Tradeoff:** Data will reset when the application restarts; persistence is out of initial scope.
- **Revisit when:** Assessment requirements demand persistence, networking, or more complex state management.

## 2026-11-17: Learning and engineering records
- **Decision:** Keep local instructions in `AGENTS.md`, verified project state in `docs/`, and demonstrated learning in `learning/`.
- **Reason:** Support safe collaboration, progress tracking, and independent explanation.

## 2026-11-18: Field Guide presentation and assets
- Decision: preserve list, dialogs, CRUD and native setState; warm paper, vermilion, editorial cards and localized header blur.
- Decision: bundle three starter PNGs and use optional assetPath separately from gallery imagePath.
- Tradeoff: static assets increase bundle size; no runtime network request. Image paths and collection edits are not permanently stored. No extra packages.
