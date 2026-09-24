import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:appets/core/constants/constants_strings_publish.dart';
import 'package:appets/core/services/app_image_cache.dart';
import 'package:appets/core/services/image_compressor.dart';

void main() {
  group('compressForUpload', () {
    late Directory tempDir;

    setUp(() {
      ImageCompressor.debugCompress = null;
      tempDir = Directory.systemTemp.createTempSync('img_comp_test_');
    });

    tearDown(() {
      ImageCompressor.debugCompress = null;
      try {
        tempDir.deleteSync(recursive: true);
      } catch (_) {
        // Melhor esforço no ambiente de teste.
      }
    });

    Future<File> createOriginal(int size) {
      final file = File(
        '${tempDir.path}${Platform.pathSeparator}orig_$size.bin',
      );
      return file.writeAsBytes(Uint8List(size), flush: true);
    }

    test('arquivo original inexistente: devolve null', () async {
      final result = await ImageCompressor.compressForUpload(
        '${tempDir.path}${Platform.pathSeparator}nao_existe.jpg',
      );

      expect(result, isNull);
    });

    test('arquivo vazio (0 bytes): devolve null sem criar temporário',
        () async {
      final original = await createOriginal(0);

      final result = await ImageCompressor.compressForUpload(original.path);

      expect(result, isNull);
      expect(File('${original.path}.webp').existsSync(), isFalse);
    });

    test('para na primeira qualidade que cabe no teto', () async {
      final original = await createOriginal(5 * 1024 * 1024);
      final calls = <int>[];
      ImageCompressor.debugCompress = (source, quality) async {
        calls.add(quality);
        switch (quality) {
          case 85:
            return Uint8List(450 * 1024); // não cabe (> 350 KB)
          case 70:
            return Uint8List(300 * 1024); // cabe
          case 60:
            return Uint8List(250 * 1024); // não deve ser tentada
          default:
            return Uint8List(0);
        }
      };

      final result = await ImageCompressor.compressForUpload(original.path);

      expect(calls, [85, 70]);
      expect(result, isNotNull);
      expect(result!.path, '${original.path}.webp');
      expect(await result.length(), 300 * 1024);
    });

    test('aceita tamanho exatamente igual ao teto', () async {
      final original = await createOriginal(700 * 1024);
      ImageCompressor.debugCompress = (source, quality) async =>
          Uint8List(ImageCompressor.targetMaxBytes);

      final result = await ImageCompressor.compressForUpload(original.path);

      expect(result, isNotNull);
      expect(result!.path, '${original.path}.webp');
      expect(await result.length(), ImageCompressor.targetMaxBytes);
    });

    test('qualidade que falha é ignorada (não envenena a escolha)', () async {
      final original = await createOriginal(5 * 1024 * 1024);
      ImageCompressor.debugCompress = (source, quality) async {
        switch (quality) {
          case 85:
            return null; // falhou; antigamente virava "size 0" e descartava
          case 70:
            return Uint8List(300 * 1024);
          case 60:
            return Uint8List(250 * 1024);
          default:
            return Uint8List(0);
        }
      };

      final result = await ImageCompressor.compressForUpload(original.path);

      expect(result, isNotNull);
      expect(await result!.length(), 300 * 1024);
    });

    test('nenhuma cabe no teto: usa a menor qualidade que ainda reduza',
        () async {
      final original = await createOriginal(5 * 1024 * 1024);
      ImageCompressor.debugCompress = (source, quality) async {
        switch (quality) {
          case 85:
            return Uint8List(600 * 1024);
          case 70:
            return Uint8List(500 * 1024);
          case 60:
            return Uint8List(400 * 1024);
          default:
            return Uint8List(0);
        }
      };

      final result = await ImageCompressor.compressForUpload(original.path);

      expect(result, isNotNull);
      expect(await result!.length(), 400 * 1024);
    });

    test('nada reduz: devolve null e apaga temporário órfão', () async {
      final original = await createOriginal(1 * 1024 * 1024);
      final orphan = File('${original.path}.webp');
      await orphan.writeAsBytes(Uint8List(100), flush: true);

      ImageCompressor.debugCompress = (source, quality) async =>
          Uint8List(2 * 1024 * 1024); // todas maiores que o original

      final result = await ImageCompressor.compressForUpload(original.path);

      expect(result, isNull);
      expect(await orphan.exists(), isFalse);
    });

    test('imagem já menor que o teto pode manter o original', () async {
      final original = await createOriginal(200 * 1024);
      ImageCompressor.debugCompress = (source, quality) async =>
          Uint8List(210 * 1024); // compressão não reduz

      final result = await ImageCompressor.compressForUpload(original.path);

      expect(result, isNull);
      expect(File('${original.path}.webp').existsSync(), isFalse);
    });
  });

  group('deleteTempWebpFiles', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('img_comp_del_');
    });

    tearDown(() {
      try {
        tempDir.deleteSync(recursive: true);
      } catch (_) {
        // Melhor esforço no ambiente de teste.
      }
    });

    test('apaga só temporários `.webp` e ignora inexistentes/erros', () async {
      final a = File('${tempDir.path}${Platform.pathSeparator}a.webp');
      final png = File('${tempDir.path}${Platform.pathSeparator}foto.png');
      await a.writeAsBytes(Uint8List(10), flush: true);
      await png.writeAsBytes(Uint8List(10), flush: true);

      await ImageCompressor.deleteTempWebpFiles([
        a.path,
        '${tempDir.path}${Platform.pathSeparator}b.webp', // inexistente
        png.path, // não é `.webp` → preservado
      ]);

      expect(await a.exists(), isFalse);
      expect(await png.exists(), isTrue);
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