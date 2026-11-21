import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

List<File> dartFiles(String path) {
  final directory = Directory(path);
  if (!directory.existsSync()) return const [];

  return directory
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .toList();
}

void main() {
  test(
    'domain does not depend on Flutter, IO, HTTP, data, or presentation',
    () {
      for (final file in dartFiles('lib/domain')) {
        final source = file.readAsStringSync();

        expect(source, isNot(contains('package:flutter')), reason: file.path);
        expect(source, isNot(contains('dart:io')), reason: file.path);
        expect(source, isNot(contains('package:http')), reason: file.path);
        expect(source, isNot(contains('../data/')), reason: file.path);
        expect(source, isNot(contains('../presentation/')), reason: file.path);
      }
    },
  );

  test('presentation does not depend on data or HTTP directly', () {
    for (final file in dartFiles('lib/presentation')) {
      final source = file.readAsStringSync();

      expect(source, isNot(contains('../data/')), reason: file.path);
      expect(source, isNot(contains('package:http')), reason: file.path);
    }
  });

  test('presentation widgets do not know the API client', () {
    for (final file in dartFiles('lib/presentation/widgets')) {
      expect(
        file.readAsStringSync(),
        isNot(contains('PokeApi')),
        reason: file.path,
      );
    }
  });

  test('manual form and bundled starter art are gone', () {
    expect(File('lib/widgets/pokemon_form_dialog.dart').existsSync(), isFalse);
    expect(Directory('assets/pokemon').existsSync(), isFalse);
  });
}
