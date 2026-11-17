# Decisions

## 2026-11-17: Minimal Flutter architecture
- **Decision:** Start with Flutter/Dart, an in-memory list, and built-in `setState` for PokÃ©mon CRUD.
- **Reason:** Beginner-friendly scope and a presentation deadline of 2026-11-19.
- **Tradeoff:** Data will reset when the application restarts; persistence is out of initial scope.
- **Revisit when:** Assessment requirements demand persistence, networking, or more complex state management.

## 2026-11-17: Learning and engineering records
- **Decision:** Keep local instructions in `AGENTS.md`, verified project state in `docs/`, and demonstrated learning in `learning/`.
- **Reason:** Support safe collaboration, progress tracking, and independent explanation.