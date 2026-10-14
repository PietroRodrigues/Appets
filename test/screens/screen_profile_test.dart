import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

import 'package:appets/core/constants/constants_strings_profile.dart';
import 'package:appets/core/constants/constants_strings_shared.dart';
import 'package:appets/core/services/app_image_cache.dart';
import 'package:appets/core/services/auth_service.dart';
import 'package:appets/core/services/connectivity_service.dart';
import 'package:appets/core/services/firestore_service.dart';
import 'package:appets/core/services/image_compressor.dart';
import 'package:appets/core/services/storage_service.dart';
import 'package:appets/screens/screen_profile.dart';
import 'package:appets/widgets/feedback/widget_process.dart';

/// GoogleSignIn que falha no signOut (simula logout sem rede).
class _ThrowingGoogleSignIn extends GoogleSignIn {
  @override
  Future<GoogleSignInAccount?> signOut() async =>
      throw StateError('google fora');
}

/// Cache de imagens falso: não toca disco/plugin nos testes.
class _FakeImageCache implements BaseCacheManager {
  @override
  Future<void> emptyCache() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

/// Provedor de e-mail/senha para simular contas com senha.
UserInfo _passwordProvider(String uid, String email) => UserInfo.fromPigeon(
  PigeonUserInfo(
    uid: uid,
    email: email,
    isAnonymous: false,
    isEmailVerified: true,
    providerId: 'password',
  ),
);

/// Provedor do Google para simular contas logadas com o Google.
UserInfo _googleProvider(String uid, String email) => UserInfo.fromPigeon(
  PigeonUserInfo(
    uid: uid,
    email: email,
    isAnonymous: false,
    isEmailVerified: true,
    providerId: 'google.com',
  ),
);

/// Picker fake que devolve sempre a mesma foto local (evita o plugin real).
class _PickerReturnsFile extends ImagePickerPlatform {
  _PickerReturnsFile(this.path);

  final String path;

  @override
  Future<XFile?> getImageFromSource({
    required ImageSource source,
    ImagePickerOptions options = const ImagePickerOptions(),
  }) async {
    return XFile(path);
  }
}

/// Storage fake do avatar: registra uploads e exclusões por URL.
class _FakeStorage implements FirebaseStorage {
  final List<String> uploadedPaths = [];
  final List<String> deletedUrls = [];

  String downloadUrl = 'https://cdn.example.com/avatar.webp';

  /// Quando definido, o upload lança este erro (simula permission-denied).
  Object? putError;

  /// Quando definido, o upload só conclui após [putGate] ser completado
  /// (segura a tela de loading para testar o bloqueio da interface).
  Completer<void>? putGate;

  @override
  Reference ref([String? path]) => _FakeAvatarReference(this, path: path);

  @override
  Reference refFromURL(String url) => _FakeAvatarReference(this, fromUrl: url);

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _FakeAvatarReference implements Reference {
  _FakeAvatarReference(this.storage, {this.path, this.fromUrl});

  @override
  final _FakeStorage storage;
  final String? path;
  final String? fromUrl;

  @override
  Reference child(String childPath) => _FakeAvatarReference(
    storage,
    path: path == null ? childPath : '$path/$childPath',
  );

  @override
  UploadTask putFile(File file, [SettableMetadata? metadata]) {
    final error = storage.putError;
    if (error != null) throw error;
    storage.uploadedPaths.add(path ?? '');
    return _FakeAvatarUploadTask(gate: storage.putGate?.future);
  }

  @override
  Future<void> delete() async {
    if (fromUrl != null) storage.deletedUrls.add(fromUrl!);
  }

  @override
  Future<String> getDownloadURL() async => storage.downloadUrl;

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _FakeAvatarUploadTask implements UploadTask {
  _FakeAvatarUploadTask({Future<void>? gate})
    : _future = gate == null
          ? Future<TaskSnapshot>.value(_FakeTaskSnapshot())
          : gate.then((_) => _FakeTaskSnapshot());

  final Future<TaskSnapshot> _future;

  @override
  Future<R> then<R>(
    FutureOr<R> Function(TaskSnapshot) onValue, {
    Function? onError,
  }) => _future.then(onValue, onError: onError);

  @override
  Future<TaskSnapshot> catchError(
    Function onError, {
    bool Function(Object)? test,
  }) => _future.catchError(onError, test: test);

  @override
  Future<TaskSnapshot> whenComplete(FutureOr<void> Function() action) =>
      _future.whenComplete(action);

  @override
  Future<TaskSnapshot> timeout(
    Duration timeLimit, {
    FutureOr<TaskSnapshot> Function()? onTimeout,
  }) => _future.timeout(timeLimit, onTimeout: onTimeout);

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _FakeTaskSnapshot implements TaskSnapshot {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

/// Aguarda [condition] virar verdadeira bombeando frames, para uso dentro de
/// [WidgetTester.runAsync].
///
/// Intercala o pump de frames com um atraso real, dando chance ao event loop
/// de concluir o I/O real (compressão/leitura da foto) que a task do loading
/// dispara só depois que a rota monta.
Future<void> _pumpUntilReal(
  WidgetTester tester,
  bool Function() condition, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    await tester.pump();
    await Future<void>.delayed(const Duration(milliseconds: 20));
    if (condition()) return;
  }
  fail('Condição não atingida dentro de ${timeout.inSeconds}s');
}

void main() {
  late FakeFirebaseFirestore db;

  setUp(() {
    db = FakeFirebaseFirestore();
    FirestoreService.instance.debugDb = db;
    FirestoreService.instance.debugGetUserError = null;
    AppImageCache.instance.debugManager = _FakeImageCache();
    // O fluxo do avatar roda via pushProcess (guarda de rede): online por
    // padrão; os testes que cobrem offline ajustam se necessário.
    ConnectivityService.instance.debugOnline = true;
  });

  tearDown(() {
    FirestoreService.instance.debugDb = null;
    FirestoreService.instance.debugGetUserError = null;
    AppImageCache.instance.debugManager = null;
    StorageService.instance.debugStorage = null;
    ImageCompressor.debugCompress = null;
    ConnectivityService.instance.reset();
  });

  Future<void> pumpProfile(
    WidgetTester tester, {
    MockUser? user,
    String photoUrl = '',
  }) async {
    AuthService.instance.debugAuth = MockFirebaseAuth(
      signedIn: true,
      mockUser: user ?? MockUser(uid: 'uid_1'),
    );

    await db.collection('users').doc('uid_1').set({
      'name': 'Ana',
      'email': 'ana@test.com',
      'phone': '(11) 99999-9999',
      'address': 'São Paulo',
      'photoUrl': photoUrl,
      'favoritePetIds': <String>[],
      'myPublishedPetIds': <String>[],
    });

    await tester.pumpWidget(
      MaterialApp(
        routes: {
          '/login': (_) => const Scaffold(body: Text('login screen')),
        },
        home: const Scaffold(body: ProfileScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  //226
  testWidgets('sem erros: carrega e mostra o nome do usuário', (tester) async {
    await pumpProfile(tester);

    expect(find.text('Ana'), findsOneWidget);
    expect(find.text(SharedStrings.LOAD_DATA_ERROR_TITLE), findsNothing);
  });

  //227
  testWidgets('logout navega para o login mesmo se o Google falhar', (
    tester,
  ) async {
    AuthService.instance.debugGoogle = _ThrowingGoogleSignIn();

    await pumpProfile(tester);

    await tester.tap(find.byIcon(Icons.logout));
    await tester.pumpAndSettle();

    // Confirma no diálogo de confirmação do logout.
    await tester.tap(find.text(SharedStrings.YES));
    await tester.pumpAndSettle();

    // Mesmo com o Google falhando, o Firebase saiu e a navegação segue.
    expect(find.text('login screen'), findsOneWidget);
  });

  //228
  testWidgets('falha na carga mostra estado de erro e o retry recarrega', (
    tester,
  ) async {
    FirestoreService.instance.debugGetUserError = StateError('falha');

    await pumpProfile(tester);

    expect(find.text(SharedStrings.LOAD_DATA_ERROR_TITLE), findsOneWidget);
    expect(find.text('Ana'), findsNothing);

    // Recupera a conexão e tenta de novo.
    FirestoreService.instance.debugGetUserError = null;
    await tester.tap(find.text('Tentar de novo'));
    await tester.pumpAndSettle();

    expect(find.text(SharedStrings.LOAD_DATA_ERROR_TITLE), findsNothing);
    expect(find.text('Ana'), findsOneWidget);
  });

  //609
  testWidgets('e-mail/senha: escolher da galeria envia e grava a URL', (
    tester,
  ) async {
    // Foto local real: a compressão lê o arquivo (I/O real).
    final tempDir = Directory.systemTemp.createTempSync('appets_avatar');
    final photoPath = '${tempDir.path}${Platform.pathSeparator}avatar.jpg';
    File(photoPath).writeAsBytesSync(List<int>.filled(100 * 1024, 1));
    addTearDown(() {
      if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
    });

    final storage = _FakeStorage();
    StorageService.instance.debugStorage = storage;
    // Compressão sem o plugin: gera um webp menor que o original.
    ImageCompressor.debugCompress = (_, _) async => Uint8List(10 * 1024);

    final originalPicker = ImagePickerPlatform.instance;
    ImagePickerPlatform.instance = _PickerReturnsFile(photoPath);
    addTearDown(() => ImagePickerPlatform.instance = originalPicker);

    await pumpProfile(
      tester,
      user: MockUser(
        uid: 'uid_1',
        providerData: [_passwordProvider('uid_1', 'ana@test.com')],
      ),
    );

    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();

    // Sem foto: o painel oferece só a galeria (nada de remover).
    expect(find.text(ProfileStrings.AVATAR_GALLERY_OPTION), findsOneWidget);
    expect(find.text(ProfileStrings.AVATAR_REMOVE_OPTION), findsNothing);

    // Dispara a escolha dentro de runAsync: além do picker, o fluxo roda o
    // I/O real da compressão numa task que só começa depois que a rota de
    // loading monta. Por isso os frames são bombeados aqui dentro (o I/O real
    // não avança no FakeAsync dos testWidgets).
    await tester.runAsync(() async {
      await tester.tap(find.text(ProfileStrings.AVATAR_GALLERY_OPTION));
      await _pumpUntilReal(
        tester,
        () => find.text(ProfileStrings.AVATAR_SUCCESS).evaluate().isNotEmpty,
      );
    });

    expect(
      storage.uploadedPaths.single,
      matches(r'^avatars/uid_1/avatar_\d+\.webp$'),
    );
    expect(find.text(ProfileStrings.AVATAR_SUCCESS), findsOneWidget);

    final doc = await db.collection('users').doc('uid_1').get();
    expect(doc.data()!['photoUrl'], 'https://cdn.example.com/avatar.webp');
  });

  //620
  testWidgets(
    'e-mail/senha: trocar foto envia versão nova e apaga só a antiga',
    (tester) async {
      // Foto local real: a compressão lê o arquivo (I/O real).
      final tempDir = Directory.systemTemp.createTempSync('appets_avatar_swap');
      final photoPath = '${tempDir.path}${Platform.pathSeparator}avatar.jpg';
      File(photoPath).writeAsBytesSync(List<int>.filled(100 * 1024, 1));
      addTearDown(() {
        if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
      });

      const oldUrl = 'https://cdn.example.com/old_avatar.webp';
      final storage = _FakeStorage();
      StorageService.instance.debugStorage = storage;
      // Compressão sem o plugin: gera um webp menor que o original.
      ImageCompressor.debugCompress = (_, _) async => Uint8List(10 * 1024);

      final originalPicker = ImagePickerPlatform.instance;
      ImagePickerPlatform.instance = _PickerReturnsFile(photoPath);
      addTearDown(() => ImagePickerPlatform.instance = originalPicker);

      await pumpProfile(
        tester,
        photoUrl: oldUrl,
        user: MockUser(
          uid: 'uid_1',
          providerData: [_passwordProvider('uid_1', 'ana@test.com')],
        ),
      );

      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      // Com foto: o painel oferece galeria e remoção.
      expect(find.text(ProfileStrings.AVATAR_GALLERY_OPTION), findsOneWidget);

      await tester.runAsync(() async {
        await tester.tap(find.text(ProfileStrings.AVATAR_GALLERY_OPTION));
        await _pumpUntilReal(
          tester,
          () => find.text(ProfileStrings.AVATAR_SUCCESS).evaluate().isNotEmpty,
        );
      });

      // A troca envia um arquivo NOVO (path versionado) e apaga apenas a
      // versão anterior — nunca o avatar recém-enviado.
      expect(storage.deletedUrls, [oldUrl]);
      expect(
        storage.uploadedPaths.single,
        matches(r'^avatars/uid_1/avatar_\d+\.webp$'),
      );

      final doc = await db.collection('users').doc('uid_1').get();
      expect(doc.data()!['photoUrl'], 'https://cdn.example.com/avatar.webp');
    },
  );

  //610
  testWidgets('e-mail/senha: remover foto limpa o campo e apaga do Storage', (
    tester,
  ) async {
    const oldUrl = 'https://cdn.example.com/old_avatar.webp';
    final storage = _FakeStorage();
    StorageService.instance.debugStorage = storage;

    await pumpProfile(
      tester,
      photoUrl: oldUrl,
      user: MockUser(
        uid: 'uid_1',
        providerData: [_passwordProvider('uid_1', 'ana@test.com')],
      ),
    );

    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();

    // Com foto: além da galeria, aparece a opção de remover.
    expect(find.text(ProfileStrings.AVATAR_REMOVE_OPTION), findsOneWidget);

    await tester.tap(find.text(ProfileStrings.AVATAR_REMOVE_OPTION));
    await tester.pumpAndSettle();

    await tester.tap(find.text(SharedStrings.YES));
    await tester.pumpAndSettle();

    expect(find.text(ProfileStrings.AVATAR_REMOVE_SUCCESS), findsOneWidget);

    final doc = await db.collection('users').doc('uid_1').get();
    expect(doc.data()!['photoUrl'], '');
    expect(storage.deletedUrls, [oldUrl]);
  });

  //611
  testWidgets('conta Google: tocar no avatar avisa que é gerenciada', (
    tester,
  ) async {
    await pumpProfile(
      tester,
      photoUrl: 'https://cdn.example.com/google.webp',
      user: MockUser(
        uid: 'uid_1',
        providerData: [_googleProvider('uid_1', 'ana@gmail.com')],
      ),
    );

    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();

    expect(find.text(ProfileStrings.AVATAR_GOOGLE_TITLE), findsOneWidget);
    expect(find.text(ProfileStrings.AVATAR_GALLERY_OPTION), findsNothing);
  });

  //614
  testWidgets('e-mail/senha: falha de permissão no upload avisa o usuário', (
    tester,
  ) async {
    final tempDir = Directory.systemTemp.createTempSync('appets_avatar_perm');
    final photoPath = '${tempDir.path}${Platform.pathSeparator}avatar.jpg';
    File(photoPath).writeAsBytesSync(List<int>.filled(100 * 1024, 1));
    addTearDown(() {
      if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
    });

    final storage = _FakeStorage()
      ..putError = FirebaseException(
        plugin: 'firebase_storage',
        code: 'permission-denied',
      );
    StorageService.instance.debugStorage = storage;
    ImageCompressor.debugCompress = (_, _) async => Uint8List(10 * 1024);

    final originalPicker = ImagePickerPlatform.instance;
    ImagePickerPlatform.instance = _PickerReturnsFile(photoPath);
    addTearDown(() => ImagePickerPlatform.instance = originalPicker);

    await pumpProfile(
      tester,
      user: MockUser(
        uid: 'uid_1',
        providerData: [_passwordProvider('uid_1', 'ana@test.com')],
      ),
    );

    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();

    await tester.runAsync(() async {
      await tester.tap(find.text(ProfileStrings.AVATAR_GALLERY_OPTION));
      await _pumpUntilReal(
        tester,
        () => find
            .textContaining(SharedStrings.PERMISSION_DENIED_HINT)
            .evaluate()
            .isNotEmpty,
      );
    });

    // Mostra a mensagem do fluxo com a dica específica de permissão.
    expect(
      find.textContaining(SharedStrings.PERMISSION_DENIED_HINT),
      findsOneWidget,
    );
    expect(
      find.textContaining(ProfileStrings.AVATAR_UPLOAD_ERROR),
      findsOneWidget,
    );
    expect(find.byType(WGProcessLoadingScreen), findsNothing);
  });

  //615
  testWidgets('e-mail/senha: falha de rede no upload avisa o usuário', (
    tester,
  ) async {
    final tempDir = Directory.systemTemp.createTempSync('appets_avatar_net');
    final photoPath = '${tempDir.path}${Platform.pathSeparator}avatar.jpg';
    File(photoPath).writeAsBytesSync(List<int>.filled(100 * 1024, 1));
    addTearDown(() {
      if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
    });

    final storage = _FakeStorage()
      ..putError = FirebaseException(
        plugin: 'firebase_storage',
        code: 'unavailable',
      );
    StorageService.instance.debugStorage = storage;
    ImageCompressor.debugCompress = (_, _) async => Uint8List(10 * 1024);

    final originalPicker = ImagePickerPlatform.instance;
    ImagePickerPlatform.instance = _PickerReturnsFile(photoPath);
    addTearDown(() => ImagePickerPlatform.instance = originalPicker);

    await pumpProfile(
      tester,
      user: MockUser(
        uid: 'uid_1',
        providerData: [_passwordProvider('uid_1', 'ana@test.com')],
      ),
    );

    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();

    await tester.runAsync(() async {
      await tester.tap(find.text(ProfileStrings.AVATAR_GALLERY_OPTION));
      await _pumpUntilReal(
        tester,
        () => find
            .textContaining(SharedStrings.NO_CONNECTION_DESCRIPTION)
            .evaluate()
            .isNotEmpty,
      );
    });

    // Mostra a mensagem do fluxo com a dica específica de conexão.
    expect(
      find.textContaining(SharedStrings.NO_CONNECTION_DESCRIPTION),
      findsOneWidget,
    );
    expect(
      find.textContaining(ProfileStrings.AVATAR_UPLOAD_ERROR),
      findsOneWidget,
    );
    expect(find.byType(WGProcessLoadingScreen), findsNothing);
  });

  //616
  testWidgets('e-mail/senha: upload bloqueia a interface com o loading', (
    tester,
  ) async {
    final tempDir = Directory.systemTemp.createTempSync('appets_avatar_lock');
    final photoPath = '${tempDir.path}${Platform.pathSeparator}avatar.jpg';
    File(photoPath).writeAsBytesSync(List<int>.filled(100 * 1024, 1));
    addTearDown(() {
      if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
    });

    // Upload preso no gate: a tela de loading fica visível até liberarmos.
    final storage = _FakeStorage()..putGate = Completer<void>();
    StorageService.instance.debugStorage = storage;
    ImageCompressor.debugCompress = (_, _) async => Uint8List(10 * 1024);

    final originalPicker = ImagePickerPlatform.instance;
    ImagePickerPlatform.instance = _PickerReturnsFile(photoPath);
    addTearDown(() => ImagePickerPlatform.instance = originalPicker);

    await pumpProfile(
      tester,
      user: MockUser(
        uid: 'uid_1',
        providerData: [_passwordProvider('uid_1', 'ana@test.com')],
      ),
    );

    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();

    await tester.runAsync(() async {
      await tester.tap(find.text(ProfileStrings.AVATAR_GALLERY_OPTION));
      await _pumpUntilReal(
        tester,
        () => find.byType(WGProcessLoadingScreen).evaluate().isNotEmpty,
      );

      // Tela de loading em primeiro plano, cobrindo toda a interface.
      expect(find.byType(WGProcessLoadingScreen), findsOneWidget);
      expect(find.text(ProfileStrings.AVATAR_UPLOADING), findsOneWidget);

      // Um toque na opção de logout (por trás do loading) não abre a
      // confirmação: a interface está bloqueada.
      await tester.tap(
        find.text(ProfileStrings.LOGOUT_OPTION),
        warnIfMissed: false,
      );
      await tester.pump();
      expect(find.text(ProfileStrings.LOGOUT_TITLE), findsNothing);

      // Libera o upload: o fluxo conclui e o loading sai.
      storage.putGate!.complete();
      await _pumpUntilReal(
        tester,
        () => find.text(ProfileStrings.AVATAR_SUCCESS).evaluate().isNotEmpty,
      );
    });

    expect(find.byType(WGProcessLoadingScreen), findsNothing);
    expect(find.text(ProfileStrings.AVATAR_SUCCESS), findsOneWidget);
  });
}
