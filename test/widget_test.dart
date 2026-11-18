import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mini_pokemon/main.dart';
import 'package:mini_pokemon/widgets/pokemon_card.dart';

Future<void> openAdd(WidgetTester tester) async {
  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();
}

Future<void> fillField(WidgetTester tester, int index, String text) async {
  final field = find.byType(TextFormField).at(index);
  await tester.ensureVisible(field);
  await tester.enterText(field, text);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Displays the initial collection', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('3 Pokemon'), findsOneWidget);
    expect(find.text('Charmander'), findsOneWidget);
    expect(find.text('Squirtle'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Bulbasaur'), 150, scrollable: find.byType(Scrollable).first);
    expect(find.text('Bulbasaur'), findsOneWidget);
    expect(tester.widget<PokemonCard>(find.byKey(const ValueKey(3))).pokemon.assetPath,
        'assets/pokemon/bulbasaur.png');
  });

  testWidgets('Rejects empty and invalid fields', (tester) async {
    await tester.pumpWidget(const MyApp());
    await openAdd(tester);
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Required field'), findsWidgets);
    await fillField(tester, 2, '0');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a positive integer'), findsOneWidget);
  });

  testWidgets('Creates a Pokemon with a unique ID', (tester) async {
    await tester.pumpWidget(const MyApp());
    await openAdd(tester);
    for (final entry in ['Pikachu', 'Electric', '100', '55', '40'].asMap().entries) {
      await fillField(tester, entry.key, entry.value);
    }
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('4 Pokemon'), findsOneWidget);
    final card = find.byKey(const ValueKey(4));
    await tester.scrollUntilVisible(card, 150, scrollable: find.byType(Scrollable).first);
    expect(tester.widget<PokemonCard>(card).pokemon.name, 'Pikachu');
  });

  testWidgets('Edits an entry while retaining its ID', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.descendant(of: find.byKey(const ValueKey(1)), matching: find.text('Edit')));
    await tester.pumpAndSettle();
    expect(find.text('Edit Pokemon'), findsOneWidget);
    await fillField(tester, 2, '150');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    final card = tester.widget<PokemonCard>(find.byKey(const ValueKey(1)));
    expect(card.pokemon.hp, 150);
    expect(card.pokemon.id, 1);
    expect(card.pokemon.assetPath, 'assets/pokemon/charmander.png');
    expect(find.text('3 Pokemon'), findsOneWidget);
  });

  testWidgets('Cancels and confirms deletion', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.descendant(of: find.byKey(const ValueKey(1)), matching: find.text('Delete')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Charmander'), findsOneWidget);
    await tester.tap(find.descendant(of: find.byKey(const ValueKey(1)), matching: find.text('Delete')));
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(of: find.byType(AlertDialog), matching: find.text('Delete')));
    await tester.pumpAndSettle();
    expect(find.text('Charmander'), findsNothing);
    expect(find.text('2 Pokemon'), findsOneWidget);
  });
}
