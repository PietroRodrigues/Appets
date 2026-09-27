import 'package:flutter_test/flutter_test.dart';

import 'package:appets/core/services/storage_service.dart';

void main() {
  final service = StorageService.instance;

  group('StorageService · caminho das fotos', () {
    test('petImagePath constrói o padrão dono→pet→índice', () {
      expect(
        StorageService.petImagePath('dono_1', 'pet_1', 0),
        'pets/dono_1/pet_1/photo_0.jpg',
      );
      expect(
        StorageService.petImagePath('dono_1', 'pet_1', 4),
        'pets/dono_1/pet_1/photo_4.jpg',
      );
    });

    test('petImagePath aceita uma extensão customizada', () {
      expect(
        StorageService.petImagePath('dono_1', 'pet_1', 2, 'webp'),
        'pets/dono_1/pet_1/photo_2.webp',
      );
      expect(
        StorageService.petImagePath('dono_1', 'pet_1', 3, 'png'),
        'pets/dono_1/pet_1/photo_3.png',
      );
    });
  });

  group('StorageService · exclusão em melhor esforço', () {
    test('deletePetImagesByUrls com lista vazia é inofensivo', () async {
      await service.deletePetImagesByUrls([]);
    });

    test('deletePetImagesByUrls ignora falhas de URLs inválidas', () async {
      // Sem Firebase inicializado, qualquer operação de Storage lança;
      // o método deve engolir cada falha e completar normalmente.
      await service.deletePetImagesByUrls([
        'https://firebasestorage.googleapis.com/iconexistente.jpg',
        'url totalmente inválida',
      ]);
    });

    test('deletePetImagesByUrls dispara as exclusões em paralelo', () async {
      service.debugDeleteDelay = const Duration(milliseconds: 20);
      service.debugMaxConcurrentDeletes = 0;

      await service.deletePetImagesByUrls([
        'https://firebasestorage.googleapis.com/um.png',
        'https://firebasestorage.googleapis.com/dois.png',
        'https://firebasestorage.googleapis.com/tres.png',
        'https://firebasestorage.googleapis.com/quatro.png',
        'https://firebasestorage.googleapis.com/cinco.png',
      ]);

      // Sequencial teria pico 1; paralelo fecha o pico de 5.
      expect(service.debugMaxConcurrentDeletes, 5);

      service.debugDeleteDelay = null;
      service.debugMaxConcurrentDeletes = 0;
    });
  });
}