import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:appets/widgets/fields/widget_editable_tile.dart';
import 'package:appets/widgets/fields/widget_phone_field.dart';

void main() {
  group('WGPhoneField', () {
    testWidgets('aplica máscara (XX) XXXXX-XXXX ao digitar', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WGPhoneField(controller: controller, hintText: 'Telefone'),
          ),
        ),
      );

      await tester.enterText(find.byType(WGPhoneField), '11987654321');

      expect(controller.text, '(11) 98765-4321');

      controller.dispose();
    });
  });

  group('WGEditableTile', () {
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
                return WGEditableTile(
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

    testWidgets('exibe o valor commitado fora do modo edição', (tester) async {
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

    testWidgets('leading: substitui o ícone pela imagem fornecida', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: WGEditableTile(
                icon: Icons.email_outlined,
                title: 'E-mail',
                initialValue: 'Valor original',
                committedValue: 'a@test.com',
                onCommit: (_) {},
                onStartEditing: () {},
                isEditing: false,
                leading: Image(
                  image: AssetImage('assets/logos/google_logo.png'),
                  width: 28,
                  height: 28,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(Image), findsOneWidget);
      expect(find.byIcon(Icons.email_outlined), findsNothing);
    });

    testWidgets('primary: fica mais alto que o normal', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  WGEditableTile(
                    icon: Icons.person_outline,
                    title: 'Nome',
                    initialValue: 'Valor original',
                    committedValue: 'a@test.com',
                    onCommit: (_) {},
                    onStartEditing: () {},
                    isEditing: false,
                    primary: true,
                  ),
                  const SizedBox(height: 8),
                  WGEditableTile(
                    icon: Icons.person_outline,
                    title: 'Nome',
                    initialValue: 'Valor original',
                    committedValue: 'Ana',
                    onCommit: (_) {},
                    onStartEditing: () {},
                    isEditing: false,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Moldura maior que a do tile comum (destaque de importância).
      final primaryTileFinder = find
          .ancestor(
            of: find.text('a@test.com'),
            matching: find.byType(WGEditableTile),
          )
          .first;
      final normalTileFinder = find
          .ancestor(
            of: find.text('Ana'),
            matching: find.byType(WGEditableTile),
          )
          .first;
      expect(
        tester.getSize(primaryTileFinder).height,
        greaterThan(tester.getSize(normalTileFinder).height),
      );
    });

    testWidgets('blocked (enabled false) nao abre edicao e mostra cadeado', (
      tester,
    ) async {
      var editing = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return WGEditableTile(
                  icon: Icons.email_outlined,
                  title: 'E-mail',
                  initialValue: 'a@test.com',
                  committedValue: 'a@test.com',
                  onCommit: (_) {},
                  onStartEditing: () => setState(() => editing = true),
                  isEditing: editing,
                  enabled: false,
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('a@test.com'));
      await tester.pumpAndSettle();

      expect(editing, isFalse);
      expect(find.byType(TextFormField), findsNothing);
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
      expect(tester.widget<Icon>(find.byIcon(Icons.lock_outline)).size, 34);
    });

    testWidgets('entra em edição e devolve o valor via onCommit', (
      tester,
    ) async {
      String? committed;

      var editing = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: StatefulBuilder(
                builder: (context, setState) {
                  return WGEditableTile(
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
