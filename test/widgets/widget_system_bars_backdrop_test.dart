import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/widgets/system/widget_system_bars_backdrop.dart';

void main() {
  Widget build({
    EdgeInsets padding = const EdgeInsets.only(top: 40, bottom: 24),
  }) {
    return MaterialApp(
      home: MediaQuery(
        data: const MediaQueryData().copyWith(padding: padding),
        child: const Scaffold(
          body: SystemBarsBackdrop(child: Text('conteúdo')),
        ),
      ),
    );
  }

  testWidgets('mantém o conteúdo e pinta a faixa da barra de status',
      (tester) async {
    await tester.pumpWidget(build());

    expect(find.text('conteúdo'), findsOneWidget);
    final backdrop = tester.widget<Container>(
      find.byKey(statusBarBackdropKey),
    );
    expect(backdrop.color, ThemeColors.statusBar);
  });

  testWidgets('ocupa exatamente a altura da barra de status', (tester) async {
    await tester.pumpWidget(build(padding: const EdgeInsets.only(top: 32)));

    final container = find.byKey(statusBarBackdropKey);
    final rect = tester.getRect(container);
    expect(rect.top, 0);
    expect(rect.height, 32);
    expect(rect.left, 0);
  });

  testWidgets('não pinta a faixa quando não há inset superior', (tester) async {
    await tester.pumpWidget(
      build(padding: const EdgeInsets.only(bottom: 24)),
    );

    expect(find.text('conteúdo'), findsOneWidget);
    expect(find.byKey(statusBarBackdropKey), findsNothing);
  });

  testWidgets('pinta a faixa da barra de navegação na mesma cor',
      (tester) async {
    await tester.pumpWidget(build());

    final backdrop = tester.widget<Container>(
      find.byKey(systemNavBarBackdropKey),
    );
    expect(backdrop.color, ThemeColors.statusBar);
  });

  testWidgets('faixa da barra de navegação ocupa a base na altura do inset',
      (tester) async {
    await tester.pumpWidget(build(padding: const EdgeInsets.only(bottom: 16)));

    final rect = tester.getRect(find.byKey(systemNavBarBackdropKey));
    expect(rect.height, 16);
    expect(rect.left, 0);
  });

  testWidgets('não pinta a faixa quando não há inset inferior', (tester) async {
    await tester.pumpWidget(
      build(padding: const EdgeInsets.only(top: 40)),
    );

    expect(find.text('conteúdo'), findsOneWidget);
    expect(find.byKey(systemNavBarBackdropKey), findsNothing);
  });
}