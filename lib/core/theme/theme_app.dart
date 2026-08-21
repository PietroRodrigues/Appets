import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:appets/core/theme/theme_colors.dart';

class AppTheme {
  AppTheme._();

  static final ThemeData lightTheme = ThemeData(
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
