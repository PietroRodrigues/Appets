import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:appets/models/enums/enums_pet.dart';

/// Modelo de dados de um pet.
///
/// Contém todas as informações necessárias para exibir
/// e gerenciar um pet na plataforma.
class Pet {
  //══════════════════════════════════════════════════════════════
  // CONSTRUCTOR
  //══════════════════════════════════════════════════════════════

  const Pet({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.age,
    required this.gender,
    required this.city,
    required this.images,
    this.description,
    this.ageUnit = AppPetAgeUnit.years,
    this.publicationType = AppPetPublicationType.adoption,
  });

  //══════════════════════════════════════════════════════════════
  // PROPERTIES
  //══════════════════════════════════════════════════════════════

  /// Identificador único do pet (Firebase document ID).
  final String id;

  /// Identificador do usuário dono da publicação (Firebase Auth UID).
  final String ownerId;

  final String name;

  final int age;

  final AppPetGender gender;

  final String city;

  final List<String> images;

  /// Descrição do pet (campo "Sobre o pet").
  final String? description;

  /// Unidade de idade: dias, meses ou anos.
  final AppPetAgeUnit ageUnit;

  /// Tipo de publicação: adoção ou perdido.
  final AppPetPublicationType publicationType;

  // Converte o pet em um mapa para persistência no Firestore.
  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'name': name,
      'age': age,
      'ageUnit': ageUnit.name,
      'gender': gender.name,
      'city': city,
      'description': description ?? '',
      'publicationType': publicationType.name,
      'images': images,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  // Cria um pet a partir de um documento do Firestore.
  factory Pet.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Pet(
      id: doc.id,
      ownerId: data['ownerId'] ?? '',
      name: data['name'] ?? '',
      age: data['age'] ?? 0,
      ageUnit: AppPetAgeUnit.values.firstWhere(
        (e) => e.name == data['ageUnit'],
        orElse: () => AppPetAgeUnit.years,
      ),
      gender: AppPetGender.values.firstWhere(
        (e) => e.name == data['gender'],
        orElse: () => AppPetGender.male,
      ),
      city: data['city'] ?? '',
      description: data['description'],
      publicationType: AppPetPublicationType.values.firstWhere(
        (e) => e.name == data['publicationType'],
        orElse: () => AppPetPublicationType.adoption,
      ),
      images: List<String>.from(data['images'] ?? []),
    );
  }
}
