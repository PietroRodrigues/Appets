import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:appets/core/extensions/extension_pet_publication_type.dart';
import 'package:appets/core/theme/app_colors.dart';
import 'package:appets/models/enums/enums_app.dart';

void main() {
  //17
  test('ícone por tipo de publicação', () {
    expect(AppPetPublicationType.adoption.icon, Icons.pets);
    expect(AppPetPublicationType.lost.icon, Icons.search);
  });

  //18
  test('cor por tipo de publicação', () {
    expect(
      AppPetPublicationType.adoption.color(AppColors.light),
      AppColors.light.success,
    );
    expect(
      AppPetPublicationType.lost.color(AppColors.light),
      AppColors.light.error,
    );
  });
}
