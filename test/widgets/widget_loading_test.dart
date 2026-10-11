import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:appets/widgets/feedback/widget_loading.dart';

void main() {
  //459
  testWidgets('exibe as patinhas de carregamento', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: WGLoading())),
    );

    expect(find.byType(WGLoading), findsOneWidget);
    expect(find.byIcon(Icons.pets), findsNWidgets(4));
  });

  //460
  testWidgets('anuncia "Carregando" como região viva (a11y)', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: WGLoading())),
    );

    expect(tester.getSemantics(find.byType(WGLoading)).label, 'Carregando');

    handle.dispose();
  });

  //461
  testWidgets('mantém o pulso da animação rodando', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: WGLoading())),
    );

    expect(tester.hasRunningAnimations, isTrue);
  });
}