import 'package:material_ui/material_ui.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    const ink = Color(0xFF242B25);
    const paper = Color(0xFFF5F3EC);
    const red = Color(0xFFBA4938);
    return ThemeData(
      colorScheme:
          ColorScheme.fromSeed(
            seedColor: red,
            brightness: Brightness.light,
          ).copyWith(
            primary: red,
            onPrimary: Colors.white,
            surface: paper,
            onSurface: ink,
          ),
      scaffoldBackgroundColor: paper,
      appBarTheme: const AppBarTheme(
        backgroundColor: paper,
        foregroundColor: ink,
        elevation: 0,
      ),
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
    );
  }
}
