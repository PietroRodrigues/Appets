import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:appets/core/theme/app_colors.dart';

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

void _expectAccessible(AppColors colors) {
  test('texto principal é legível (AAA ≥7) sobre o fundo', () {
    expect(
      _contrast(colors.background, colors.textPrimary),
      greaterThanOrEqualTo(7),
    );
  });

  test('texto secundário é legível (AA ≥4.5) sobre a surface', () {
    expect(
      _contrast(colors.surface, colors.textSecondary),
      greaterThanOrEqualTo(4.5),
    );
  });

  test('onPrimary (creme) é mais claro que primary (destaque estético)', () {
    expect(
      _luminance(colors.onPrimary),
      greaterThan(_luminance(colors.primary)),
    );
  });

  test('navigationInactive alcança AA (≥4.5) sobre primary', () {
    expect(
      _contrast(colors.primary, colors.navigationInactive),
      greaterThanOrEqualTo(4.5),
    );
  });

  test('navigationActive é mais claro que a barra (item ativo distinto)', () {
    expect(
      _luminance(colors.navigationActive),
      greaterThan(_luminance(colors.primary)),
    );
  });

  test('onColor escolhe a cor de maior contraste para o fundo', () {
    // Sobre a primária, onColor devolve o creme (destaque estético).
    expect(colors.onColor(colors.primary), colors.onPrimary);
    expect(
      _luminance(colors.onColor(colors.primary)),
      greaterThan(_luminance(colors.primary)),
    );

    // Sobre o fundo do scaffold, o texto principal contrasta.
    expect(colors.onColor(colors.background), colors.textPrimary);

    // Sobre o verde de sucesso, o resultado passa em AA.
    final onSuccess = colors.onColor(colors.success);
    expect(_contrast(colors.success, onSuccess), greaterThanOrEqualTo(4.5));
  });
}

void main() {
  group('AppColors.light', () {
    _expectAccessible(AppColors.light);

    test('onColor sobre a secundária devolve branco', () {
      expect(AppColors.light.onColor(AppColors.light.secondary), Colors.white);
    });

    test('onColor sobre success usa texto escuro (verde é claro)', () {
      expect(AppColors.light.onColor(AppColors.light.success), isNot(Colors.white));
      expect(
        AppColors.light.onColor(AppColors.light.success),
        AppColors.light.textPrimary,
        reason: 'O verde claro pede o texto escuro da paleta.',
      );
    });
  });

  test('copyWith preserva os demais campos', () {
    final copy = AppColors.light.copyWith(primary: const Color(0xFF123456));
    expect(copy.primary, const Color(0xFF123456));
    expect(copy.background, AppColors.light.background);
  });

  test('lerp mistura variantes da paleta clara', () {
    final other = AppColors.light.copyWith(primary: const Color(0xFF123456));
    final half = AppColors.light.lerp(other, 0.5);
    expect(
      half.primary,
      Color.lerp(AppColors.light.primary, other.primary, 0.5),
    );
    expect(half.background, AppColors.light.background);
  });

  testWidgets('AppColors.of cai na paleta clara sem tema do app', (tester) async {
    late AppColors resolved;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            resolved = AppColors.of(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(resolved, AppColors.light);
  });
}