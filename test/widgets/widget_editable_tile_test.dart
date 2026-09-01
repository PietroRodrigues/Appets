import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:appets/widgets/common/fields/widget_editable_tile.dart';
import 'package:appets/widgets/common/fields/widget_fields.dart';

void main() {
  group('AppPhoneField', () {
    testWidgets('aplica máscara (XX) XXXXX-XXXX ao digitar', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppPhoneField(
              controller: controller,
              hintText: 'Telefone',
            ),
          ),
        ),
      );

      await tester.enterText(
        find.byType(AppPhoneField),
        '11987654321',
      );

      expect(controller.text, '(11) 98765-4321');

      controller.dispose();
    });
  });

  group('AppEditableTile', () {
    Widget buildTile({
      required bool isEditing,
      required String committedValue,
      required ValueChanged<String> onCommit,
      required VoidCallback onStartEditing,
      String? editingValue,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (context, setState) {
                return AppEditableTile(
                  icon: Icons.person_outline,
                  title: 'Nome',
                  initialValue: 'Valor original',
                  committedValue: committedValue,
                  onCommit: onCommit,
                  onStartEditing: onStartEditing,
                  isEditing: isEditing,
                );
              },
            ),
          ),
        ),
      );
    }

    testWidgets('exibe o valor commitado fora do modo edição',
        (tester) async {
      await tester.pumpWidget(
        buildTile(
          isEditing: false,
          committedValue: 'Rex',
          onCommit: (_) {},
          onStartEditing: () {},
        ),
      );

      expect(find.text('Nome'), findsOneWidget);
      expect(find.text('Rex'), findsOneWidget);
    });

    testWidgets('entra em edição e devolve o valor via onCommit',
        (tester) async {
      String? committed;

      var editing = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: StatefulBuilder(
                builder: (context, setState) {
                  return AppEditableTile(
                    icon: Icons.person_outline,
                    title: 'Nome',
                    initialValue: 'Rex',
                    committedValue: 'Rex',
                    onCommit: (v) {
                      committed = v;
                      setState(() => editing = false);
                    },
                    onStartEditing: () {
                      setState(() => editing = true);
                    },
                    isEditing: editing,
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Sem edição: clique chama onStartEditing.
      await tester.tap(find.text('Nome'));
      await tester.pumpAndSettle();

      // Em edição: campo de texto presente.
      expect(find.byType(TextFormField), findsOneWidget);

      // Digita novo valor e confirma (done).
      await tester.enterText(find.byType(TextFormField), 'Thor');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(committed, 'Thor');
    });
  });
}
