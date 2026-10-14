import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter_image_compress/flutter_image_compress.dart';

/// Comprime uma imagem local antes do upload.
///
/// Estratégia "uma qualidade por vez": tenta webp na dimensão informada
/// pelas qualidades [qualityCandidates] em ordem decrescente e PARA assim
/// que uma couber no teto [targetMaxBytes] e for menor que o original.
/// Qualidade que falha (null/vazia) é ignorada e a próxima é tentada; se
/// nenhuma couber, fica com a menor qualidade que ainda reduza o arquivo
/// (melhor esforço). Se nada compensar (imagem pequena) devolve `null` — o
/// chamador mantém o original — e apaga qualquer temporário `.webp` deixado
/// por uma tentativa anterior do mesmo arquivo.
///
/// Dois perfis prontos: [compressForUpload] (fotos de pets, 1280px/350 KB)
/// e [compressAvatar] (foto de perfil, 256px/40 KB).
class ImageCompressor {
  ImageCompressor._();

  // ── Fotos de pets (padrão) ─────────────────────────────

  /// Teto máximo do arquivo comprimido (~350 KB).
  static const int targetMaxBytes = 350 * 1024;

  /// Dimensão máxima (em pixels) da imagem comprimida.
  static const int maxDimension = 1280;

  /// Qualidades tentadas em ordem decrescente.
  static const List<int> qualityCandidates = [85, 70, 60];

  // ── Foto de perfil (avatar) ────────────────────────────

  /// Teto máximo do avatar (~40 KB): é uma imagem minúscula na tela.
  static const int avatarMaxBytes = 40 * 1024;

  /// Dimensão máxima do avatar (256px cobre o avatar de 90px em telas 3x).
  static const int avatarMaxDimension = 256;

  /// Qualidades tentadas em ordem decrescente para o avatar.
  static const List<int> avatarQualityCandidates = [70, 55, 40];

  /// Comprimidor injetável em testes (no lugar do plugin).
  @visibleForTesting
  static Future<Uint8List?> Function(String sourcePath, int quality)?
  debugCompress;

  /// Dimensão usada na última compressão (testes provam o perfil aplicado).
  @visibleForTesting
  static int? debugLastMaxDimension;

  /// Comprime uma foto de pet com o perfil padrão (1280px / 350 KB).
  static Future<File?> compressForUpload(String sourcePath) => _run(
    sourcePath,
    targetMaxBytes: targetMaxBytes,
    maxDimension: maxDimension,
    qualityCandidates: qualityCandidates,
  );

  /// Comprime uma foto de perfil com o perfil leve (256px / 40 KB).
  static Future<File?> compressAvatar(String sourcePath) => _run(
    sourcePath,
    targetMaxBytes: avatarMaxBytes,
    maxDimension: avatarMaxDimension,
    qualityCandidates: avatarQualityCandidates,
  );

  // Núcleo da compressão, parametrizado por perfil.
  static Future<File?> _run(
    String sourcePath, {
    required int targetMaxBytes,
    required int maxDimension,
    required List<int> qualityCandidates,
  }) async {
    final original = File(sourcePath);
    if (!await original.exists()) return null;
    final originalBytes = await original.length();
    if (originalBytes == 0) return null;

    Uint8List? chosenBytes;
    for (final quality in qualityCandidates) {
      final bytes = await _compress(sourcePath, quality, maxDimension);
      // Qualidade que falhou (null/vazia) não participa da escolha.
      if (bytes == null || bytes.isEmpty) continue;
      // Como já tem bytes, só faz sentido se realmente reduzir o arquivo.
      if (bytes.length >= originalBytes) continue;

      if (bytes.length <= targetMaxBytes) {
        // Primeira qualidade que cabe no teto: decisão final.
        chosenBytes = bytes;
        break;
      }
      // Melhor esforço: lembra da última qualidade que reduziu (a menor
      // vista até aqui) para o caso de nenhuma couber no teto.
      chosenBytes = bytes;
    }

    if (chosenBytes == null) {
      // Nada compensou: não deixa temporário órfão de tentativa anterior.
      await _deleteTempIfAny(sourcePath);
      return null;
    }

    final target = File('$sourcePath.webp');
    try {
      await target.writeAsBytes(chosenBytes, flush: true);
      return target;
    } catch (_) {
      return null;
    }
  }

  /// Apaga os arquivos temporários `.webp` gerados pelo compressor.
  ///
  /// Best-effort e conservador: mexe apenas em paths que terminam em
  /// `.webp`, nunca no arquivo original; erros são ignorados. Use depois
  /// que o upload consumir a imagem (e ao descartar a foto sem salvar).
  static Future<void> deleteTempWebpFiles(Iterable<String> paths) async {
    for (final path in paths) {
      if (!path.toLowerCase().endsWith('.webp')) continue;
      try {
        final file = File(path);
        if (await file.exists()) await file.delete();
      } catch (_) {
        // Melhor esforço.
      }
    }
  }

  static Future<void> _deleteTempIfAny(String sourcePath) async {
    try {
      final temp = File('$sourcePath.webp');
      if (await temp.exists()) await temp.delete();
    } catch (_) {
      // Melhor esforço.
    }
  }

  // Comprime o arquivo em webp e devolve os bytes (ou null se falhar).
  static Future<Uint8List?> _compress(
    String sourcePath,
    int quality,
    int maxDimension,
  ) async {
    debugLastMaxDimension = maxDimension;
    final fake = debugCompress;
    if (fake != null) return fake(sourcePath, quality);

    try {
      return await FlutterImageCompress.compressWithFile(
        sourcePath,
        minWidth: maxDimension,
        minHeight: maxDimension,
        quality: quality,
        format: CompressFormat.webp,
      );
    } catch (_) {
      return null;
    }
  }
}
