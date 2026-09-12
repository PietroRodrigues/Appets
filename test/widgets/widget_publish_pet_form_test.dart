import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/models/enums/enums_app.dart';
import 'package:appets/models/model_pet.dart';
import 'package:appets/widgets/publish/widget_publish_pet_form.dart';

void main() {
  group('WGPublishPetForm', () {
    Widget createTestWidget() {
      return const MaterialApp(home: Scaffold(body: WGPublishPetForm()));
    }

    // Lê a cor de fundo do botão "Publicar Pet".
    Color? publishButtonColor(WidgetTester tester) {
      final button = tester.widget<ElevatedButton>(
        find.ancestor(
          of: find.text('Publicar Pet'),
          matching: find.byType(ElevatedButton),
        ),
      );
      return button.style?.backgroundColor?.resolve(<WidgetState>{});
    }

    testWidgets('exibe todos os campos do formulário', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Verifica se os labels dos campos estão presentes.
      expect(find.text('Tipo de publicação'), findsOneWidget);
      expect(find.text('Nome do pet'), findsOneWidget);
      expect(find.text('Idade'), findsOneWidget);
      expect(find.text('Gênero'), findsOneWidget);
      expect(find.text('Telefone'), findsOneWidget);
      expect(find.text('Endereço'), findsOneWidget);
      expect(find.text('Sobre o pet'), findsOneWidget);
      expect(find.text('Fotos do pet'), findsOneWidget);
    });

    testWidgets('exibe botão de publicar', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Publicar Pet'), findsOneWidget);
    });

    testWidgets('campo nome aceita texto', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final nameField = find.widgetWithText(
        TextFormField,
        'Digite o nome do pet',
      );
      expect(nameField, findsOneWidget);

      await tester.enterText(nameField, 'Rex');
      expect(find.text('Rex'), findsOneWidget);
    });

    testWidgets('campo endereço aceita texto', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final addressField = find.widgetWithText(
        TextFormField,
        'Digite o endereço',
      );
      expect(addressField, findsOneWidget);

      await tester.enterText(addressField, 'São Paulo');
      expect(find.text('São Paulo'), findsOneWidget);
    });

    testWidgets('campo descrição aceita texto', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final descField = find.widgetWithText(
        TextFormField,
        'Conte um pouco sobre o pet',
      );
      expect(descField, findsOneWidget);

      await tester.enterText(descField, '描述 um pet muito bom');
      expect(find.text('描述 um pet muito bom'), findsOneWidget);
    });

    testWidgets('botão de publicar começa cinza (formulário incompleto)', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      expect(publishButtonColor(tester), ThemeColors.disabled);
    });

    testWidgets('botão fica verde quando o formulário está completo e o '
        '"Sobre o pet" vazio não bloqueia', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Nome válido.
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Digite o nome do pet'),
        'Rex',
      );
      // Celular válido (máscara aplicada com 11 dígitos).
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Ex.: (11) 98765-4321'),
        '11987654321',
      );
      // Endereço preenchido.
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Digite o endereço'),
        'São Paulo',
      );
      await tester.pump();

      expect(publishButtonColor(tester), ThemeColors.success);
    });

    testWidgets('botão continua cinza com celular inválido (fixo/10 dígitos)', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Digite o nome do pet'),
        'Rex',
      );
      // 10 dígitos (fixo) é inválido; a máscara mostra (11) 8765-4321.
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Ex.: (11) 98765-4321'),
        '1187654321',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Digite o endereço'),
        'São Paulo',
      );
      await tester.pump();

      expect(publishButtonColor(tester), ThemeColors.disabled);
    });
  });

  group('WGPublishPetForm em modo edição', () {
    Pet createEditPet() {
      return Pet(
        id: 'pet_001',
        ownerId: 'user_001',
        name: 'Rex',
        age: 2,
        ageUnit: AppPetAgeUnit.years,
        gender: AppPetGender.male,
        address: 'São Paulo',
        ownerPhone: '(11) 98765-4321',
        ownerAddress: 'São Paulo',
        description: 'Muito dócil.',
        publicationType: AppPetPublicationType.lost,
        species: AppPetSpecies.dog,
        race: 'Poodle',
        images: ['a.png'],
      );
    }

    Widget createEditWidget() {
      return MaterialApp(
        home: Scaffold(body: WGPublishPetForm(pet: createEditPet())),
      );
    }

    testWidgets('exibe botão "Salvar Alterações" em vez de "Publicar Pet"', (
      tester,
    ) async {
      await tester.pumpWidget(createEditWidget());

      expect(find.text('Salvar Alterações'), findsOneWidget);
      expect(find.text('Publicar Pet'), findsNothing);
    });

    testWidgets('pré-preenche os campos com os dados do pet', (tester) async {
      await tester.pumpWidget(createEditWidget());

      expect(find.text('Rex'), findsWidgets);
      expect(find.text('Poodle'), findsWidgets);
      expect(find.text('Muito dócil.'), findsWidgets);
      expect(find.text('Perdido'), findsWidgets);
      expect(find.text('Cachorro'), findsWidgets);
      // Telefone com a máscara aplicada.
      expect(find.text('(11) 98765-4321'), findsWidgets);
    });

    testWidgets('botão "Salvar Alterações" começa verde (formulário válido)', (
      tester,
    ) async {
      await tester.pumpWidget(createEditWidget());

      final button = tester.widget<ElevatedButton>(
        find.ancestor(
          of: find.text('Salvar Alterações'),
          matching: find.byType(ElevatedButton),
        ),
      );
      final color = button.style?.backgroundColor?.resolve(<WidgetState>{});
      expect(color, ThemeColors.success);
    });
  });
}
