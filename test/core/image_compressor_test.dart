import 'package:flutter_test/flutter_test.dart';

import 'package:appets/core/constants/constants_strings_publish.dart';
import 'package:appets/core/services/app_image_cache.dart';
import 'package:appets/core/services/image_compressor.dart';

void main() {
  group('chooseBestCompression', () {
    const target = ImageCompressor.targetMaxBytes; // 350 * 1024
    const original = 5 * 1024 * 1024; // 5 MB

    test('escolhe a maior qualidade que caiba no teto', () {
      final choice = chooseBestCompression(
        originalBytes: original,
        targetMaxBytes: target,
        qualities: ImageCompressor.qualityCandidates,
        sizeFor: (quality) => switch (quality) {
          85 => 420 * 1024,
          70 => 300 * 1024,
          _ => 250 * 1024,
        },
      );

      expect(choice, isNotNull);
      expect(choice!.quality, 70);
      expect(choice.bytes, 300 * 1024);
    });

    test('aceita tamanho exatamente igual ao teto', () {
      final choice = chooseBestCompression(
        originalBytes: original,
        targetMaxBytes: target,
        qualities: ImageCompressor.qualityCandidates,
        sizeFor: (quality) => switch (quality) {
          85 => target,
          _ => 200 * 1024,
        },
      );

      expect(choice, isNotNull);
      expect(choice!.quality, 85);
      expect(choice.bytes, target);
    });

    test('nenhuma cabe no teto: usa a menor qualidade que ainda reduza',
        () {
      final choice = chooseBestCompression(
        originalBytes: original,
        targetMaxBytes: target,
        qualities: ImageCompressor.qualityCandidates,
        sizeFor: (quality) => switch (quality) {
          85 => 600 * 1024,
          70 => 500 * 1024,
          _ => 400 * 1024,
        },
      );

      expect(choice, isNotNull);
      expect(choice!.quality, 60);
      expect(choice.bytes, 400 * 1024);
    });

    test('nenhuma qualidade reduz: retorna null (manter original)', () {
      final choice = chooseBestCompression(
        originalBytes: original,
        targetMaxBytes: target,
        qualities: ImageCompressor.qualityCandidates,
        sizeFor: (quality) => original + 100 * 1024,
      );

      expect(choice, isNull);
    });

    test('imagem já menor que o teto pode manter o original', () {
      final choice = chooseBestCompression(
        originalBytes: 200 * 1024,
        targetMaxBytes: target,
        qualities: ImageCompressor.qualityCandidates,
        sizeFor: (quality) => 210 * 1024,
      );

      expect(choice, isNull);
    });
  });

  group('guarda de "imagem muito grande"', () {
    test('limite é 5 MB (alinhado ao Storage)', () {
      expect(PublishStrings.IMAGE_TOO_LARGE_MAX_MB, 5);
    });

    test('mensagem cita o limite em MB', () {
      final message = PublishStrings.photoTooLargeMessage();

      expect(
        message,
        contains('${PublishStrings.IMAGE_TOO_LARGE_MAX_MB} MB'),
      );
    });

    test('título do alerta', () {
      expect(PublishStrings.PHOTO_TOO_LARGE_TITLE, 'Imagem muito grande');
    });
  });

  group('AppImageCache', () {
    test('configura 300 objetos e 30 dias de validade', () {
      expect(AppImageCache.maxNrOfCacheObjects, 300);
      expect(AppImageCache.stalePeriod, const Duration(days: 30));
      expect(AppImageCache.cacheKey, 'petImageCache');
    });
  });
}