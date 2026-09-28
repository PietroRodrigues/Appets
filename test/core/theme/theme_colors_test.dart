import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:appets/core/theme/theme_colors.dart';

/// Canais em intensidade linear (padrão WCAG), v em 0..1.
double _channel(double v) {
  return v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
}

/// Luminância relativa (WCAG).
double _luminance(Color c) {
  return 0.2126 * _channel(c.r) +
      0.7152 * _channel(c.g) +
      0.0722 * _channel(c.b);
}

/// Contraste entre duas cores (WCAG).
double _contrast(Color a, Color b) {
  final l1 = _luminance(a);
  final l2 = _luminance(b);
  final lighter = math.max(l1, l2);
  final darker = math.min(l1, l2);
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  test('texto principal é legível (AAA ≥7) sobre o fundo', () {
    expect(
      _contrast(ThemeColors.background, ThemeColors.textPrimary),
      greaterThanOrEqualTo(7),
    );
  });

  test('texto secundário é legível (AA ≥4.5) sobre o branco (surface)', () {
    expect(
      _contrast(ThemeColors.white, ThemeColors.textSecondary),
      greaterThanOrEqualTo(4.5),
    );
  });

  test('onPrimary (creme) é mais claro que primary (destaque estético)', () {
    expect(
      _luminance(ThemeColors.onPrimary),
      greaterThan(_luminance(ThemeColors.primary)),
    );
  });

  test('navigationInactive alcança AA (≥4.5) sobre primary', () {
    expect(
      _contrast(ThemeColors.primary, ThemeColors.navigationInactive),
      greaterThanOrEqualTo(4.5),
    );
  });

  test('navigationActive é mais claro que a barra (item ativo distinto)', () {
    expect(
      _luminance(ThemeColors.navigationActive),
      greaterThan(_luminance(ThemeColors.primary)),
    );
  });

  test('onColor escolhe escuro em fundo claro e branco em fundo escuro', () {
    // Sobre a primária, onColor devolve o creme (destaque estético).
    expect(ThemeColors.onColor(ThemeColors.primary), ThemeColors.onPrimary);
    expect(
      _luminance(ThemeColors.onColor(ThemeColors.primary)),
      greaterThan(_luminance(ThemeColors.primary)),
    );
    expect(ThemeColors.onColor(ThemeColors.secondary), Colors.white);
    expect(ThemeColors.onColor(ThemeColors.background), ThemeColors.textPrimary);

    final onSuccess = ThemeColors.onColor(ThemeColors.success);
    expect(_contrast(ThemeColors.success, onSuccess), greaterThanOrEqualTo(4.5));
    expect(onSuccess, isNot(Colors.white));

    expect(
      onSuccess,
      ThemeColors.textPrimary,
      reason: 'O verde do success é claro o suficiente para o texto escuro (azul-marinho) passar em AA.',
    );
  });
}