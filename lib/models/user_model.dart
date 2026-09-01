import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

/// Modelo de dados do usuário do app.
class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone = '',
    this.address = '',
    this.photoUrl = '',
    this.favoritePetIds = const [],
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String photoUrl;

  /// IDs dos pets favoritados pelo usuário.
  final List<String> favoritePetIds;

  // Converte o usuário em um mapa para persistência no Firestore.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'photoUrl': photoUrl,
      'favoritePetIds': favoritePetIds,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  // Cria um usuário a partir de um documento do Firestore.
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      address: data['address'] ?? data['city'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      favoritePetIds: List<String>.from(data['favoritePetIds'] ?? []),
    );
  }

  // Cria um usuário a partir da conta autenticada do Firebase Auth.
  factory UserModel.fromFirebaseUser(fb.User user) {
    return UserModel(
      id: user.uid,
      name: user.displayName ?? '',
      email: user.email ?? '',
      photoUrl: user.photoURL ?? '',
    );
  }
}
