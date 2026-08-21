import 'package:appets/models/enums/enum_pet_gender.dart';
import 'package:appets/models/enums/enum_pet_publication_type.dart';

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

  /// Tipo de publicação: adoção ou perdido.
  final AppPetPublicationType publicationType;
}
