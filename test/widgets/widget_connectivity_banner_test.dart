import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:appets/core/services/connectivity_service.dart';
import 'package:appets/widgets/feedback/widget_connectivity_banner.dart';

void main() {
  final connectivity = ConnectivityService.instance;
  final stripKey = const ValueKey<String>('connectivity_strip');

  setUp(() => connectivity.reset());

  tearDown(() => connectivity.reset());

  Future<void> pumpBanner(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ConnectivityBanner(child: const Scaffold(body: Text('app'))),
      ),
    );
  }

  testWidgets('inicia offline e mostra a faixa colorida', (tester) async {
    connectivity.debugOnline = false;

    await pumpBanner(tester);

    expect(find.byKey(stripKey), findsOneWidget);
  });

  testWidgets('inicia online e não mostra a faixa', (tester) async {
    connectivity.debugOnline = true;

    await pumpBanner(tester);

    expect(find.byKey(stripKey), findsNothing);
  });

  testWidgets(
    'reconecta: mostra a faixa e recolhe após o tempo',
    (tester) async {
      connectivity.debugOnline = false;
      await pumpBanner(tester);
      expect(find.byKey(stripKey), findsOneWidget);

      connectivity.debugOnline = true;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byKey(stripKey), findsOneWidget);

      await tester.pump(const Duration(seconds: 3));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byKey(stripKey), findsNothing);
    },
  );
}