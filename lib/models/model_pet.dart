import 'package:appets/models/enums/enum_pet_gender.dart';

class Pet {
  //══════════════════════════════════════════════════════════════
  // CONSTRUCTOR
  //══════════════════════════════════════════════════════════════

  const Pet({
    required this.name,
    required this.age,
    required this.gender,
    required this.city,
    required this.images,
  });

  //══════════════════════════════════════════════════════════════
  // PROPERTIES
  //══════════════════════════════════════════════════════════════

  final String name;

  final int age;

  final AppPetGender gender;

  final String city;

  final List<String> images;
}
