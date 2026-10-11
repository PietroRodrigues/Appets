import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:appets/core/theme/app_colors.dart';
import 'package:appets/core/theme/theme_app.dart';

void main() {
  group('AppTheme.lightTheme', () {
    //113
    test('carrega a paleta clara e o fundo correspondente', () {
      expect(
        AppTheme.lightTheme.extension<AppColors>(),
        AppColors.light,
      );
      expect(
        AppTheme.lightTheme.scaffoldBackgroundColor,
        AppColors.light.background,
      );
      expect(AppTheme.lightTheme.brightness, Brightness.light);
    });
  });

  //114
  testWidgets('o tema do app resolve a paleta clara', (tester) async {
    AppColors? resolved;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Builder(
          builder: (context) {
            resolved = Theme.of(context).extension<AppColors>();
            return const SizedBox.shrink();
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(resolved, AppColors.light);
  });
}