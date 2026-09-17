import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:appets/widgets/display/widget_info_row.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  testWidgets('endereço longo quebra em linhas sem overflow', (tester) async {
    const longAddress =
        'Rua Marquês de São Vicente, 2534 - Vila Olímpia, '
        'São Paulo - SP, Brasil';

    await tester.pumpWidget(
      wrap(
        Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 180,
            child: WGInfoRow(
              icon: Icons.location_on_outlined,
              text: longAddress,
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.byIcon(Icons.location_on_outlined), findsOneWidget);
    expect(find.text(longAddress), findsOneWidget);
    expect(tester.getSize(find.byType(WGInfoRow)).height,
        greaterThan(20));
  });

  testWidgets('texto curto continua em linha única', (tester) async {
    await tester.pumpWidget(
      wrap(
        Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 180,
            child: WGInfoRow(icon: Icons.cake_outlined, text: '2 anos'),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('2 anos'), findsOneWidget);
    expect(tester.getSize(find.byType(WGInfoRow)).height, lessThan(30));
  });
}