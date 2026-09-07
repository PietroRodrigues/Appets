import 'package:flutter_test/flutter_test.dart';

import 'package:appets/core/utils/pet_filters_controller.dart';
import 'package:appets/widgets/filters/widget_pet_filters_sheet.dart';

void main() {
  const dog = PetFilterOption(
    category: PetFilterCategory.species,
    value: 'dog',
    label: 'Cachorro',
  );
  const female = PetFilterOption(
    category: PetFilterCategory.gender,
    value: 'female',
    label: 'Fêmea',
  );

  test('inicia vazio e inativo', () {
    final controller = PetFiltersController();
    expect(controller.value, isEmpty);
    expect(controller.isActive, isFalse);
    expect(controller.tags, isEmpty);
    controller.dispose();
  });

  test('tags expõe os valores das opções ativas', () {
    final controller = PetFiltersController();
    controller.value = [dog, female];
    expect(controller.tags, ['dog', 'female']);
    expect(controller.isActive, isTrue);
    controller.dispose();
  });

  test('remove apaga apenas a opção indicada', () {
    final controller = PetFiltersController();
    controller.value = [dog, female];

    controller.remove(female);

    expect(controller.value, hasLength(1));
    expect(controller.value.single.id, dog.id);
    controller.dispose();
  });

  test('clear limpa e notifica os ouvintes', () {
    final controller = PetFiltersController();
    controller.value = [dog];
    var notified = 0;
    controller.addListener(() => notified++);

    controller.clear();

    expect(controller.value, isEmpty);
    expect(controller.isActive, isFalse);
    expect(notified, 1);
    controller.dispose();
  });
}