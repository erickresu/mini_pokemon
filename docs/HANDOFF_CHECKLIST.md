# Handoff Checklist

## Before ending or switching assistants
- [ ] Read `AGENTS.md` and current project records
- [ ] Inspect local Git branch, status, and diffs
- [ ] Record latest local commit (or explicitly unknown)
- [ ] Record latest remote commit (or explicitly unknown)
- [ ] Record last verified checkpoint with commands and observed output
- [ ] Record uncommitted work and blockers
- [ ] Update `docs/PROJECT_MEMORY.md` with exactly one next safe action
- [ ] Update learning status only with teach-back or independent-work evidence
- [ ] Review changes for secrets before any proposed commit
- [ ] Obtain explicit approval before remote GitHub writes

## Verified checkpoint: 2026-11-17
- Local Windows branch: `main` at `25144e0fe137438649e03a9af97ddac9ecd0a5e1` when last shown in PowerShell. Current Windows working tree is not remotely inspectable.
- GitHub repository: https://github.com/nickos8/mini_pokemon (public).
- Uploaded remote baseline: `25144e0fe137438649e03a9af97ddac9ecd0a5e1`, verified by GitHub.
- Approved remote documentation updates: encoding fixes, memory, handoff, learning tracker. Remote `main` may advance after baseline; inspect before local synchronization.
- Engineering baseline: starter APK built/installed on emulator; previously reported `flutter analyze` clean and `flutter test` 1 passing counter test. No tests rerun for documentation-only updates.
- Learning: startup guided teach-back partially confirmed; `MaterialApp.home` still needs retest. Pokémon CRUD not implemented/verified.
- Next action: inspect current local Git status, local/remote commit identities, and uncommitted work before synchronizing the remote documentation changes.