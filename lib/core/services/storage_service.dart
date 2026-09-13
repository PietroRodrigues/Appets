import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

/// Opera sobre as imagens dos pets no Firebase Storage.
class StorageService {
  StorageService._();

  static final StorageService instance = StorageService._();

  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Faz upload de uma imagem do pet e retorna a URL de acesso.
  //
  // O caminho inclui o [ownerId] para que as regras do Storage possam
  // restringir escrita/delete somente ao dono (mesmo padrão do Firestore).
  Future<String> uploadPetImage(
    String ownerId,
    String petId,
    int index,
    File imageFile,
  ) async {
    final ref =
        _storage.ref().child('pets/$ownerId/$petId/photo_$index.jpg');
    await ref.putFile(imageFile, SettableMetadata(contentType: 'image/jpeg'));
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
