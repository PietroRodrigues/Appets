import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:appets/widgets/filters/widget_filter_chips_bar.dart';
import 'package:appets/widgets/filters/widget_pet_filters_sheet.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  group('WGPetFiltersDialog', () {
    // Abre a janela e devolve o resultado do show.
    Future<void> openDialog(
      WidgetTester tester, {
      required void Function(List<PetFilterOption>?) onResult,
    }) async {
      await tester.pumpWidget(
        wrap(
          Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () async {
                  onResult(await WGPetFiltersDialog.show(context));
                },
                child: const Text('abrir'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();
    }

    CheckboxListTile tileFor(WidgetTester tester, String label) =>
        tester.widget<CheckboxListTile>(
          find.widgetWithText(CheckboxListTile, label),
        );

    testWidgets('exibe as categorias com opções', (tester) async {
      await openDialog(tester, onResult: (_) {});

      expect(find.text('Filtros'), findsOneWidget);
      expect(find.text('Espécie'), findsOneWidget);
      expect(find.text('Cachorro'), findsOneWidget);
      expect(find.text('Gato'), findsOneWidget);
      expect(find.text('Gênero'), findsOneWidget);
      expect(find.text('Macho'), findsOneWidget);
      expect(find.text('Fêmea'), findsOneWidget);
      expect(find.text('Tipo'), findsOneWidget);
      expect(find.text('Adoção'), findsOneWidget);
      expect(find.text('Perdido'), findsOneWidget);
      expect(find.text('Idade'), findsOneWidget);
      expect(find.text('Filhote'), findsOneWidget);
      expect(find.text('Jovem'), findsOneWidget);
      expect(find.text('Adulto'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Filtrar'), findsOneWidget);
    });

    testWidgets('Filtrar devolve as opções marcadas', (tester) async {
      List<PetFilterOption>? result;
      await openDialog(tester, onResult: (options) => result = options);

      await tester.tap(find.widgetWithText(CheckboxListTile, 'Cachorro'));
      await tester.scrollUntilVisible(
        find.widgetWithText(CheckboxListTile, 'Macho'),
        120,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.widgetWithText(CheckboxListTile, 'Macho'));
      await tester.pump();

      await tester.tap(find.widgetWithText(FilledButton, 'Filtrar'));
      await tester.pumpAndSettle();

      expect(result, hasLength(2));
      expect(result![0].id, 'species:cachorro');
      expect(result![0].label, 'Cachorro');
      expect(result![1].id, 'gender:macho');
    });

    testWidgets('X fecha a janela descartando a seleção', (tester) async {
      List<PetFilterOption>? result;
      await openDialog(tester, onResult: (options) => result = options);

      await tester.tap(find.widgetWithText(CheckboxListTile, 'Gato'));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(result, isNull);
      expect(find.text('Filtros'), findsNothing);
    });

    testWidgets('aplicar filtros pré-marcados mantém os selecionados',
        (tester) async {
      List<PetFilterOption>? result;
      final applied = [
        const PetFilterOption(
          category: PetFilterCategory.gender,
          value: 'macho',
          label: 'Macho',
        ),
        const PetFilterOption(
          category: PetFilterCategory.age,
          value: 'adulto',
          label: 'Adulto',
        ),
      ];

      await tester.pumpWidget(
        wrap(
          Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () async {
                  result = await WGPetFiltersDialog.show(
                    context,
                    initialOptions: applied,
                  );
                },
                child: const Text('abrir'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();

      // Desmarca apenas "Macho".
      await tester.scrollUntilVisible(
        find.widgetWithText(CheckboxListTile, 'Macho'),
        120,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.widgetWithText(CheckboxListTile, 'Macho'));
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Filtrar'));
      await tester.pumpAndSettle();

      expect(result, hasLength(1));
      expect(result!.single.id, 'age:adulto');
    });

    testWidgets('desmarcar todos e aplicar devolve lista vazia',
        (tester) async {
      List<PetFilterOption>? result;
      final applied = [
        const PetFilterOption(
          category: PetFilterCategory.gender,
          value: 'macho',
          label: 'Macho',
        ),
      ];

      await tester.pumpWidget(
        wrap(
          Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () async {
                  result = await WGPetFiltersDialog.show(
                    context,
                    initialOptions: applied,
                  );
                },
                child: const Text('abrir'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.widgetWithText(CheckboxListTile, 'Macho'),
        120,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.widgetWithText(CheckboxListTile, 'Macho'));
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Filtrar'));
      await tester.pumpAndSettle();

      expect(result, isNotNull);
      expect(result, isEmpty);
    });

    testWidgets('reaplica filtros já aplicados como marcados ao abrir',
        (tester) async {
      List<PetFilterOption>? result;
      final applied = [
        const PetFilterOption(
          category: PetFilterCategory.gender,
          value: 'macho',
          label: 'Macho',
        ),
        const PetFilterOption(
          category: PetFilterCategory.age,
          value: 'adulto',
          label: 'Adulto',
        ),
      ];

      await tester.pumpWidget(
        wrap(
          Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () async {
                  result = await WGPetFiltersDialog.show(
                    context,
                    initialOptions: applied,
                  );
                },
                child: const Text('abrir'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();

      expect(tileFor(tester, 'Macho').value, isTrue);
      expect(tileFor(tester, 'Adulto').value, isTrue);
      expect(tileFor(tester, 'Gato').value, isFalse);
      expect(tileFor(tester, 'Fêmea').value, isFalse);

      await tester.tap(find.widgetWithText(FilledButton, 'Filtrar'));
      await tester.pumpAndSettle();

      expect(result, hasLength(2));
      expect(result![0].id, 'gender:macho');
      expect(result![1].id, 'age:adulto');
    });
  });

  group('WGFilterChipsBar', () {
    testWidgets('exibe os chips aplicados', (tester) async {
      await tester.pumpWidget(
        wrap(
          const WGFilterChipsBar(
            options: [
              PetFilterOption(
                category: PetFilterCategory.age,
                value: 'puppy',
                label: 'Filhote',
              ),
              PetFilterOption(
                category: PetFilterCategory.gender,
                value: 'male',
                label: 'Macho',
              ),
            ],
            onRemove: _noopRemove,
          ),
        ),
      );

      expect(find.text('Filhote'), findsOneWidget);
      expect(find.text('Macho'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsNWidgets(2));
    });

    testWidgets('tocar no X chama onRemove com o chip certo', (tester) async {
      final option = PetFilterOptions.ageOptions.first;
      PetFilterOption? removed;

      await tester.pumpWidget(
        wrap(
          WGFilterChipsBar(
            options: [option],
            onRemove: (o) => removed = o,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      expect(removed, same(option));
    });
  });
}

void _noopRemove(PetFilterOption _) {}