import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:appets/core/theme/theme_colors.dart';

/// Estilos de texto padronizados do app (fonte Poppins).
class ThemeTextStyles {
  ThemeTextStyles._();

  // Título grande (ex.: logos/telas de destaque).
  static final title = GoogleFonts.poppins(
    fontSize: 30,
    fontWeight: FontWeight.bold,
    color: ThemeColors.textPrimary,
  );

  // Subtítulo (ex.: títulos de seção/cards).
  static final subtitle = GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: ThemeColors.textPrimary,
  );

  // Cabeçalho de página (ex.: títulos de tela).
  static final heading = GoogleFonts.poppins(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: ThemeColors.textPrimary,
  );

  // Texto de corpo padrão.
  static final body = GoogleFonts.poppins(
    fontSize: 16,
    color: ThemeColors.textPrimary,
  );

  // Texto de corpo sobre fundo claro dos formulários de autenticação.
  static final authBody = body.copyWith(color: ThemeColors.white);

  // Texto auxiliar/captions (ex.: descrições pequenas).
  static final caption = GoogleFonts.poppins(
    fontSize: 13,
    color: ThemeColors.textSecondary,
  );

  // Texto dos botões.
  static final button = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  // Slogan exibido nas telas iniciais.
  static TextStyle get slogan => GoogleFonts.poppins(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    color: Colors.white70,
    letterSpacing: .3,
  );
}
