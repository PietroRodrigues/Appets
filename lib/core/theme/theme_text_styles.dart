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
    height: 1.2, // Espaçamento de linha ajustado para não "esmagar" textos grandes
  );

  // Cabeçalho de página (ex.: títulos de tela).
  static final heading = GoogleFonts.poppins(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: ThemeColors.textPrimary,
    height: 1.3,
  );

  // Subtítulo (ex.: títulos de seção/cards).
  static final subtitle = GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w600, // w600 (SemiBold) cria melhor hierarquia
    color: ThemeColors.textPrimary,
  );

  // Texto de corpo padrão.
  static final body = GoogleFonts.poppins(
    fontSize: 16,
    color: ThemeColors.textPrimary,
    height: 1.5, // Altura de linha padrão (150%) para leitura confortável
  );

  // Texto de apoio sobre a cor primária das telas de autenticação.
  static final authBody = body.copyWith(color: ThemeColors.onPrimary);

  // Texto auxiliar/captions (ex.: descrições pequenas).
  static final caption = GoogleFonts.poppins(
    fontSize: 13,
    color: ThemeColors.textSecondary,
    height: 1.4,
  );

// Texto dos botões.
  /// NOTA: Nos botões de fundo primário o texto padrão é o creme
  /// [ThemeColors.onPrimary] (estética do app). O helper de contraste
  /// ([ThemeColors.onColor]) resolve sozinho: laranja → creme, e
  /// verde/vermelho/azul → escuro ou branco (WCAG).
  static final button = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: ThemeColors.white, // Referência neutra do ThemeColors
    letterSpacing: 0.5, // Dá um leve respiro às letras dentro de botões
  );

  // Slogan exibido nas telas iniciais (sobre a cor primária).
  static TextStyle get slogan => GoogleFonts.poppins(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    color: ThemeColors.onPrimary,
    letterSpacing: 0.3,
  );
}