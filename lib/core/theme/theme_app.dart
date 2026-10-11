import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:appets/core/theme/app_colors.dart';

/// Define o tema visual global do app.
class AppTheme {
  AppTheme._();

  /// Tema do app (modo claro), com fonte Poppins e cor base primária.
  static final ThemeData lightTheme = _createTheme(AppColors.light);

  static ThemeData _createTheme(AppColors colors) {
    // Poppins é empacotada como asset (section `fonts` do pubspec): com o
    // runtime fetching desligado, sem rede no primeiro frame e sem
    // dependência do Google Fonts API em runtime.
    GoogleFonts.config.allowRuntimeFetching = false;

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: colors.background,

      extensions: [colors],

      colorScheme: ColorScheme.fromSeed(
        seedColor: colors.primary,
        primary: colors.primary,
      ),

      textTheme: GoogleFonts.poppinsTextTheme(),

      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: colors.transparent,
      ),
    );
  }
}