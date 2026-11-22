# Mastery Tracker

Statuses: New, Practicing, Can Explain, Can Apply. Guided evidence is not independent mastery.

| Topic | Status | Evidence / next check |
|---|---|---|
| main, runApp, MyApp, MaterialApp, home | Can Explain | Guided startup teach-back; explain without notes |
| StatefulWidget vs StatelessWidget | Can Explain | Guided distinction; explain state ownership in screen versus card |
| Widgets and widget tree | Can Explain | Guided parent-child explanations; independently draw redesigned tree |
| Immutable Pokemon entity | Can Explain | Guided model discussion; retest identity versus immutability |
| Testing and debugging | Practicing | Earlier analyzer checks reported; run and explain new tests |
| Clean Architecture layers (`domain`, `data`, `presentation`) | New | Read `lib/` folder map; explain inward dependency rule without notes |
| Repository contracts and use cases | New | Trace `CollectPokemon` from contract to implementation |
| BLoC events and states | New | Explain `DiscoverStarted` to `DiscoverReady` without notes |
| `CollectionBloc`, `DiscoverBloc`, `DetailBloc` | New | Draw each event/state transition from source |
| PokéAPI DTOs and read-only catalog | New | Explain how `PokeApiPokemonDto` maps to `Pokemon` |
| Boundary testing | New | Explain what `test/layer_boundaries_test.dart` prevents |
| Composition root in `lib/main.dart` | New | Explain why only `main.dart` builds concrete repositories |
| Collection stream snapshot plus updates | New | Explain the regression test added in `e31409d` |

Historical topics from the removed CRUD/asset implementation:

| Topic | Status | Evidence / next check |
|---|---|---|
| setState | Can Explain | Explained gallery selection rebuild in own words; feature removed in refactor |
| CRUD | Practicing | Guided implementation and reported working; forms removed in refactor |
| Form validation and lifecycle | Practicing | Guided implementation; form removed in refactor |
| Gallery images and bundled assets | Practicing | Gallery preview demonstrated; assets and `image_picker` removed in refactor |
| Glassmorphism | New | Assistant-authored styling; inspect `ClipRect` and `BackdropFilter` |

No learning status is upgraded merely because assistant-authored code exists. Teaching gates were waived in this pass; no new teach-back evidence was collected.
