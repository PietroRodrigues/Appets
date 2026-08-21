import 'package:appets/models/enums/enum_pet_gender.dart';
import 'package:appets/models/enums/enum_pet_publication_type.dart';
import 'package:appets/models/model_pet.dart';

//══════════════════════════════════════════════════════════════
// MOCK DATA
//
// Dados temporários utilizados apenas durante o desenvolvimento.
//
// Futuramente esta lista será substituída pelos dados vindos
// do Firebase Firestore.
//
// ID do usuário logado simulado (será o Auth UID do Firebase).
const _currentUserId = 'user_pietro_001';
//══════════════════════════════════════════════════════════════

final List<Pet> mockPets = [
  const Pet(
    id: 'pet_001',
    ownerId: _currentUserId,
    name: 'Thor',
    age: 2,
    gender: AppPetGender.male,
    city: 'São Paulo',
    publicationType: AppPetPublicationType.adoption,
    images: [
      'assets/images/dog.png',
      'assets/images/dog.png',
      'assets/images/dog.png',
    ],
  ),

  const Pet(
    id: 'pet_002',
    ownerId: 'user_outro_002',
    name: 'Luna',
    age: 1,
    gender: AppPetGender.female,
    city: 'Campinas',
    publicationType: AppPetPublicationType.lost,
    images: [
      'assets/images/dog.png',
      'assets/images/dog.png',
      'assets/images/dog.png',
    ],
  ),

  const Pet(
    id: 'pet_003',
    ownerId: _currentUserId,
    name: 'Mel',
    age: 3,
    gender: AppPetGender.female,
    city: 'Santos',
    publicationType: AppPetPublicationType.adoption,
    images: [
      'assets/images/dog.png',
      'assets/images/dog.png',
      'assets/images/dog.png',
    ],
  ),

  const Pet(
    id: 'pet_004',
    ownerId: 'user_outro_003',
    name: 'Bob',
    age: 4,
    gender: AppPetGender.male,
    city: 'São Paulo',
    publicationType: AppPetPublicationType.lost,
    images: [
      'assets/images/dog.png',
      'assets/images/dog.png',
      'assets/images/dog.png',
    ],
  ),

  const Pet(
    id: 'pet_005',
    ownerId: _currentUserId,
    name: 'Nina',
    age: 2,
    gender: AppPetGender.female,
    city: 'Sorocaba',
    publicationType: AppPetPublicationType.adoption,
    images: [
      'assets/images/dog.png',
      'assets/images/dog.png',
      'assets/images/dog.png',
    ],
  ),

  const Pet(
    id: 'pet_006',
    ownerId: 'user_outro_004',
    name: 'Max',
    age: 5,
    gender: AppPetGender.male,
    city: 'Guarulhos',
    publicationType: AppPetPublicationType.adoption,
    images: [
      'assets/images/dog.png',
      'assets/images/dog.png',
      'assets/images/dog.png',
    ],
  ),
];
