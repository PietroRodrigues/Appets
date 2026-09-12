import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:appets/core/utils/pet_filters.dart';
import 'package:appets/core/utils/search_tokens.dart';
import 'package:appets/core/utils/storage_tokens.dart';
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
    this.species = AppPetSpecies.dog,
    this.race = '',
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

  /// Espécie do pet (cachorro, gato, coelho, pássaro, etc.).
  final AppPetSpecies species;

  /// Raça do pet, opcional (ex.: "Poodle", "SRD").
  final String race;

  /// Tokens de filtro (1 por categoria, normalizados), gravados no
  /// documento e consultados pelo servidor com `arrayContainsAny`.
  ///
  /// Sempre derivado dos campos atuais (nunca armazenado no objeto),
  /// garantindo consistência com espécie/gênero/tipo/idade exibidos.
  List<String> get specifications => buildFilterTokens(
        species: species,
        gender: gender,
        publicationType: publicationType,
        age: age,
        ageUnit: ageUnit,
      );

  // Converte o pet em um mapa para persistência no Firestore.
  //
  // Os códigos de espécie, gênero, unidade de idade e tipo são gravados
  // em tokens PT normalizados (ver [storage_tokens]).
  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'name': name,
      'age': age,
      'ageUnit': ageUnitStorageToken(ageUnit),
      'gender': genderStorageToken(gender),
      'address': address,
      'ownerPhone': ownerPhone,
      'ownerAddress': ownerAddress,
      'description': description ?? '',
      'publicationType': publicationTypeStorageToken(publicationType),
      'species': speciesStorageToken(species),
      'race': race,
      'searchTokens': buildSearchTokens(name: name, description: description),
      'specifications': specifications,
      'images': images,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  // Converte o pet em um mapa para atualização no Firestore.
  //
  // Diferente do [toMap]: não grava `id`, `ownerId` nem `createdAt`
  // (evita reordernar o feed) e não toca em `images`, que são gerenciadas
  // à parte pelo fluxo de fotos.
  Map<String, dynamic> toUpdateMap() {
    return {
      'name': name,
      'age': age,
      'ageUnit': ageUnitStorageToken(ageUnit),
      'gender': genderStorageToken(gender),
      'address': address,
      'ownerPhone': ownerPhone,
      'ownerAddress': ownerAddress,
      'description': description ?? '',
      'publicationType': publicationTypeStorageToken(publicationType),
      'species': speciesStorageToken(species),
      'race': race,
      'searchTokens': buildSearchTokens(name: name, description: description),
      'specifications': specifications,
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
      ageUnit: ageUnitFromStored(data['ageUnit']),
      gender: genderFromStored(data['gender']),
      address: data['address'] ?? data['city'] ?? '',
      ownerPhone: data['ownerPhone'] ?? '',
      ownerAddress: data['ownerAddress'] ?? '',
      description: data['description'],
      publicationType: publicationTypeFromStored(data['publicationType']),
      species: speciesFromStored(data['species']),
      race: data['race'] ?? '',
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
