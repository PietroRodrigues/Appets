import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/widgets/feedback/widget_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget harness() => const MaterialApp(home: Scaffold(body: SizedBox()));

  group('WGSnackBar', () {
    testWidgets('showError exibe a mensagem de erro', (tester) async {
      await tester.pumpWidget(harness());

      WGSnackBar.showError(
        tester.element(find.byType(Scaffold)),
        'Não foi possível favoritar. Tente novamente.',
      );
      await tester.pump();

      expect(
        find.text('Não foi possível favoritar. Tente novamente.'),
        findsOneWidget,
      );

      // Drena o timer do SnackBar para não deixar pendente.
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
    });

    testWidgets('showSuccess exibe a mensagem de sucesso', (tester) async {
      await tester.pumpWidget(harness());

      WGSnackBar.showSuccess(tester.element(find.byType(Scaffold)), 'Salvo!');
      await tester.pump();

      expect(find.text('Salvo!'), findsOneWidget);

      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
    });

    testWidgets('nova chamada não empilha avisos anteriores', (tester) async {
      await tester.pumpWidget(harness());

      WGSnackBar.showError(tester.element(find.byType(Scaffold)), 'Primeiro');
      await tester.pump();
      WGSnackBar.showError(tester.element(find.byType(Scaffold)), 'Segundo');
      await tester.pump();

      expect(find.text('Primeiro'), findsNothing);
      expect(find.text('Segundo'), findsOneWidget);

      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
    });

    testWidgets('usa o fundo da cor do tipo', (tester) async {
      await tester.pumpWidget(harness());

      WGSnackBar.showError(tester.element(find.byType(Scaffold)), 'Erro');
      await tester.pump();

      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.backgroundColor, ThemeColors.error);

      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
    });
  });
}