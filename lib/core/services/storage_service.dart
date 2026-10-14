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

  /// Atraso injetado por exclusão em testes (prova o paralelismo).
  @visibleForTesting
  Duration? debugDeleteDelay;

  /// Pico de exclusões simultâneas observado (testes: paralelo = N).
  @visibleForTesting
  int debugMaxConcurrentDeletes = 0;

  int _activeDeletes = 0;

  // Extrai a extensão (sem o ponto) do caminho, ou '' se não houver.
  //
  // Diferente de `split('.').last`, não devolve o caminho inteiro quando o
  // arquivo não tem ponto — o que geraria um caminho inválido no Storage
  // (ex.: `avatars/{uid}/avatar./data/user/0/.../image_picker`).
  static String _extensionOf(String path) {
    final match = RegExp(r'\.([^./\\]+)$').firstMatch(path);
    return match?.group(1)?.toLowerCase() ?? '';
  }

  // Monta o caminho de uma foto no Storage, no padrão dono→pet→índice.
  static String petImagePath(
    String ownerId,
    String petId,
    int index, [
    String extension = 'jpg',
  ]) {
    return 'pets/$ownerId/$petId/photo_$index.$extension';
  }

  // Monta o caminho do avatar do usuário: avatars/{uid}/avatar_{versão}.ext.
  //
  // A versão torna cada upload um arquivo NOVO (nunca sobrescreve o
  // anterior): a URL antiga segue apontando para o arquivo antigo, então
  // o fluxo que troca a foto pode apagá-la com segurança. Com caminho
  // fixo, oldUrl e newUrl referenciavam o MESMO objeto do Storage e o
  // delete da antiga destruía o avatar recém-enviado.
  static int _lastAvatarVersion = 0;

  static String avatarPath(String uid, [String extension = 'webp']) {
    // Timestamp com monotonicidade garantida: duas chamadas no mesmo
    // milissegundo (ex.: testes) também geram versões distintas.
    var version = DateTime.now().millisecondsSinceEpoch;
    if (version <= _lastAvatarVersion) version = _lastAvatarVersion + 1;
    _lastAvatarVersion = version;
    return 'avatars/$uid/avatar_$version.$extension';
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
    final extension = _extensionOf(imageFile.path);
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

  // Faz upload do avatar do usuário e retorna a URL de acesso.
  //
  // O caminho inclui o [uid] para que as regras do Storage restrinjam a
  // escrita/delete somente ao dono (mesmo padrão das fotos dos pets). A
  // extensão/contentType são derivados do arquivo (o compressor gera webp).
  Future<String> uploadAvatar(String uid, File imageFile) async {
    final extension = _extensionOf(imageFile.path);
    final safeExtension = (extension.isEmpty) ? 'webp' : extension;
    final contentType = switch (safeExtension) {
      'webp' => 'image/webp',
      'png' => 'image/png',
      _ => 'image/jpeg',
    };

    final ref = _storage.ref().child(avatarPath(uid, safeExtension));
    await ref.putFile(imageFile, SettableMetadata(contentType: contentType));
    return await ref.getDownloadURL();
  }

  // Remove o avatar do usuário pela URL salva no Firestore (melhor esforço).
  Future<void> deleteAvatarByUrl(String url) => _deleteByUrl(url);

  // Remove um arquivo do Storage pela URL, ignorando falhas (URL inválida
  // ou arquivo já inexistente não devem interromper o fluxo).
  Future<void> _deleteByUrl(String url) async {
    try {
      await _storage.refFromURL(url).delete();
    } catch (_) {
      // Melhor esforço.
    }
  }

  // Remove imagens de um pet pelas URLs salvas no Firestore.
  //
  // Usa a própria URL (via refFromURL) em vez de derivar o caminho por
  // índice: robusto mesmo quando a edição deixou índices esparsos.
  //
  // Dispara todas as exclusões em paralelo (Future.wait) — o custo não é
  // a soma das latências — mantendo o melhor esforço: cada URL engole a
  // própria falha e as demais seguem normalmente.
  Future<void> deletePetImagesByUrls(List<String> imageUrls) async {
    await Future.wait(
      imageUrls.map((url) async {
        _activeDeletes++;
        if (_activeDeletes > debugMaxConcurrentDeletes) {
          debugMaxConcurrentDeletes = _activeDeletes;
        }
        try {
          final delay = debugDeleteDelay;
          if (delay != null) {
            await Future<void>.delayed(delay);
          }
          await _deleteByUrl(url);
        } catch (_) {
          // Ignorar se a imagem não existe ou o URL for inválido.
        } finally {
          _activeDeletes--;
        }
      }),
    );
  }
}
