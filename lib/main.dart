import 'package:material_ui/material_ui.dart';

import 'screens/pokemon_list_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF242B25);
    const paper = Color(0xFFF5F3EC);
    const red = Color(0xFFBA4938);
    return MaterialApp(
      title: 'Mini Pokemon',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: red, brightness: Brightness.light).copyWith(
          primary: red,
          onPrimary: Colors.white,
          surface: paper,
          onSurface: ink,
        ),
        scaffoldBackgroundColor: paper,
        appBarTheme: const AppBarTheme(backgroundColor: paper, foregroundColor: ink, elevation: 0),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: red,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFFCFBF7),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
      home: const PokemonListPage(),
    );
  }
}
