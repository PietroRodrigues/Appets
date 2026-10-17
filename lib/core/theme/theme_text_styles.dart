import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:appets/core/theme/app_colors.dart';

/// Estilos de texto padronizados do app (fonte Poppins).
///
/// Os estilos que dependem de [textPrimary]/[textSecondary] recebem a
/// paleta ativa ([AppColors]) para acompanhar o tema claro/escuro; quem
/// não recebe nada usa a paleta clara (fallback de segurança).
class ThemeTextStyles {
  ThemeTextStyles._();

  // Título grande (ex.: logos/telas de destaque).
  static TextStyle title([AppColors? c]) => GoogleFonts.poppins(
    fontSize: 30,
    fontWeight: FontWeight.bold,
    color: (c ?? AppColors.light).textPrimary,
    height: 1.2, // Espaçamento de linha ajustado para não "esmagar" textos grandes
  );

  // Cabeçalho de página (ex.: títulos de tela).
  static TextStyle heading([AppColors? c]) => GoogleFonts.poppins(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: (c ?? AppColors.light).textPrimary,
    height: 1.3,
  );

  // Subtítulo (ex.: títulos de seção/cards).
  static TextStyle subtitle([AppColors? c]) => GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w600, // w600 (SemiBold) cria melhor hierarquia
    color: (c ?? AppColors.light).textPrimary,
  );

  // Texto de corpo padrão.
  static TextStyle body([AppColors? c]) => GoogleFonts.poppins(
    fontSize: 16,
    color: (c ?? AppColors.light).textPrimary,
    height: 1.5, // Altura de linha padrão (150%) para leitura confortável
  );

  // Texto de apoio sobre a cor primária das telas de autenticação.
  static TextStyle authBody([AppColors? c]) => body(c).copyWith(
    color: (c ?? AppColors.light).onPrimary,
  );

  // Texto auxiliar/captions (ex.: descrições pequenas).
  static TextStyle caption([AppColors? c]) => GoogleFonts.poppins(
    fontSize: 13,
    color: (c ?? AppColors.light).textSecondary,
    height: 1.4,
  );

  // Texto dos botões.
  /// NOTA: Nos botões de fundo primário o texto padrão é o creme
  /// [AppColors.light.onPrimary] (estética do app e igual no tema escuro).
  /// O helper de contraste ([AppColors.onColor]) resolve sozinho:
  /// laranja → creme, e verde/vermelho/azul → escuro ou branco (WCAG).
  static final button = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.light.white, // Referência neutra, igual nas paletas
    letterSpacing: 0.5, // Dá um leve respiro às letras dentro de botões
  );
}