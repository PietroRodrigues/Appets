import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:appets/core/constants/constants_strings_home.dart';
import 'package:appets/core/constants/constants_strings_publish.dart';
import 'package:appets/models/enums/enums_app.dart';
import 'package:appets/models/model_pet.dart';
import 'package:appets/screens/screen_publish_pet.dart';
import 'package:appets/widgets/publish/widget_publish_pet_form.dart';

/// Pet mínimo válido para o modo edição do shell.
Pet _pet() {
  return const Pet(
    id: 'pet_a',
    ownerId: 'dono_a',
    name: 'Rex',
    age: 2,
    gender: AppPetGender.male,
    address: 'Rua 1',
    images: ['https://example.com/a.jpg'],
  );
}

void main() {
  Future<void> pumpPublish(WidgetTester tester, {Pet? pet}) async {
    await tester.pumpWidget(
      MaterialApp(home: PublishPetScreen(pet: pet)),
    );
    await tester.pump();
  }

  //229
  testWidgets('modo publicar exibe o cabeçalho e o formulário',
      (tester) async {
    await pumpPublish(tester);

    expect(find.text(HomeStrings.PUBLISH_PET), findsOneWidget);
    expect(find.text(PublishStrings.PUBLISH_PET_DESCRIPTION), findsOneWidget);
    expect(find.byType(WGPublishPetForm), findsOneWidget);
  });

  //230
  testWidgets('modo edição exibe o cabeçalho de edição e o formulário',
      (tester) async {
    await pumpPublish(tester, pet: _pet());

    expect(find.text(HomeStrings.EDIT_PET), findsOneWidget);
    expect(find.text(PublishStrings.EDIT_PET_DESCRIPTION), findsOneWidget);
    expect(find.byType(WGPublishPetForm), findsOneWidget);
  });
}
