import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';

/// Escolha de qualidade de compressão feita por [chooseBestCompression].
class BestCompression {
  const BestCompression({required this.quality, required this.bytes});

  final int quality;

  final int bytes;
}

/// Escolhe a melhor qualidade de compressão respeitando o teto de bytes.
///
/// Lógica pura (sem dependência do plugin), testável:
/// - percorre as qualidades em ordem decrescente e escolhe a primeira cujo
///   resultado caiba no teto E seja menor que o original (melhor qualidade
///   possível dentro do limite);
/// - se nenhuma couber no teto, usa a menor qualidade que ainda reduza o
///   arquivo (melhor esforço);
/// - retorna `null` se nenhuma qualidade compensar (imagem já pequena).
BestCompression? chooseBestCompression({
  required int originalBytes,
  required int targetMaxBytes,
  required List<int> qualities,
  required int Function(int quality) sizeFor,
}) {
  for (final quality in qualities) {
    final size = sizeFor(quality);
    if (size <= targetMaxBytes && size < originalBytes) {
      return BestCompression(quality: quality, bytes: size);
    }
  }

  for (final quality in qualities.reversed) {
    final size = sizeFor(quality);
    if (size < originalBytes) {
      return BestCompression(quality: quality, bytes: size);
    }
  }

  return null;
}

/// Comprime uma imagem local antes do upload.
///
/// Tenta webp em 1280px com qualidades [qualityCandidates] e escolhe a
/// melhor dentro do teto [targetMaxBytes]. Se a compressão não compensar
/// (imagem pequena) ou falhar, devolve `null` — o chamador mantém o original.
class ImageCompressor {
  ImageCompressor._();

  /// Teto máximo do arquivo comprimido (~350 KB).
  static const int targetMaxBytes = 350 * 1024;

  /// Dimensão máxima (em pixels) da imagem comprimida.
  static const int maxDimension = 1280;

  /// Qualidades tentadas em ordem decrescente.
  static const List<int> qualityCandidates = [85, 70, 60];

  static Future<File?> compressForUpload(String sourcePath) async {
    final original = File(sourcePath);
    if (!await original.exists()) return null;
    final originalBytes = await original.length();
    if (originalBytes == 0) return null;

    // Comprime cada candidato uma única vez e reutiliza os bytes escolhidos.
    final Map<int, Uint8List?> bytesByQuality = {};
    final Map<int, int> sizesByQuality = {};
    for (final quality in qualityCandidates) {
      final bytes = await _compress(sourcePath, quality);
      bytesByQuality[quality] = bytes;
      sizesByQuality[quality] = bytes?.length ?? 0;
    }

    final choice = chooseBestCompression(
      originalBytes: originalBytes,
      targetMaxBytes: targetMaxBytes,
      qualities: qualityCandidates,
      sizeFor: (quality) => sizesByQuality[quality] ?? 0,
    );

    if (choice == null) return null;

    final bytes = bytesByQuality[choice.quality];
    if (bytes == null) return null;

    final target = File('$sourcePath.webp');
    try {
      await target.writeAsBytes(bytes, flush: true);
      return target;
    } catch (_) {
      return null;
    }
  }

  // Comprime o arquivo em webp e devolve os bytes (ou null se falhar).
  static Future<Uint8List?> _compress(String sourcePath, int quality) async {
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