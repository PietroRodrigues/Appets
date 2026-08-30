import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:appets/models/user_model.dart';

/// Opera sobre o documento `users` no Firestore.
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Cria o documento do usuário na coleção `users`.
  Future<void> createUser(UserModel user) async {
    await _db.collection('users').doc(user.id).set(user.toMap());
  }

  // Busca o documento do usuário pelo UID; retorna `null` se não existir.
  Future<UserModel?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  // Atualiza campos do documento do usuário.
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
  }

  // Adiciona um pet aos favoritos do usuário.
  Future<void> addFavorite(String uid, String petId) async {
    await updateUser(uid, {
      'favoritePetIds': FieldValue.arrayUnion([petId]),
    });
  }

  // Remove um pet dos favoritos do usuário.
  Future<void> removeFavorite(String uid, String petId) async {
    await updateUser(uid, {
      'favoritePetIds': FieldValue.arrayRemove([petId]),
    });
  }

  // Remove o documento do usuário.
  Future<void> deleteUser(String uid) async {
    await _db.collection('users').doc(uid).delete();
  }
}
