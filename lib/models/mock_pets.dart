import 'package:appets/models/enums/enum_pet_gender.dart';
import 'package:appets/models/model_pet.dart';

//══════════════════════════════════════════════════════════════
// MOCK DATA
//
// Dados temporários utilizados apenas durante o desenvolvimento.
//
// Futuramente esta lista será substituída pelos dados vindos
// do Firebase Firestore.
//══════════════════════════════════════════════════════════════

final List<Pet> mockPets = [
  const Pet(
    name: 'Thor',
    age: 2,
    gender: AppPetGender.male,
    city: 'São Paulo',
    images: [
      'assets/images/dog.png',
      'assets/images/dog.png',
      'assets/images/dog.png',
    ],
  ),

  const Pet(
    name: 'Luna',
    age: 1,
    gender: AppPetGender.female,
    city: 'Campinas',
    images: [
      'assets/images/dog.png',
      'assets/images/dog.png',
      'assets/images/dog.png',
    ],
  ),

  const Pet(
    name: 'Mel',
    age: 3,
    gender: AppPetGender.female,
    city: 'Santos',
    images: [
      'assets/images/dog.png',
      'assets/images/dog.png',
      'assets/images/dog.png',
    ],
  ),

  const Pet(
    name: 'Bob',
    age: 4,
    gender: AppPetGender.male,
    city: 'São Paulo',
    images: [
      'assets/images/dog.png',
      'assets/images/dog.png',
      'assets/images/dog.png',
    ],
  ),

  const Pet(
    name: 'Nina',
    age: 2,
    gender: AppPetGender.female,
    city: 'Sorocaba',
    images: [
      'assets/images/dog.png',
      'assets/images/dog.png',
      'assets/images/dog.png',
    ],
  ),

  const Pet(
    name: 'Max',
    age: 5,
    gender: AppPetGender.male,
    city: 'Guarulhos',
    images: [
      'assets/images/dog.png',
      'assets/images/dog.png',
      'assets/images/dog.png',
    ],
  ),
];
