import 'package:flutter/material.dart';
import 'pages/movie_list_page.dart';
import 'services/movie_service.dart';

// Instance globale du service partagée dans toute l'application
final movieService = MovieService();

void main() => runApp(const CanIWatchApp());

class CanIWatchApp extends StatelessWidget {
  const CanIWatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Modern blue theme for CanIWatch
    const primaryBlue = Color(0xFF1E88E5);
    const secondaryBlue = Color(0xFF0D47A1);
    const bg = Color(0xFF111317);
    const surface = Color(0xFF1A1C20);
    const surfaceVariant = Color(0xFF23262C);
    const onSurface = Color(0xFFEAE7E2);
    const onSurfaceVariant = Color(0xFFB7B9BD);

    final colorScheme = const ColorScheme.dark(
      primary: primaryBlue,
      onPrimary: Color(0xFFFFFFFF),
      secondary: secondaryBlue,
      onSecondary: Color(0xFFFFFFFF),
      surface: surface,
      onSurface: onSurface,
      surfaceContainerHighest: surfaceVariant,
      onSurfaceVariant: onSurfaceVariant,
    );

    final theme = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: bg,
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        foregroundColor: onSurface,
        centerTitle: true,
        elevation: 0,
      ),
      cardTheme: const CardThemeData(
        color: surface,
        elevation: 1,
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
      ),
      dividerColor: surface,
      iconTheme: const IconThemeData(color: onSurfaceVariant),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: const Color(0xFFFFFFFF),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: onSurfaceVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: onSurfaceVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: primaryBlue),
        ),
        labelStyle: TextStyle(color: onSurfaceVariant),
        hintStyle: TextStyle(color: onSurfaceVariant),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primaryBlue,
        unselectedItemColor: onSurfaceVariant,
        elevation: 0,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          color: onSurface,
        ),
        headlineMedium: TextStyle(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
          color: onSurface,
        ),
        titleLarge: TextStyle(
          fontWeight: FontWeight.w600,
          color: onSurface,
        ),
        bodyLarge: TextStyle(
          color: onSurface,
        ),
        bodyMedium: TextStyle(
          color: onSurface,
          height: 1.5,
        ),
      ),
    );

    return MaterialApp(
      title: 'CanIWatch',
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: MovieListPage(movieService: movieService),
    );
  }
}
