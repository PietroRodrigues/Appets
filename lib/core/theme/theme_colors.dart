import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // =========================
  // Brand
  // =========================

  static const Color primary = Color(0xFFF2A93B);
  static const Color secondary = Color.fromARGB(255, 37, 37, 36);

  // =========================
  // Background
  // =========================

  static const Color background = Color.fromARGB(255, 241, 226, 183);
  static const Color surface = Color(0xFFF8F8F8);

  // =========================
  // Text
  // =========================

  static const Color textPrimary = Color(0xFF1F1F1F);
  static const Color textSecondary = Color(0xFF666666);
  static const Color hint = Color(0xFF9E9E9E);

  // =========================
  // States
  // =========================

  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF42A5F5);

  // =========================
  // Borders
  // =========================

  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFEAEAEA);
  static const Color disabled = Color(0xFFBDBDBD);

  // =========================
  // Navigation / Destaques
  // =========================

  /// Ícones e textos NÃO selecionados sobre fundo primário.
  static const Color navigationInactive = Color.fromARGB(255, 83, 83, 82);

  /// Ícones e textos selecionados.
  static const Color navigationActive = Color.fromARGB(255, 240, 230, 211);

  /// Indicador atrás do item selecionado.
  static const Color navigationIndicator = Color.fromARGB(255, 0, 0, 0);

  /// Cor para ícones claros em fundos coloridos.
  static const Color onPrimary = Color(0xFFFFFFFF);

  /// Cor utilizada em Cards destacados.
  static const Color cardHighlight = Color(0xFFFFF7EA);

  // =========================
  // Neutral
  // =========================

  static const Color white = Colors.white;
  static const Color black = Colors.black;
}
