# Project Memory

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
