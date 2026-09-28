import 'dart:math' as math;

import 'package:flutter/material.dart';

class ThemeColors {
  ThemeColors._();

  // 1. Brand
  /// Usado em: nav, chips, splash, botões, indicadores.
  static const Color primary = Color(0xFFF2A93B);

  /// Usado em: botão Google/outline, splash e galeria ([secondarySoft]).
  static const Color secondary = Color(0xFF8C5E0F);
  // =========================

  // 2. Background
  /// Usado em: scaffold ([AppTheme]).
  static const Color background = Color.fromARGB(255, 255, 243, 220);

  /// Usado em: cards, campos de texto, chips, galeria.
  static const Color surface = Color(0xFFFFFFFF);
  // =========================

  // 3. Text
  /// Usado em: títulos, corpo, rótulos; fallback de [onColor].
  static const Color textPrimary = Color(0xFF1C1408);

  /// Usado em: captions/textos secundários.
  static const Color textSecondary = Color.fromARGB(255, 110, 79, 22);

  /// Usado em: placeholders.
  static const Color hint = Color(0xFFA08A5C);
  // =========================

  // 4. States
  /// Usado em: botão "salvar contato", confirmações, banner online.
  static const Color success = Color(0xFF5DBB63);

  /// Usado em: avisos e favorito no card.
  static const Color warning = Color(0xFFF57C00);

  /// Usado em: textos/ícones de erro, snackbar, diálogos destrutivos.
  static const Color error = Color(0xFFD32F2F);

  /// Usado em: snackbar informativa.
  static const Color info = Color(0xFFC98A1C);

  /// Usado em: ícone/texto sobre fundo de erro (banner offline).
  static const Color errorOnPrimary = Color(0xFFFFFFFF);

  /// Usado em: ícone de gênero (pet macho).
  static const Color genderMale = Color(0xFF4A90E2);

  /// Usado em: ícone de gênero (pet fêmea).
  static const Color genderFemale = Color(0xFFE874A3);
  // =========================

  // 5. Borders
  /// Usado em: bordas de inputs/cards.
  static const Color border = Color(0xFFB3832B);

  /// Usado em: divisores sutis.
  static const Color divider = Color(0xFFE3CD9C);

  /// Usado em: elementos desabilitados.
  static const Color disabled = Color(0xFFC9B98C);
  // =========================

  // 6. Navigation / Destaques
  /// Ícone/rótulo do item ATIVO na [WGBottomNavigation] (sem pílula).
  ///
  /// Creme ([onPrimary]) sobre a barra laranja — destaque estético do app.
  /// O reforço vem do contraste claro-escuro + ícone preenchido, 10% maior
  /// e semibold.
  static const Color navigationActive = onPrimary;

  /// Ícone/rótulo dos itens INATIVOS na [WGBottomNavigation].
  ///
  /// Marrom escuro (contraste alto sobre o laranja); a diferenciação é feita
  /// pelo ícone outline + peso normal.
  static const Color navigationInactive = Color.fromARGB(255, 58, 36, 4);

  /// Cor para texto/ícones sobre a cor primária (laranja).
  ///
  /// Creme claro (mesma família da nav). Contraste ~1.6:1 sobre [primary] —
  /// escolha estética de design (não AA). Usado em: nav ativa, auth, splash,
  /// fab, AppBar, chips/filtros, headers, selos e botões de fundo primário.
  static const Color onPrimary = Color(0xFFF5E2C7);

  /// Usado em: card/item em destaque ([WGEditableTile]).
  static const Color cardHighlight = Color(0xFFFFFDF8);
  // =========================

  // 7. Neutral
  /// Usado em: textos sobre fundos escuros, ícones, bordas.
  static const Color white = Colors.white;

  /// Usado em: cores derivadas de sombra ([shadowCard] etc.).
  static const Color black = Colors.black;
  // =========================

  // 8. System bars
  /// Faixa atrás da barra de status ([WGSystemBarsBackdrop]).
  static const Color statusBar = Color(0x8C000000);
  // =========================

  // 9. Derived (sombra / soft)
  /// Usado em: [AppTheme] (appBar), fundo neutro de botões.
  static const Color transparent = Colors.transparent;

  /// Preto 54% — [WGImageSlotsGrid] (remoção de foto) e popover de filtros.
  static const Color scrimDark = Color(0x8A000000);

  /// Preto 38% — contador da [WGPetGallery].
  static const Color overlayCounter = Color(0x61000000);

  /// Preto 26% — sombras do [WGPetCard].
  static const Color shadowCard = Color(0x42000000);

  /// Preto 12% — sombra da [WGBottomNavigation].
  static const Color shadowNav = Color(0x1F000000);

  /// Preto 20% — sombra dos chips de filtro.
  static const Color shadowChips = Color(0x33000000);

  /// Preto 25% — sombra de botões/avatar/perfil.
  static const Color shadowButton = Color(0x40000000);

  /// Primária a 12% — fundos suaves ([WGEditableTile], [WGPageStates]).
  static const Color primarySoft = Color(0x1FF2A93B);

  /// Primária a 15% — indicador do [WGPublicationTypeSelector].
  static const Color primarySofter = Color(0x26F2A93B);

  /// Secundária a 40% — pontos da [WGPetGallery].
  static const Color secondarySoft = Color(0x668C5E0F);
  // =========================

  // 10. Contraste (helper)
  /// Texto/ícone sobre [background].
  ///
  /// Sobre a cor primária devolve o creme [onPrimary] (estética do app);
  /// nos demais fundos mantém WCAG-AA: escuro [textPrimary] ou branco.
  /// Usado em [WGButton]/[WGDialog]/[WGSnackBar]/banner de conexão.
  static Color onColor(Color background) {
    if (background == primary) return onPrimary;
    if (_contrast(background, textPrimary) >= 4.5) return textPrimary;
    return Colors.white;
  }

  static double _channel(double v) {
    return v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  }

  static double _luminance(Color c) {
    return 0.2126 * _channel(c.r) +
        0.7152 * _channel(c.g) +
        0.0722 * _channel(c.b);
  }

  static double _contrast(Color a, Color b) {
    final l1 = _luminance(a);
    final l2 = _luminance(b);
    final lighter = math.max(l1, l2);
    final darker = math.min(l1, l2);
    return (lighter + 0.05) / (darker + 0.05);
  }
}