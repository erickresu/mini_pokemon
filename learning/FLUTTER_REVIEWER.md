# Flutter Field Guide: presentation reviewer

Goal: explain responsibilities and data flow, not memorize styling.

## 1. Core Flutter
**Simple explanation:** Dart executes main; runApp supplies MyApp to Flutter.
**Why it matters:** Establishes root configuration and initial screen.
**Cause -> Process -> Result:** main() -> runApp(const MyApp()) -> MyApp.build -> MaterialApp.home -> PokemonListPage.
**Example:** lib/main.dart defines a paper/red theme and native navigation.
**Your turn:** Which property changes the initial screen without changing main?

## 2. Stateful and Stateless
**Simple explanation:** StatefulWidget has a separate State object; StatelessWidget builds from supplied configuration.
**Why it matters:** State ownership is explicit.
**Cause -> Process -> Result:** list State changes -> parent rebuild -> new PokemonCard configuration.
**Example:** PokemonListPage owns _pokemons and _nextId. PokemonFormDialog owns controllers and image selection. MyApp and PokemonCard are stateless; cards receive pokemon and callbacks.
**Your turn:** Why can PokemonCard display new HP without owning State?

## 3. Widgets
**Simple explanation:** Components describing UI.
**Why it matters:** Compose small components instead of drawing everything manually.
**Cause -> Process -> Result:** widget properties and child widgets describe layout and appearance.
**Example:** Card, Row, Column, Text, Image.asset, TextButton.icon and LinearProgressIndicator in pokemon_card.dart.
**Your turn:** What is the difference between Row and Column?

## 4. Widget tree
**Simple explanation:** Parent-child widget hierarchy.
**Why it matters:** It explains layout and configuration relationships.
**Cause -> Process -> Result:** MyApp -> MaterialApp -> PokemonListPage -> Scaffold -> Stack -> Column -> Expanded -> ListView.builder -> PokemonCard.
**Example:** PokemonCard builds Card -> Column with entry header, portrait/stat row, divider and action row. Scaffold also has AppBar and FloatingActionButton.
**Your turn:** Trace a single Edit button back to its parent card.

## 5. setState
**Simple explanation:** Notify Flutter that State changed and schedule rebuilding.
**Why it matters:** Changing data alone does not notify Flutter.
**Cause -> Process -> Result:** dialog returns valid Pokemon -> setState mutates list -> build runs -> collection reflects change.
**Example:** _pokemons.add(pokemon); _nextId++; (Create); _pokemons[index] = updatedPokemon; (Update); _pokemons.removeAt(index); (Delete). All occur inside setState. Read uses ListView.builder.
**Your turn:** What happens if removeAt runs without setState?

## Trace the form
The parent awaits showDialog<Pokemon>. The form preloads values in initState for edit, validates input, builds a new immutable Pokemon with the same ID for edit, and returns it with Navigator.pop. Cancel returns null. mounted guards asynchronous work. Controllers are disposed when State is removed.

## Images
Starter records store assetPath; gallery selections store imagePath. Picking a new file clears assetPath; removing a photo clears both. Save passes both paths to the new object. Card chooses Image.file, Image.asset or placeholder. This uses native State, not an API. Both fields are optional.

## Styling
ClipRect and BackdropFilter create a localized frosted header. The rest uses ordinary Card, Container and TextStyle. Attribute bars are normalized against 150 and clamped; numbers remain the actual values.

## Independent practice
Change a theme color, then draw the card tree, then implement a +10 HP action using an immutable replacement object and setState. Explain each change before moving on.

## Presentation honesty
Data is in memory, not SQLite. No live API, battle engine, or permanent photo storage. Assistant helped design and implement the final styling; explain your own contribution accurately. Final branch runtime tests must be run locally.
