# Handoff Checklist

## Branch status

- Worktree: `C:\dev\mini_pokemon_clean_architecture`
- Branch: `refactor/clean-architecture-api-only`
- Original checkout `C:\dev\mini_pokemon` is untouched.
- No merge, push, pull, rebase, clean, or remote write was performed.
- User choice: keep the branch only; review later.

## Engineering checks

Run from Windows PowerShell:

```powershell
Set-Location 'C:\dev\mini_pokemon_clean_architecture'
dart format lib test
flutter pub get
flutter analyze
flutter test
```

- [x] `dart format lib test` completes.
- [x] `flutter pub get` resolves without `image_picker`.
- [x] `flutter analyze` reports no issues.
- [x] `flutter test` passes all tests.
- [x] `flutter test test/layer_boundaries_test.dart` passes boundary guards.

## Flow checks in widget tests

- [x] Collection starts empty: `0 Pokemon` and `No Pokemon yet. Add your first one!`.
- [x] No `FloatingActionButton`, add form, edit form, `Add Pokemon`, or `Edit`.
- [x] `Add New Pokemon` opens Discover with a first page and `Load more`.
- [x] Detail shows six base stats and `GRASS / POISON`.
- [x] `Collect` returns a `Pokemon`, adds it through `CollectionBloc`, and shows `1 Pokemon`.
- [x] Delete confirmation removes the local entry and returns to `0 Pokemon`.
- [x] Duplicate API ids are rejected by `CollectPokemon`.
- [x] Boundary test rejects domain-to-framework/data/presentation imports and old form/assets.

## Emulator checks

- [ ] Run `flutter run -d emulator-5554 --no-resident` on a real device/emulator.
- [ ] Confirm empty start, no FAB/edit UI, Discover pagination/retry, detail retry, collect, duplicate notice, and delete.
- [ ] Record observed device output before claiming runtime verification.

No emulator output exists for this branch. Do not mark these complete without a captured result.

## Integration

- [ ] User reviews the branch.
- [ ] User explicitly approves any merge or remote write.
- [ ] If approved, inspect status and diff again before integration.
