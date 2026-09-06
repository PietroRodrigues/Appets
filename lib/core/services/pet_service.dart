import 'package:appets/core/utils/search_tokens.dart';
import 'package:appets/models/model_pet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Resultado de uma página paginada de pets.
class PetsPage {
  const PetsPage({required this.pets, required this.hasMore, this.lastDoc});

  /// Pets presentes nesta página.
  final List<Pet> pets;

  /// Último documento da consulta, usado como cursor na próxima página.
  final QueryDocumentSnapshot? lastDoc;

  /// Indica se há mais páginas a carregar.
  final bool hasMore;
}

/// Opera sobre a coleção `pets` no Firestore.
class PetService {
  PetService._();

  static final PetService instance = PetService._();

  /// Quantidade de pets por página no feed paginado.
  static const int pageSize = 20;

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

  // Retorna os pets correspondentes a uma lista de IDs (usado para favoritos
  // e para as publicações do usuário).
  //
  // O Firestore limita `whereIn` a no máximo 10 valores por consulta, então
  // os IDs são divididos em lotes de 10 e as consultas rodam em paralelo.
  Future<List<Pet>> getPetsByIds(List<String> petIds) async {
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

  // ── Página inicial do feed de todos os pets ──────────────────────
  //
  // O pedido de +1 item indica se há mais páginas (`hasMore`).
  Stream<PetsPage> watchFirstPage() {
    return _db
        .collection('pets')
        .orderBy('createdAt', descending: true)
        .limit(pageSize + 1)
        .snapshots()
        .map((snapshot) => _toPage(snapshot));
  }

  // ── Página inicial do feed de pets de um dono ────────────────────
  Stream<PetsPage> watchMyPetsFirstPage(String ownerId) {
    return _db
        .collection('pets')
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('createdAt', descending: true)
        .limit(pageSize + 1)
        .snapshots()
        .map((snapshot) => _toPage(snapshot));
  }

  // ── Próxima página do feed de todos os pets ──────────────────────
  Future<PetsPage> getNextPage(QueryDocumentSnapshot lastDoc) async {
    final snapshot = await _db
        .collection('pets')
        .orderBy('createdAt', descending: true)
        .startAfterDocument(lastDoc)
        .limit(pageSize + 1)
        .get();
    return _toPage(snapshot);
  }

  // ── Próxima página do feed de pets de um dono ────────────────────
  Future<PetsPage> getMyPetsNextPage(
    String ownerId,
    QueryDocumentSnapshot lastDoc,
  ) async {
    final snapshot = await _db
        .collection('pets')
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('createdAt', descending: true)
        .startAfterDocument(lastDoc)
        .limit(pageSize + 1)
        .get();
    return _toPage(snapshot);
  }

  // ── Busca por tokens (prefixo de palavras do nome/descrição) ─────
  //
  // Cada token é armazenado em `searchTokens` no documento e consultado
  // com `arrayContainsAny`. Requer um índice composto no Firestore
  // (searchTokens array-contains-any + orderBy createdAt desc).
  Future<PetsPage> searchPetsByTokens(String term) async {
    final tokens = normalizeText(term).split(RegExp(r'[^a-z0-9]+'));
    final searchable = tokens.where((t) => t.length >= 2).toSet().toList();

    if (searchable.isEmpty) return const PetsPage(pets: [], hasMore: false);

    final q = _db
        .collection('pets')
        .where('searchTokens', arrayContainsAny: searchable);

    final snapshot = await q
        .orderBy('createdAt', descending: true)
        .limit(pageSize + 1)
        .get();
    return _toPage(snapshot);
  }

  // Converte um snapshot em uma página, descartando o item extra
  // usado apenas para detectar `hasMore`.
  PetsPage _toPage(QuerySnapshot snapshot) {
    final hasMore = snapshot.docs.length > pageSize;
    final docs = hasMore ? snapshot.docs.take(pageSize) : snapshot.docs;
    return PetsPage(
      pets: docs.map((doc) => Pet.fromFirestore(doc)).toList(),
      lastDoc: hasMore ? snapshot.docs[pageSize - 1] : null,
      hasMore: hasMore,
    );
  }
}
