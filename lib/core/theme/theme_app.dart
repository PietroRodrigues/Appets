import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:appets/core/theme/theme_colors.dart';

/// Define o tema visual global do app.
class AppTheme {
  AppTheme._();

  /// Tema claro do app, com fonte Poppins e cor base primária.
  static final ThemeData lightTheme = _createLightTheme();

  static ThemeData _createLightTheme() {
    // Poppins é empacotada como asset (section `fonts` do pubspec): com o
    // runtime fetching desligado, sem rede no primeiro frame e sem
    // dependência do Google Fonts API em runtime.
    GoogleFonts.config.allowRuntimeFetching = false;

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: ThemeColors.background,

      colorScheme: ColorScheme.fromSeed(
        seedColor: ThemeColors.primary,
        primary: ThemeColors.primary,
      ),

      textTheme: GoogleFonts.poppinsTextTheme(),

      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
    );
  }
}
