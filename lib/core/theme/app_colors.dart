import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Paleta do app exposta como [ThemeExtension].
///
/// O [AppTheme] carrega a instância clara ([AppColors.light]) e os widgets
/// leem as cores de `context.appColors`, com o laranja [primary] como
/// identidade do app.
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.primary,
    required this.secondary,
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.hint,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
    required this.errorOnPrimary,
    required this.genderMale,
    required this.genderFemale,
    required this.border,
    required this.divider,
    required this.disabled,
    required this.navigationActive,
    required this.navigationInactive,
    required this.onPrimary,
    required this.cardHighlight,
    required this.white,
    required this.black,
    required this.statusBar,
    required this.transparent,
    required this.scrimDark,
    required this.overlayCounter,
    required this.shadowCard,
    required this.shadowNav,
    required this.shadowChips,
    required this.shadowButton,
    required this.primarySoft,
    required this.primarySofter,
    required this.secondarySoft,
  });

  // 1. Brand
  /// Usado em: nav, chips, splash, botões, indicadores. Identidade do app.
  final Color primary;

  /// Usado em: botão Google/outline, splash e galeria ([secondarySoft]).
  final Color secondary;
  // =========================

  // 2. Background
  /// Usado em: scaffold ([AppTheme]).
  final Color background;

  /// Usado em: cards, campos de texto, chips, galeria.
  final Color surface;
  // =========================

  // 3. Text
  /// Usado em: títulos, corpo, rótulos; fallback de [onColor].
  final Color textPrimary;

  /// Usado em: captions/textos secundários.
  final Color textSecondary;

  /// Usado em: placeholders.
  final Color hint;
  // =========================

  // 4. States
  /// Usado em: botão "salvar contato", confirmações, banner online.
  final Color success;

  /// Usado em: avisos e favorito no card.
  final Color warning;

  /// Usado em: textos/ícones de erro, snackbar, diálogos destrutivos.
  final Color error;

  /// Usado em: snackbar informativa.
  final Color info;

  /// Usado em: ícone/texto sobre fundo de erro (banner offline).
  final Color errorOnPrimary;

  /// Usado em: ícone de gênero (pet macho).
  final Color genderMale;

  /// Usado em: ícone de gênero (pet fêmea).
  final Color genderFemale;
  // =========================

  // 5. Borders
  /// Usado em: bordas de inputs/cards.
  final Color border;

  /// Usado em: divisores sutis.
  final Color divider;

  /// Usado em: elementos desabilitados.
  final Color disabled;
  // =========================

  // 6. Navigation / Destaques
  /// Ícone/rótulo do item ATIVO na [WGBottomNavigation] (sem pílula).
  final Color navigationActive;

  /// Ícone/rótulo dos itens INATIVOS na [WGBottomNavigation].
  final Color navigationInactive;

  /// Cor para texto/ícones sobre a cor primária (laranja). Creme claro
  /// (mesma família da nav) — escolha estética (não AA).
  final Color onPrimary;

  /// Usado em: card/item em destaque ([WGEditableTile]).
  final Color cardHighlight;
  // =========================

  // 7. Neutral
  /// Usado em: textos sobre fundos escuros, ícones, bordas.
  final Color white;

  /// Usado em: cores derivadas de sombra ([shadowCard] etc.).
  final Color black;
  // =========================

  // 8. System bars
  /// Faixa atrás da barra de status ([SystemBarsBackdrop]).
  final Color statusBar;
  // =========================

  // 9. Derived (sombra / soft)
  /// Usado em: [AppTheme] (appBar), fundo neutro de botões.
  final Color transparent;

  /// Preto 54% — [WGImageSlotsGrid] (remoção de foto) e popover de filtros.
  final Color scrimDark;

  /// Preto 38% — contador da [WGPetGallery].
  final Color overlayCounter;

  /// Preto 26% — sombras do [WGPetCard].
  final Color shadowCard;

  /// Preto 12% — sombra da [WGBottomNavigation].
  final Color shadowNav;

  /// Preto 20% — sombra dos chips de filtro.
  final Color shadowChips;

  /// Preto 25% — sombra de botões/avatar/perfil.
  final Color shadowButton;

  /// Primária a 12% — fundos suaves ([WGEditableTile], [WGPageStates]).
  final Color primarySoft;

  /// Primária a 15% — variante mais intensa de [primarySoft].
  final Color primarySofter;

  /// Secundária a 40% — pontos da [WGPetGallery].
  final Color secondarySoft;

  /// Lê a paleta ativa do tema; cai na clara fora de um [MaterialApp] com
  /// tema do app.
  static AppColors of(BuildContext context) {
    return Theme.of(context).extension<AppColors>() ?? AppColors.light;
  }

  // ================== Paletas ==================

  /// Paleta do app (modo claro; identidade atual do app).
  static const AppColors light = AppColors(
    primary: Color(0xFFF2A93B),
    secondary: Color(0xFF8C5E0F),
    background: Color.fromARGB(255, 255, 243, 220),
    surface: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF1C1408),
    textSecondary: Color.fromARGB(255, 110, 79, 22),
    hint: Color(0xFFA08A5C),
    success: Color(0xFF5DBB63),
    warning: Color(0xFFF57C00),
    error: Color(0xFFD32F2F),
    info: Color(0xFFC98A1C),
    errorOnPrimary: Color(0xFFFFFFFF),
    genderMale: Color(0xFF4A90E2),
    genderFemale: Color(0xFFE874A3),
    border: Color(0xFFB3832B),
    divider: Color(0xFFE3CD9C),
    disabled: Color(0xFFC9B98C),
    navigationActive: Color(0xFFF5E2C7),
    navigationInactive: Color.fromARGB(255, 58, 36, 4),
    onPrimary: Color(0xFFF5E2C7),
    cardHighlight: Color(0xFFFFFDF8),
    white: Color(0xFFFFFFFF),
    black: Color(0xFF000000),
    statusBar: Color(0x8C000000),
    transparent: Color(0x00000000),
    scrimDark: Color(0x8A000000),
    overlayCounter: Color(0x61000000),
    shadowCard: Color(0x42000000),
    shadowNav: Color(0x1F000000),
    shadowChips: Color(0x33000000),
    shadowButton: Color(0x40000000),
    primarySoft: Color(0x1FF2A93B),
    primarySofter: Color(0x26F2A93B),
    secondarySoft: Color(0x668C5E0F),
  );

  // ================== Helpers ==================

  /// Texto/ícone sobre [background].
  ///
  /// Sobre a cor primária devolve o creme [onPrimary] (estética do app);
  /// nos demais fundos mantém WCAG-AA: usa [textPrimary] quando há
  /// contraste suficiente, senão o contraste máximo da paleta (branco no
  /// claro, quase preto no escuro).
  Color onColor(Color background) {
    if (background == primary) return onPrimary;
    if (_contrast(background, textPrimary) >= 4.5) return textPrimary;
    return Colors.white;
  }

  static double _channel(double v) {
    return v <= 0.03928
        ? v / 12.92
        : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
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

  @override
  AppColors copyWith({
    Color? primary,
    Color? secondary,
    Color? background,
    Color? surface,
    Color? textPrimary,
    Color? textSecondary,
    Color? hint,
    Color? success,
    Color? warning,
    Color? error,
    Color? info,
    Color? errorOnPrimary,
    Color? genderMale,
    Color? genderFemale,
    Color? border,
    Color? divider,
    Color? disabled,
    Color? navigationActive,
    Color? navigationInactive,
    Color? onPrimary,
    Color? cardHighlight,
    Color? white,
    Color? black,
    Color? statusBar,
    Color? transparent,
    Color? scrimDark,
    Color? overlayCounter,
    Color? shadowCard,
    Color? shadowNav,
    Color? shadowChips,
    Color? shadowButton,
    Color? primarySoft,
    Color? primarySofter,
    Color? secondarySoft,
  }) {
    return AppColors(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      hint: hint ?? this.hint,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      info: info ?? this.info,
      errorOnPrimary: errorOnPrimary ?? this.errorOnPrimary,
      genderMale: genderMale ?? this.genderMale,
      genderFemale: genderFemale ?? this.genderFemale,
      border: border ?? this.border,
      divider: divider ?? this.divider,
      disabled: disabled ?? this.disabled,
      navigationActive: navigationActive ?? this.navigationActive,
      navigationInactive: navigationInactive ?? this.navigationInactive,
      onPrimary: onPrimary ?? this.onPrimary,
      cardHighlight: cardHighlight ?? this.cardHighlight,
      white: white ?? this.white,
      black: black ?? this.black,
      statusBar: statusBar ?? this.statusBar,
      transparent: transparent ?? this.transparent,
      scrimDark: scrimDark ?? this.scrimDark,
      overlayCounter: overlayCounter ?? this.overlayCounter,
      shadowCard: shadowCard ?? this.shadowCard,
      shadowNav: shadowNav ?? this.shadowNav,
      shadowChips: shadowChips ?? this.shadowChips,
      shadowButton: shadowButton ?? this.shadowButton,
      primarySoft: primarySoft ?? this.primarySoft,
      primarySofter: primarySofter ?? this.primarySofter,
      secondarySoft: secondarySoft ?? this.secondarySoft,
    );
  }

  @override
  AppColors lerp(covariant AppColors? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      primary: Color.lerp(primary, other.primary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      hint: Color.lerp(hint, other.hint, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
      info: Color.lerp(info, other.info, t)!,
      errorOnPrimary: Color.lerp(errorOnPrimary, other.errorOnPrimary, t)!,
      genderMale: Color.lerp(genderMale, other.genderMale, t)!,
      genderFemale: Color.lerp(genderFemale, other.genderFemale, t)!,
      border: Color.lerp(border, other.border, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      disabled: Color.lerp(disabled, other.disabled, t)!,
      navigationActive: Color.lerp(
        navigationActive,
        other.navigationActive,
        t,
      )!,
      navigationInactive: Color.lerp(
        navigationInactive,
        other.navigationInactive,
        t,
      )!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      cardHighlight: Color.lerp(cardHighlight, other.cardHighlight, t)!,
      white: Color.lerp(white, other.white, t)!,
      black: Color.lerp(black, other.black, t)!,
      statusBar: Color.lerp(statusBar, other.statusBar, t)!,
      transparent: Color.lerp(transparent, other.transparent, t)!,
      scrimDark: Color.lerp(scrimDark, other.scrimDark, t)!,
      overlayCounter: Color.lerp(overlayCounter, other.overlayCounter, t)!,
      shadowCard: Color.lerp(shadowCard, other.shadowCard, t)!,
      shadowNav: Color.lerp(shadowNav, other.shadowNav, t)!,
      shadowChips: Color.lerp(shadowChips, other.shadowChips, t)!,
      shadowButton: Color.lerp(shadowButton, other.shadowButton, t)!,
      primarySoft: Color.lerp(primarySoft, other.primarySoft, t)!,
      primarySofter: Color.lerp(primarySofter, other.primarySofter, t)!,
      secondarySoft: Color.lerp(secondarySoft, other.secondarySoft, t)!,
    );
  }
}

/// Acesso rápido nos widgets: `context.appColors.primary`.
extension AppColorsContextX on BuildContext {
  AppColors get appColors => AppColors.of(this);
}