import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:appets/widgets/filters/widget_filter_chips_bar.dart';
import 'package:appets/widgets/filters/widget_pet_filters_sheet.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  group('WGPetFiltersDialog', () {
    // Abre o popover (ancorado no próprio botão) e entrega o resultado.
    Future<void> openDialog(
      WidgetTester tester, {
      required void Function(List<PetFilterOption>?) onResult,
      List<PetFilterOption> initialOptions = const [],
      bool disableAnimations = false,
    }) async {
      final button = Center(
        child: Builder(
          // Âncora = o próprio botão (contexto do Builder).
          builder: (buttonContext) => ElevatedButton(
            onPressed: () async {
              onResult(
                await WGPetFiltersDialog.show(
                  buttonContext,
                  initialOptions: initialOptions,
                ),
              );
            },
            child: const Text('abrir'),
          ),
        ),
      );

      await tester.pumpWidget(
        disableAnimations
            ? MediaQuery(
                data: const MediaQueryData(
                  size: Size(800, 600),
                  devicePixelRatio: 1.0,
                  disableAnimations: true,
                ),
                child: wrap(button),
              )
            : wrap(button),
      );
      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();
    }

    // Fecha o popover tocando longe dele (equivale ao usuário fechar).
    Future<void> closeOutside(WidgetTester tester) async {
      await tester.tapAt(const Offset(10, 500));
      await tester.pumpAndSettle();
    }

    WGFilterOptionTile tileFor(WidgetTester tester, String label) =>
        tester.widget<WGFilterOptionTile>(
          find.widgetWithText(WGFilterOptionTile, label),
        );

    testWidgets('exibe as categorias com opções', (tester) async {
      final handle = tester.ensureSemantics();
      await openDialog(tester, onResult: (_) {});

      expect(find.bySemanticsLabel('Limpar tudo'), findsWidgets);
      expect(find.bySemanticsLabel('Espécie'), findsOneWidget);
      expect(find.text('Limpar tudo'), findsOneWidget);
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

      handle.dispose();
    });

    testWidgets('linhas de opção têm alvo de toque ≥ 48px', (tester) async {
      await openDialog(tester, onResult: (_) {});

      final size = tester.getSize(
        find.widgetWithText(WGFilterOptionTile, 'Cachorro'),
      );

      expect(size.height, greaterThanOrEqualTo(48));
    });

    testWidgets('X fecha e aplica a seleção (igual a tocar fora)',
        (tester) async {
      List<PetFilterOption>? result;
      await openDialog(tester, onResult: (options) => result = options);

      await tester.tap(find.widgetWithText(WGFilterOptionTile, 'Gato'));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      expect(result, hasLength(1));
      expect(result!.single.id, 'species:gato');
      expect(find.text('Espécie'), findsNothing);
    });

    testWidgets('reduced motion: reduzir animações abre e interage (smoke)',
        (tester) async {
      List<PetFilterOption>? result;
      await openDialog(
        tester,
        onResult: (options) => result = options,
        disableAnimations: true,
      );

      expect(find.text('Espécie'), findsOneWidget);

      await tester.tap(find.widgetWithText(WGFilterOptionTile, 'Gato'));
      await tester.pump();
      await closeOutside(tester);

      expect(result, hasLength(1));
      expect(result!.single.id, 'species:gato');
    });

    testWidgets('fechar tocando fora aplica as opções marcadas',
        (tester) async {
      List<PetFilterOption>? result;
      await openDialog(tester, onResult: (options) => result = options);

      await tester.tap(find.widgetWithText(WGFilterOptionTile, 'Cachorro'));
      await tester.scrollUntilVisible(
        find.widgetWithText(WGFilterOptionTile, 'Macho'),
        120,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.widgetWithText(WGFilterOptionTile, 'Macho'));
      await tester.pump();

      await closeOutside(tester);

      expect(result, hasLength(2));
      expect(result![0].id, 'species:cachorro');
      expect(result![1].id, 'gender:macho');
      expect(find.text('Espécie'), findsNothing);
    });

    testWidgets('tocar fora do popover fecha e aplica o que está marcado',
        (tester) async {
      List<PetFilterOption>? result;
      await openDialog(tester, onResult: (options) => result = options);

      await tester.tap(find.widgetWithText(WGFilterOptionTile, 'Gato'));
      await tester.pump();
      await closeOutside(tester);

      expect(result, hasLength(1));
      expect(result!.single.id, 'species:gato');
      expect(find.text('Espécie'), findsNothing);
    });

    testWidgets('barreira (outro ponto fora) aplica a seleção atual',
        (tester) async {
      List<PetFilterOption>? result;
      await openDialog(tester, onResult: (options) => result = options);

      await tester.tap(find.widgetWithText(WGFilterOptionTile, 'Gato'));
      await tester.pump();

      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(result, hasLength(1));
      expect(result!.single.id, 'species:gato');
      expect(find.text('Espécie'), findsNothing);
    });

    testWidgets('abrir com pré-aplicados e desmarcar um mantém o resto',
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

      await openDialog(
        tester,
        onResult: (options) => result = options,
        initialOptions: applied,
      );

      // Desmarca apenas "Macho".
      await tester.scrollUntilVisible(
        find.widgetWithText(WGFilterOptionTile, 'Macho'),
        120,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.widgetWithText(WGFilterOptionTile, 'Macho'));
      await tester.pump();
      await closeOutside(tester);

      expect(result, hasLength(1));
      expect(result!.single.id, 'age:adulto');
    });

    testWidgets('desmarcar todos e fechar devolve lista vazia', (tester) async {
      List<PetFilterOption>? result;
      const applied = [
        PetFilterOption(
          category: PetFilterCategory.gender,
          value: 'macho',
          label: 'Macho',
        ),
      ];

      await openDialog(
        tester,
        onResult: (options) => result = options,
        initialOptions: applied,
      );

      await tester.scrollUntilVisible(
        find.widgetWithText(WGFilterOptionTile, 'Macho'),
        120,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.widgetWithText(WGFilterOptionTile, 'Macho'));
      await tester.pump();
      await closeOutside(tester);

      expect(result, isNotNull);
      expect(result, isEmpty);
    });

    testWidgets('reaplica filtros já aplicados como marcados ao abrir',
        (tester) async {
      List<PetFilterOption>? result;
      const applied = [
        PetFilterOption(
          category: PetFilterCategory.gender,
          value: 'macho',
          label: 'Macho',
        ),
        PetFilterOption(
          category: PetFilterCategory.age,
          value: 'adulto',
          label: 'Adulto',
        ),
      ];

      await openDialog(
        tester,
        onResult: (options) => result = options,
        initialOptions: applied,
      );

      expect(tileFor(tester, 'Macho').value, isTrue);
      expect(tileFor(tester, 'Adulto').value, isTrue);
      expect(tileFor(tester, 'Gato').value, isFalse);
      expect(tileFor(tester, 'Fêmea').value, isFalse);

      // Fechar sem mexer devolve o que veio marcado.
      await closeOutside(tester);

      expect(result, hasLength(2));
      expect(result![0].id, 'gender:macho');
      expect(result![1].id, 'age:adulto');
    });

    testWidgets('Limpar tudo desmarca e fechar aplica vazio', (tester) async {
      List<PetFilterOption>? result;
      const applied = [
        PetFilterOption(
          category: PetFilterCategory.gender,
          value: 'macho',
          label: 'Macho',
        ),
        PetFilterOption(
          category: PetFilterCategory.age,
          value: 'adulto',
          label: 'Adulto',
        ),
      ];

      await openDialog(
        tester,
        onResult: (options) => result = options,
        initialOptions: applied,
      );

      expect(tileFor(tester, 'Macho').value, isTrue);
      expect(tileFor(tester, 'Adulto').value, isTrue);

      // Limpar tudo desmarca e mantém o popover aberto.
      await tester.tap(find.text('Limpar tudo'));
      await tester.pump();

      expect(find.text('Espécie'), findsOneWidget);
      expect(tileFor(tester, 'Macho').value, isFalse);
      expect(tileFor(tester, 'Adulto').value, isFalse);

      // Fechar após limpar devolve lista vazia (remove os filtros).
      await closeOutside(tester);

      expect(result, isNotNull);
      expect(result, isEmpty);
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