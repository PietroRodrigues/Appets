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
  test('primary NÃO alcança AA com branco (pendência do item 28)', () {
    expect(_contrast(ThemeColors.primary, ThemeColors.white), lessThan(4.5));
  });
}