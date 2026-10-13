import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:appets/core/constants/constants_strings_pet_details.dart';
import 'package:appets/core/constants/constants_strings_shared.dart';
import 'package:appets/models/enums/enums_app.dart';
import 'package:appets/models/model_pet.dart';
import 'package:appets/widgets/display/widget_info_row.dart';
import 'package:appets/widgets/pet/widget_pet_details_info.dart';

void main() {
  // Rolável para não estourar a altura padrão da tela de teste e para
  // permitir rolar até o botão de contato.
  Widget wrap(Widget child) => MaterialApp(
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );

  Pet buildPet({
    String? description = 'Muito dócil.',
    String race = '',
    double? weight,
    String ownerPhone = '(11) 98765-4321',
  }) {
    return Pet(
      id: 'pet_1',
      ownerId: 'owner_1',
      name: 'Rex',
      age: 2,
      gender: AppPetGender.male,
      address: 'São Paulo',
      ownerPhone: ownerPhone,
      description: description,
      race: race,
      weight: weight,
      images: const [],
    );
  }

  //493
  testWidgets('exibe os dados básicos do pet', (tester) async {
    await tester.pumpWidget(wrap(WGPetDetailsInfo(pet: buildPet())));

    expect(find.text('Rex'), findsOneWidget);
    expect(find.text('2 anos'), findsOneWidget);
    expect(find.text('Cachorro'), findsOneWidget);
    expect(find.text('Macho'), findsOneWidget);
    expect(find.text('São Paulo'), findsOneWidget);
    expect(find.text('Adoção'), findsOneWidget);
    expect(find.text('Muito dócil.'), findsOneWidget);
    expect(find.text(PetDetailsStrings.ABOUT_SECTION), findsOneWidget);
  });

  //494
  testWidgets('raça e peso aparecem só quando informados', (tester) async {
    // Sem raça nem peso: 5 linhas de informação.
    await tester.pumpWidget(wrap(WGPetDetailsInfo(pet: buildPet())));
    expect(find.byType(WGInfoRow), findsNWidgets(5));
    expect(find.textContaining('kg'), findsNothing);

    // Com raça e peso: 7 linhas.
    await tester.pumpWidget(
      wrap(
        WGPetDetailsInfo(pet: buildPet(race: 'Poodle', weight: 12.5)),
      ),
    );
    expect(find.byType(WGInfoRow), findsNWidgets(7));
    expect(find.text('Poodle'), findsOneWidget);
    expect(find.text('12,5 kg'), findsOneWidget);
  });

  //495
  testWidgets('descrição ausente mostra o aviso padrão', (tester) async {
    await tester.pumpWidget(
      wrap(WGPetDetailsInfo(pet: buildPet(description: null))),
    );

    expect(find.text(PetDetailsStrings.DESCRIPTION_NOT_INFORMED), findsOneWidget);
  });

  //496
  testWidgets('contato sem telefone abre o aviso, sem tocar o WhatsApp', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(WGPetDetailsInfo(pet: buildPet(ownerPhone: ''))),
    );

    await tester.ensureVisible(find.text(PetDetailsStrings.CONTACT_BUTTON));
    await tester.pumpAndSettle();
    await tester.tap(find.text(PetDetailsStrings.CONTACT_BUTTON));
    await tester.pumpAndSettle();

    expect(find.text(SharedStrings.NOTICE_TITLE), findsOneWidget);
    expect(find.text(PetDetailsStrings.OWNER_PHONE_UNAVAILABLE), findsOneWidget);
  });
}
