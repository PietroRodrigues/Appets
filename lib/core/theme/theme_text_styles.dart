import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:appets/core/theme/theme_colors.dart';

class ThemeTextStyles {
  ThemeTextStyles._();

  static final title = GoogleFonts.poppins(
    fontSize: 30,
    fontWeight: FontWeight.bold,
    color: ThemeColors.textPrimary,
  );

  static final subtitle = GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: ThemeColors.textPrimary,
  );

  static final heading = GoogleFonts.poppins(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: ThemeColors.textPrimary,
  );

  static final body = GoogleFonts.poppins(
    fontSize: 16,
    color: ThemeColors.textPrimary,
  );

  static final authBody = body.copyWith(color: ThemeColors.white);

  static final caption = GoogleFonts.poppins(
    fontSize: 13,
    color: ThemeColors.textSecondary,
  );

  static final button = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static TextStyle get slogan => GoogleFonts.poppins(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    color: Colors.white70,
    letterSpacing: .3,
  );
}
