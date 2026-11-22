import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:mini_pokemon/main.dart';

import 'fakes/fake_catalog_repository.dart';
import 'fakes/fake_collection_repository.dart';

Widget _app(
  FakeCollectionRepository collection, {
  FakeCatalogRepository? catalog,
}) {
  return MyApp(
    collectionRepository: collection,
    catalogRepository: catalog ?? FakeCatalogRepository(),
  );
}

void main() {
  testWidgets('starts with an empty collection and no manual form', (
    tester,
  ) async {
    await tester.pumpWidget(_app(FakeCollectionRepository()));
    await tester.pumpAndSettle();

    expect(find.text('0 Pokemon'), findsOneWidget);
    expect(find.text('No Pokemon yet. Add your first one!'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNothing);
    expect(find.text('Name is required.'), findsNothing);
    expect(find.text('Save'), findsNothing);
  });

  testWidgets('bottom navigation exposes collection add and favorites', (
    tester,
  ) async {
    await tester.pumpWidget(_app(FakeCollectionRepository()));
    await tester.pumpAndSettle();

    expect(find.text('Collection'), findsOneWidget);
    expect(find.text('Add Pokemon'), findsOneWidget);
    expect(find.text('Favorites'), findsOneWidget);

    await tester.tap(find.text('Add Pokemon'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('search-field')), findsOneWidget);
  });

  testWidgets('delete removes a Pokemon from the local collection', (
    tester,
  ) async {
    final repo = FakeCollectionRepository();
    await repo.add(testPokemon());

    await tester.pumpWidget(_app(repo));
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

  testWidgets('edit form is prefilled and saves changed attributes', (
    tester,
  ) async {
    final repo = FakeCollectionRepository();
    await repo.add(testPokemon());
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    expect(find.text('Portrait URL (optional)'), findsNothing);
    final nameField = find.byKey(const Key('edit-name'));
    expect(tester.widget<TextField>(nameField).controller!.text, 'bulbasaur');

    await tester.enterText(nameField, 'Ivysaur');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('IVYSAUR'), findsOneWidget);
    expect(find.text('BULBASAUR'), findsNothing);
    expect(
      (await repo.watchAll().first).single.portraitUrl,
      'https://example.com/artwork.png',
    );
  });

  testWidgets('edit dialog leaves vertical space between fields', (
    tester,
  ) async {
    final repo = FakeCollectionRepository();
    await repo.add(testPokemon());
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextField);
    expect(fields, findsNWidgets(8));

    for (var index = 0; index < fields.evaluate().length - 1; index++) {
      final current = tester.getRect(fields.at(index));
      final next = tester.getRect(fields.at(index + 1));

      expect(
        next.top - current.bottom,
        greaterThanOrEqualTo(8),
        reason: 'gap between field $index and field ${index + 1}',
      );
    }
  });

  testWidgets('edit dialog scrolls with the keyboard open', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    tester.view.viewInsets = const FakeViewPadding(bottom: 260);
    addTearDown(() {
      tester.view.viewInsets = FakeViewPadding.zero;
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final repo = FakeCollectionRepository();
    await repo.add(testPokemon());
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);

    final scroll = find.byType(SingleChildScrollView);
    expect(scroll, findsOneWidget);

    await tester.drag(scroll, const Offset(0, -600));
    await tester.pumpAndSettle();

    expect(tester.getRect(find.byType(TextField).last).bottom, lessThan(640));
  });

  testWidgets('edit form rejects a blank name', (tester) async {
    final repo = FakeCollectionRepository();
    await repo.add(testPokemon());
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('edit-name')), '   ');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Name is required.'), findsOneWidget);
    expect(find.text('BULBASAUR'), findsWidgets);
  });

  testWidgets('star toggles favorite and favorites filter hides others', (
    tester,
  ) async {
    final repo = FakeCollectionRepository();
    await repo.add(testPokemon(apiId: 1));
    await repo.add(testPokemon(apiId: 2, name: 'ivysaur'));
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('favorite-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Favorites'));
    await tester.pumpAndSettle();

    expect(find.text('1 Pokemon'), findsOneWidget);
    expect(find.text('BULBASAUR'), findsOneWidget);
    expect(find.text('IVYSAUR'), findsNothing);
  });

  testWidgets('typing shows prefix then substring suggestions', (tester) async {
    await tester.pumpWidget(_app(FakeCollectionRepository()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add Pokemon'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('search-field')), 'p');
    await tester.pumpAndSettle();

    expect(find.text('PIKACHU'), findsOneWidget);
    expect(find.text('PICHU'), findsOneWidget);
    expect(find.text('PSYDUCK'), findsOneWidget);
    expect(find.text('AIPOM'), findsNothing);

    await tester.enterText(find.byKey(const Key('search-field')), 'pi');
    await tester.pumpAndSettle();

    expect(find.text('PIKACHU'), findsOneWidget);
    expect(find.text('PICHU'), findsOneWidget);
    expect(find.text('PSYDUCK'), findsNothing);
  });

  testWidgets('search finds a Pokemon without scrolling pages', (tester) async {
    await tester.pumpWidget(
      _app(
        FakeCollectionRepository(),
        catalog: FakeCatalogRepository(detailName: 'ivysaur'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add Pokemon'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('search-field')), 'ivysaur');
    await tester.tap(find.text('Search'));
    await tester.pumpAndSettle();

    expect(find.text('IVYSAUR'), findsOneWidget);
    expect(find.text('BULBASAUR'), findsNothing);
    expect(find.text('Load more'), findsNothing);
    expect(find.text('Clear'), findsOneWidget);

    await tester.tap(find.text('IVYSAUR'));
    await tester.pumpAndSettle();
    expect(find.text('Special Attack'), findsOneWidget);

    await tester.tap(find.text('Collect'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('1 Pokemon'), findsOneWidget);
  });

  testWidgets('discovers, collects, and deletes from collection', (
    tester,
  ) async {
    final repo = FakeCollectionRepository();
    await tester.pumpWidget(_app(repo));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add Pokemon'));
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

  testWidgets(
    'sqlite startup failure shows error and allows in-memory fallback',
    (tester) async {
      await tester.pumpWidget(
        MyApp(
          catalogRepository: FakeCatalogRepository(),
          startupError:
              'Unable to open local storage. Running in memory this session.',
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Unable to open local storage. Running in memory this session.',
        ),
        findsOneWidget,
      );
      expect(find.text('0 Pokemon'), findsOneWidget);
    },
  );
}
