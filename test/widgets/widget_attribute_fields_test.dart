import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:appets/core/constants/constants_strings_publish.dart';
import 'package:appets/models/enums/enums_app.dart';
import 'package:appets/widgets/publish/widget_attribute_fields.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  group('WGAgeFields', () {
    //391
    testWidgets('mostra a idade e a unidade iniciais', (tester) async {
      await tester.pumpWidget(
        wrap(const WGAgeFields(initialValue: 2, initialUnit: AppPetAgeUnit.years)),
      );

      expect(find.text('2'), findsOneWidget);
      expect(find.text(AppPetAgeUnit.years.label), findsOneWidget);
    });

    //392
    testWidgets('notifica onChanged ao escolher um valor', (tester) async {
      int? value;
      AppPetAgeUnit? unit;
      await tester.pumpWidget(
        wrap(
          WGAgeFields(
            initialUnit: AppPetAgeUnit.months,
            onChanged: (v, u) {
              value = v;
              unit = u;
            },
          ),
        ),
      );

      await tester.tap(find.byType(DropdownButtonFormField<int>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('5').last);
      await tester.pumpAndSettle();

      expect(value, 5);
      expect(unit, AppPetAgeUnit.months);
    });

    //393
    testWidgets('ao trocar a unidade, limita o valor ao novo máximo',
        (tester) async {
      int? value;
      AppPetAgeUnit? unit;
      await tester.pumpWidget(
        wrap(
          WGAgeFields(
            initialValue: 50,
            initialUnit: AppPetAgeUnit.years,
            onChanged: (v, u) {
              value = v;
              unit = u;
            },
          ),
        ),
      );

      // 50 anos > 11 meses: ao virar "meses" o valor é reduzido para 11.
      await tester.tap(find.byType(DropdownButtonFormField<AppPetAgeUnit>));
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppPetAgeUnit.months.label).last);
      await tester.pumpAndSettle();

      expect(unit, AppPetAgeUnit.months);
      expect(value, 11);
      expect(find.text('11'), findsOneWidget);
    });

    //394
    testWidgets('valida a idade obrigatória', (tester) async {
      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(
        wrap(
          Form(
            key: formKey,
            child: const WGAgeFields(),
          ),
        ),
      );

      expect(formKey.currentState!.validate(), isFalse);
      await tester.pump();

      expect(find.text(PublishStrings.AGE_REQUIRED), findsOneWidget);
    });
  });

  group('WGGenderFields', () {
    //395
    testWidgets('exibe as opções Macho e Fêmea', (tester) async {
      await tester.pumpWidget(
        wrap(WGGenderFields(onChanged: (_) {})),
      );

      expect(find.text(AppPetGender.male.label), findsOneWidget);
      expect(find.text(AppPetGender.female.label), findsOneWidget);
    });

    //396
    testWidgets('notifica o gênero selecionado', (tester) async {
      AppPetGender? selected;
      await tester.pumpWidget(
        wrap(WGGenderFields(onChanged: (gender) => selected = gender)),
      );

      await tester.tap(find.text(AppPetGender.female.label));
      await tester.pump();

      expect(selected, AppPetGender.female);
    });
  });
}
