import 'dart:async';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:appets/core/services/storage_service.dart';

/// Storage fake que captura o caminho e os metadados do último upload.
class _FakeStorage implements FirebaseStorage {
  _FakeStorage(this.downloadUrl);

  final String downloadUrl;
  String? lastPath;
  SettableMetadata? lastMetadata;
  bool putCalled = false;

  @override
  Reference ref([String? path]) => _FakeReference(storage: this);

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _FakeReference implements Reference {
  _FakeReference({required this.storage, this.path});

  @override
  final _FakeStorage storage;
  final String? path;

  @override
  Reference child(String childPath) => _FakeReference(
        storage: storage,
        path: path == null ? childPath : '$path/$childPath',
      );

  @override
  UploadTask putFile(File file, [SettableMetadata? metadata]) {
    storage.lastPath = path;
    storage.lastMetadata = metadata;
    storage.putCalled = true;
    return _FakeUploadTask();
  }

  @override
  Future<String> getDownloadURL() async => storage.downloadUrl;

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

/// UploadTask é um Future&lt;TaskSnapshot&gt;: conclui imediatamente.
class _FakeUploadTask implements UploadTask {
  _FakeUploadTask() : _future = Future<TaskSnapshot>.value(_FakeTaskSnapshot());

  final Future<TaskSnapshot> _future;

  @override
  Future<R> then<R>(
    FutureOr<R> Function(TaskSnapshot) onValue, {
    Function? onError,
  }) =>
      _future.then(onValue, onError: onError);

  @override
  Future<TaskSnapshot> catchError(
    Function onError, {
    bool Function(Object)? test,
  }) =>
      _future.catchError(onError, test: test);

  @override
  Future<TaskSnapshot> whenComplete(FutureOr<void> Function() action) =>
      _future.whenComplete(action);

  @override
  Future<TaskSnapshot> timeout(
    Duration timeLimit, {
    FutureOr<TaskSnapshot> Function()? onTimeout,
  }) =>
      _future.timeout(timeLimit, onTimeout: onTimeout);

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _FakeTaskSnapshot implements TaskSnapshot {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

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

  group('StorageService · upload', () {
    test('envia com a extensão do arquivo e devolve a URL', () async {
      final storage = _FakeStorage('https://cdn.example.com/foto.webp');
      service.debugStorage = storage;
      addTearDown(() => service.debugStorage = null);

      // Só o caminho do arquivo é lido (não há I/O real).
      final url = await service.uploadPetImage(
        'dono_1',
        'pet_1',
        2,
        File('foto.webp'),
      );

      expect(url, 'https://cdn.example.com/foto.webp');
      expect(storage.putCalled, isTrue);
      expect(storage.lastPath, 'pets/dono_1/pet_1/photo_2.webp');
      expect(storage.lastMetadata?.contentType, 'image/webp');
    });

    test('normaliza a extensão para minúsculas (PNG → image/png)', () async {
      final storage = _FakeStorage('https://cdn.example.com/foto.png');
      service.debugStorage = storage;
      addTearDown(() => service.debugStorage = null);

      await service.uploadPetImage('dono_1', 'pet_1', 0, File('FOTO.PNG'));

      expect(storage.lastPath, 'pets/dono_1/pet_1/photo_0.png');
      expect(storage.lastMetadata?.contentType, 'image/png');
    });

    test('extensão desconhecida usa image/jpeg', () async {
      final storage = _FakeStorage('https://cdn.example.com/foto');
      service.debugStorage = storage;
      addTearDown(() => service.debugStorage = null);

      await service.uploadPetImage('dono_1', 'pet_1', 1, File('foto.gif'));

      expect(storage.lastPath, 'pets/dono_1/pet_1/photo_1.gif');
      expect(storage.lastMetadata?.contentType, 'image/jpeg');
    });

    test('sem extensão usa jpg e contentType jpeg', () async {
      final storage = _FakeStorage('https://cdn.example.com/foto.jpg');
      service.debugStorage = storage;
      addTearDown(() => service.debugStorage = null);

      // O trecho após o último ponto fica vazio → fallback para "jpg".
      await service.uploadPetImage('dono_1', 'pet_1', 3, File('foto.'));

      expect(storage.lastPath, 'pets/dono_1/pet_1/photo_3.jpg');
      expect(storage.lastMetadata?.contentType, 'image/jpeg');
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
        'https://firebasestorage.googleapis.com/iconexiste.jpg',
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
