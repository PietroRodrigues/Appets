import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:appets/models/model_pet.dart';

/// Opera sobre a coleção `pets` no Firestore.
class PetService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Retorna todos os pets, dos mais recentes aos mais antigos.
  Future<List<Pet>> getAllPets() async {
    final snapshot = await _db
        .collection('pets')
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => Pet.fromFirestore(doc)).toList();
  }

  // Retorna os pets publicados por um determinado dono (UID).
  Future<List<Pet>> getPetsByOwner(String ownerId) async {
    final snapshot = await _db
        .collection('pets')
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => Pet.fromFirestore(doc)).toList();
  }

  // Retorna um pet pelo seu ID (documento); `null` se não existir.
  Future<Pet?> getPetById(String petId) async {
    final doc = await _db.collection('pets').doc(petId).get();
    if (!doc.exists) return null;
    return Pet.fromFirestore(doc);
  }

  // Cria um pet e retorna o ID gerado pelo Firestore.
  Future<String> createPet(Pet pet) async {
    final docRef = await _db.collection('pets').add(pet.toMap());
    return docRef.id;
  }

  // Atualiza campos de um pet existente.
  Future<void> updatePet(String petId, Map<String, dynamic> data) async {
    await _db.collection('pets').doc(petId).update(data);
  }

  // Remove um pet pelo ID.
  Future<void> deletePet(String petId) async {
    await _db.collection('pets').doc(petId).delete();
  }

  // Retorna os pets correspondentes a uma lista de IDs (usado para favoritos).
  //
  // O Firestore limita `whereIn` a no máximo 10 valores por consulta, então
  // os IDs são divididos em lotes de 10 e as consultas rodam em paralelo.
  Future<List<Pet>> getFavoritePets(List<String> petIds) async {
    if (petIds.isEmpty) return [];

    const batchSize = 10;
    final results = <Pet>[];
    for (var i = 0; i < petIds.length; i += batchSize) {
      final end = (i + batchSize > petIds.length)
          ? petIds.length
          : i + batchSize;
      final batch = petIds.sublist(i, end);
      final snapshot = await _db
          .collection('pets')
          .where(FieldPath.documentId, whereIn: batch)
          .get();
      results.addAll(snapshot.docs.map((doc) => Pet.fromFirestore(doc)));
    }
    return results;
  }
}
