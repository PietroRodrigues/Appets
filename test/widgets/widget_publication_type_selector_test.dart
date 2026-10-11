import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:appets/core/theme/app_colors.dart';
import 'package:appets/models/enums/enums_app.dart';
import 'package:appets/widgets/publish/widget_publication_type_selector.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  ChoiceChip chipFor(WidgetTester tester, String label) {
    return tester.widget<ChoiceChip>(
      find.ancestor(of: find.text(label), matching: find.byType(ChoiceChip)),
    );
  }

  testWidgets('renderiza um chip por tipo de publicação', (tester) async {
    await tester.pumpWidget(
      wrap(
        WGPublicationTypeSelector(
          selectedType: AppPetPublicationType.adoption,
          onChanged: (_) {},
        ),
      ),
    );

    expect(
      find.byType(WGOptionChip),
      findsNWidgets(AppPetPublicationType.values.length),
    );
    for (final type in AppPetPublicationType.values) {
      expect(find.text(type.label), findsOneWidget);
    }
  });

  testWidgets('marca apenas o chip do tipo selecionado', (tester) async {
    await tester.pumpWidget(
      wrap(
        WGPublicationTypeSelector(
          selectedType: AppPetPublicationType.lost,
          onChanged: (_) {},
        ),
      ),
    );

    expect(chipFor(tester, AppPetPublicationType.lost.label).selected, isTrue);
    expect(
      chipFor(tester, AppPetPublicationType.adoption.label).selected,
      isFalse,
    );
  });

  testWidgets('tocar em um chip devolve o tipo escolhido', (tester) async {
    AppPetPublicationType? picked;
    await tester.pumpWidget(
      wrap(
        WGPublicationTypeSelector(
          selectedType: AppPetPublicationType.adoption,
          onChanged: (type) => picked = type,
        ),
      ),
    );

    await tester.tap(find.text(AppPetPublicationType.lost.label));

    expect(picked, AppPetPublicationType.lost);
  });

  group('WGOptionChip', () {
    testWidgets('sem accentColor usa a cor primária sólida quando selecionado', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          WGOptionChip(label: 'Sólido', isSelected: true, onSelected: () {}),
        ),
      );

      final chip = tester.widget<ChoiceChip>(find.byType(ChoiceChip));
      expect(chip.selectedColor, AppColors.light.primary);
    });

    testWidgets('com accentColor usa a cor suave (alpha 0.15)', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          WGOptionChip(
            label: 'Suave',
            isSelected: true,
            accentColor: AppColors.light.error,
            onSelected: () {},
          ),
        ),
      );

      final chip = tester.widget<ChoiceChip>(find.byType(ChoiceChip));
      expect(
        chip.selectedColor,
        AppColors.light.error.withValues(alpha: 0.15),
      );
    });

    testWidgets('dispara onSelected no toque', (tester) async {
      var selected = false;
      await tester.pumpWidget(
        wrap(
          WGOptionChip(
            label: 'Chip',
            isSelected: false,
            onSelected: () => selected = true,
          ),
        ),
      );

      await tester.tap(find.text('Chip'));
      expect(selected, isTrue);
    });
  });
}
