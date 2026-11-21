import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mini_pokemon/main.dart';

import 'fakes/fake_catalog_repository.dart';
import 'fakes/fake_collection_repository.dart';

void main() {
  testWidgets('starts with an empty collection and no manual form', (
    tester,
  ) async {
    await tester.pumpWidget(
      MyApp(
        collectionRepository: FakeCollectionRepository(),
        catalogRepository: FakeCatalogRepository(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('0 Pokemon'), findsOneWidget);
    expect(find.text('No Pokemon yet. Add your first one!'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNothing);
    expect(find.text('Add Pokemon'), findsNothing);
    expect(find.text('Edit'), findsNothing);
  });

  testWidgets('delete removes a Pokemon from the local collection', (
    tester,
  ) async {
    final repo = FakeCollectionRepository();
    await repo.add(testPokemon());

    await tester.pumpWidget(
      MyApp(
        collectionRepository: repo,
        catalogRepository: FakeCatalogRepository(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('1 Pokemon'), findsOneWidget);
    expect(find.text('BULBASAUR'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Delete').first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Delete').last);
    await tester.pumpAndSettle();

    expect(find.text('0 Pokemon'), findsOneWidget);
    expect(find.text('BULBASAUR'), findsNothing);
    repo.dispose();
  });

  testWidgets('discovers, collects, and deletes from collection', (
    tester,
  ) async {
    final repo = FakeCollectionRepository();
    await tester.pumpWidget(
      MyApp(
        collectionRepository: repo,
        catalogRepository: FakeCatalogRepository(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add New Pokemon'));
    await tester.pumpAndSettle();
    expect(find.text('BULBASAUR'), findsOneWidget);
    expect(find.text('Load more'), findsOneWidget);

    await tester.tap(find.text('BULBASAUR'));
    await tester.pumpAndSettle();
    expect(find.text('Special Attack'), findsOneWidget);
    expect(find.text('GRASS / POISON'), findsOneWidget);

    await tester.tap(find.text('Collect'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('1 Pokemon'), findsOneWidget);

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Delete'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('0 Pokemon'), findsOneWidget);
    repo.dispose();
  });
}
