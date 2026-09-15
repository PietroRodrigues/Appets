import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;

/// Opera sobre as imagens dos pets no Firebase Storage.
class StorageService {
  StorageService._();

  static final StorageService instance = StorageService._();

  FirebaseStorage? _debugStorage;

  FirebaseStorage get _storage => _debugStorage ?? FirebaseStorage.instance;

  /// Permite injetar um Storage de teste (ex.: em modo de falha).
  @visibleForTesting
  set debugStorage(FirebaseStorage? storage) => _debugStorage = storage;

  // Monta o caminho de uma foto no Storage, no padrão dono→pet→índice.
  static String petImagePath(
    String ownerId,
    String petId,
    int index, [
    String extension = 'jpg',
  ]) {
    return 'pets/$ownerId/$petId/photo_$index.$extension';
  }

  // Faz upload de uma imagem do pet e retorna a URL de acesso.
  //
  // O caminho inclui o [ownerId] para que as regras do Storage possam
  // restringir escrita/delete somente ao dono (mesmo padrão do Firestore).
  // A extensão e o contentType são derivados do arquivo (ex.: webp/png).
  Future<String> uploadPetImage(
    String ownerId,
    String petId,
    int index,
    File imageFile,
  ) async {
    final extension = imageFile.path.split('.').last.toLowerCase();
    final safeExtension = (extension.isEmpty) ? 'jpg' : extension;
    final contentType = switch (safeExtension) {
      'webp' => 'image/webp',
      'png' => 'image/png',
      _ => 'image/jpeg',
    };

    final ref =
        _storage.ref().child(petImagePath(ownerId, petId, index, safeExtension));
    await ref.putFile(imageFile, SettableMetadata(contentType: contentType));
    return await ref.getDownloadURL();
  }

  // Remove imagens de um pet pelas URLs salvas no Firestore.
  //
  // Usa a própria URL (via refFromURL) em vez de derivar o caminho por
  // índice: robusto mesmo quando a edição deixou índices esparsos.
  Future<void> deletePetImagesByUrls(List<String> imageUrls) async {
    for (final url in imageUrls) {
      try {
        await _storage.refFromURL(url).delete();
      } catch (_) {
        // Ignorar se a imagem não existe ou o URL for inválido.
      }
    }
  }
}
