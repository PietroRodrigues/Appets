import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

/// Opera sobre as imagens dos pets no Firebase Storage.
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Faz upload de uma imagem do pet e retorna a URL de acesso.
  Future<String> uploadPetImage(String petId, int index, File imageFile) async {
    final ref = _storage.ref().child('pets/$petId/photo_$index.jpg');
    await ref.putFile(
      imageFile,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return await ref.getDownloadURL();
  }

  // Remove todas as imagens de um pet (por índice até [imageCount]).
  Future<void> deletePetImages(String petId, int imageCount) async {
    for (int i = 0; i < imageCount; i++) {
      final ref = _storage.ref().child('pets/$petId/photo_$i.jpg');
      try {
        await ref.delete();
      } catch (_) {
        // Ignorar se a imagem não existe
      }
    }
  }
}
