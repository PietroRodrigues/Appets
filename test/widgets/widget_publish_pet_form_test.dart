import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:appets/widgets/publish/widget_publish_pet_form.dart';

void main() {
  group('AppPublishPetForm', () {
    Widget createTestWidget() {
      return const MaterialApp(
        home: Scaffold(
          body: AppPublishPetForm(),
        ),
      );
    }

    testWidgets('exibe todos os campos do formulário', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Verifica se os labels dos campos estão presentes.
      expect(find.text('Tipo de publicação'), findsOneWidget);
      expect(find.text('Nome do pet'), findsOneWidget);
      expect(find.text('Idade'), findsOneWidget);
      expect(find.text('Gênero'), findsOneWidget);
      expect(find.text('Cidade'), findsOneWidget);
      expect(find.text('Sobre o pet'), findsOneWidget);
      expect(find.text('Fotos do pet'), findsOneWidget);
    });

    testWidgets('exibe botão de publicar', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Publicar Pet'), findsOneWidget);
    });

    testWidgets('campo nome aceita texto', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final nameField = find.widgetWithText(TextFormField, 'Digite o nome do pet');
      expect(nameField, findsOneWidget);

      await tester.enterText(nameField, 'Rex');
      expect(find.text('Rex'), findsOneWidget);
    });

    testWidgets('campo cidade aceita texto', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final cityField = find.widgetWithText(TextFormField, 'Digite a cidade');
      expect(cityField, findsOneWidget);

      await tester.enterText(cityField, 'São Paulo');
      expect(find.text('São Paulo'), findsOneWidget);
    });

    testWidgets('campo descrição aceita texto', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final descField = find.widgetWithText(TextFormField, 'Conte um pouco sobre o pet');
      expect(descField, findsOneWidget);

      await tester.enterText(descField, '描述 um pet muito bom');
      expect(find.text('描述 um pet muito bom'), findsOneWidget);
    });
  });
}
