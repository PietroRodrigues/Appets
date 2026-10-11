import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:appets/widgets/display/widget_logo.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('exibe a imagem do logo institucional', (tester) async {
    await tester.pumpWidget(wrap(const WGLogo()));

    expect(find.byType(WGLogo), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('logo expõe o rótulo "APPets" na árvore semântica (a11y)',
      (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(wrap(const WGLogo()));

    expect(tester.getSemantics(find.byType(WGLogo)).label, 'APPets');

    handle.dispose();
  });
}