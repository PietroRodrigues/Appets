import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:appets/models/enums/enums_app.dart';

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
    required this.address,
    required this.images,
    this.ownerPhone = '',
    this.ownerAddress = '',
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

  final String address;

  /// Telefone de contato do dono, "carimbo" copiado da conta
  /// no momento da publicação. Mantido aqui para exibição
  /// sem necessidade de buscar o usuário a cada listagem.
  final String ownerPhone;

  /// Endereço do dono, "carimbo" copiado da conta no momento
  /// da publicação.
  final String ownerAddress;

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
      'address': address,
      'ownerPhone': ownerPhone,
      'ownerAddress': ownerAddress,
      'description': description ?? '',
      'publicationType': publicationType.name,
      'images': images,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  // Cria um pet a partir de um documento do Firestore.
  factory Pet.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Pet.fromMap(doc.id, data);
  }

  // Cria um pet a partir de um mapa de dados (ex.: documento Firestore).
  factory Pet.fromMap(String id, Map<String, dynamic> data) {
    return Pet(
      id: id,
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
      address: data['address'] ?? data['city'] ?? '',
      ownerPhone: data['ownerPhone'] ?? '',
      ownerAddress: data['ownerAddress'] ?? '',
      description: data['description'],
      publicationType: AppPetPublicationType.values.firstWhere(
        (e) => e.name == data['publicationType'],
        orElse: () => AppPetPublicationType.adoption,
      ),
      images: _stringList(data['images']),
    );
  }

  // Converte defensivamente uma lista do Firestore em uma lista de strings.
  // Ignora elementos não-string e evita TypeError com dados corrompidos.
  static List<String> _stringList(Object? value) {
    if (value is! List) return [];
    return value.whereType<String>().toList();
  }
}
