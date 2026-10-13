import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/src/mock_user_credential.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';

import 'package:appets/core/services/auth_service.dart';
import 'package:appets/core/services/firestore_service.dart';
import 'package:appets/models/user_model.dart';

// Os mocks do firebase_auth_mocks já declaram campos não-finais.
// ignore_for_file: must_be_immutable

/// GoogleSignIn falso apenas para o logout suportar o fluxo em testes.
class _FakeGoogleSignIn extends GoogleSignIn {
  @override
  Future<GoogleSignInAccount?> signOut() async => null;
}

/// GoogleSignIn que falha no signOut (simula logout sem rede).
class _ThrowingGoogleSignIn extends GoogleSignIn {
  @override
  Future<GoogleSignInAccount?> signOut() async =>
      throw StateError('google fora');
}

/// GoogleSignIn cujo seletor de conta é cancelado (devolve null).
class _CancelGoogleSignIn extends GoogleSignIn {
  @override
  Future<GoogleSignInAccount?> signIn() async => null;
}

/// Plataforma Google falsa: simula o `signIn` e o `getTokens` nativos sem
/// MethodChannel. Usada com um [GoogleSignIn] real, que monta a
/// [GoogleSignInAccount] a partir do [GoogleSignInUserData].
class _FakeGooglePlatform extends GoogleSignInPlatform {
  _FakeGooglePlatform({
    this.userData,
    this.tokenData,
    this.failSignIn = false,
    this.failTokens = false,
  });

  /// Dados do usuário devolvidos pelo `signIn` (null = sem conta).
  final GoogleSignInUserData? userData;

  /// Tokens devolvidos pelo `getTokens`.
  final GoogleSignInTokenData? tokenData;

  /// Quando `true`, o `signIn` lança (ex.: erro de rede do Google).
  final bool failSignIn;

  /// Quando `true`, o `getTokens` lança (ex.: sessão do Google expirada).
  final bool failTokens;

  @override
  Future<void> initWithParams(SignInInitParameters params) async {}

  @override
  Future<GoogleSignInUserData?> signIn() async {
    if (failSignIn) throw StateError('google fora do ar');
    return userData;
  }

  @override
  Future<GoogleSignInTokenData> getTokens({
    required String email,
    bool? shouldRecoverAuth,
  }) async {
    if (failTokens) throw StateError('tokens indisponíveis');
    return tokenData ?? GoogleSignInTokenData();
  }

  @override
  Future<void> signOut() async {}
}

/// MockUser que conta a reautenticação e guarda a credencial recebida.
class _TrackingReauthUser extends MockUser {
  _TrackingReauthUser({super.uid, super.email});

  int reauthCalls = 0;
  AuthCredential? lastCredential;

  @override
  Future<UserCredential> reauthenticateWithCredential(
    AuthCredential? credential,
  ) {
    reauthCalls++;
    lastCredential = credential;
    return Future.value(MockUserCredential(false, mockUser: this));
  }
}

/// MockUser cuja reautenticação falha: conta Google diferente da logada.
class _MismatchReauthUser extends MockUser {
  _MismatchReauthUser({super.uid, super.email});

  @override
  Future<UserCredential> reauthenticateWithCredential(
    AuthCredential? credential,
  ) async {
    throw FirebaseAuthException(code: 'user-mismatch');
  }
}

/// MockUser que conta as chamadas de updateEmail.
class _TrackingEmailUser extends MockUser {
  _TrackingEmailUser({super.uid, super.email});

  int updateEmailCalls = 0;

  @override
  Future<void> updateEmail(String newEmail) async {
    updateEmailCalls++;
  }
}

/// MockUser que simula uma conta excluída/revogada: o refresh de token
/// (getIdToken com forceRefresh) falha com user-not-found.
class _RevokedUser extends MockUser {
  _RevokedUser({super.uid, super.email});

  @override
  Future<String> getIdToken([bool forceRefresh = false]) async {
    throw FirebaseAuthException(code: 'user-not-found');
  }
}

/// MockUser com sessão restaurada, mas offline: o refresh falha por rede
/// e a sessão de cache deve ser mantida.
class _OfflineUser extends MockUser {
  _OfflineUser({super.uid, super.email});

  @override
  Future<String> getIdToken([bool forceRefresh = false]) async {
    throw FirebaseAuthException(code: 'network-request-failed');
  }
}

void main() {
  late MockFirebaseAuth auth;
  late FakeFirebaseFirestore db;
  final service = AuthService.instance;

  setUp(() {
    auth = MockFirebaseAuth();
    db = FakeFirebaseFirestore();
    service.debugAuth = auth;
    service.debugGoogle = _FakeGoogleSignIn();
    service.debugAuthStateError = null;
    FirestoreService.instance.debugDb = db;
  });

  group('AuthService · estado deslogado', () {
    //252
    test('currentUser é null e os provedores devolvem false', () {
      expect(service.currentUser, isNull);
      expect(service.usesPasswordProvider, isFalse);
      expect(service.usesGoogleProvider, isFalse);
    });

    //253
    test('reauthenticateWithPassword sem usuário é um no-op', () async {
      await service.reauthenticateWithPassword('senha');
    });

    //254
    test('reauthenticateWithGoogle sem usuário devolve false', () async {
      expect(await service.reauthenticateWithGoogle(), isFalse);
    });

    //255
    test('deleteAccount sem usuário é um no-op', () async {
      await service.deleteAccount();
    });
  });

  group('AuthService · registro e login', () {
    //256
    test('register cria a conta com e-mail/senha', () async {
      final credential = await service.register(
        email: 'a@test.com',
        password: '123456',
      );

      expect(credential.user, isNotNull);
      expect(service.currentUser, isNotNull);
      expect(service.currentUser!.email, 'a@test.com');
      expect(service.usesPasswordProvider, isTrue);
      expect(service.usesGoogleProvider, isFalse);
    });

    //257
    test('login autentica o usuário', () async {
      final credential = await service.login(
        email: 'a@test.com',
        password: '123456',
      );

      expect(credential.user, isNotNull);
      expect(service.currentUser, isNotNull);
    });

    //258
    test('sendPasswordResetEmail conclui sem erro', () async {
      await service.sendPasswordResetEmail('a@test.com');
    });

    //259
    test('loginWithGoogle devolve null quando o usuário cancela', () async {
      service.debugGoogle = _CancelGoogleSignIn();

      expect(await service.loginWithGoogle(), isNull);
    });
  });

  group('AuthService · login com Google (fluxo completo)', () {
    GoogleSignInUserData googleUserData() => GoogleSignInUserData(
          email: 'ana@gmail.com',
          id: 'google_1',
          displayName: 'Ana Google',
          idToken: 'id-token-1',
        );

    GoogleSignInTokenData googleTokenData() => GoogleSignInTokenData(
          idToken: 'id-token-1',
          accessToken: 'access-token-1',
        );

    void useFakePlatform({
      GoogleSignInUserData? userData,
      GoogleSignInTokenData? tokenData,
      bool failSignIn = false,
      bool failTokens = false,
    }) {
      final original = GoogleSignInPlatform.instance;
      GoogleSignInPlatform.instance = _FakeGooglePlatform(
        userData: userData,
        tokenData: tokenData,
        failSignIn: failSignIn,
        failTokens: failTokens,
      );
      addTearDown(() => GoogleSignInPlatform.instance = original);
    }

    //260
    test('loginWithGoogle autentica com tokens e credencial do Google',
        () async {
      useFakePlatform(userData: googleUserData(), tokenData: googleTokenData());
      service.debugGoogle = GoogleSignIn();

      final credential = await service.loginWithGoogle();

      expect(credential, isNotNull);
      expect(credential!.user, isNotNull);
      expect(service.currentUser, isNotNull);
    });

    //261
    test('loginWithGoogle propaga erro do signIn do Google', () async {
      useFakePlatform(userData: googleUserData(), failSignIn: true);
      service.debugGoogle = GoogleSignIn();

      await expectLater(
        service.loginWithGoogle(),
        throwsA(isA<StateError>()),
      );
      expect(service.currentUser, isNull);
    });

    //262
    test('loginWithGoogle propaga erro ao obter os tokens', () async {
      useFakePlatform(userData: googleUserData(), failTokens: true);
      service.debugGoogle = GoogleSignIn();

      await expectLater(
        service.loginWithGoogle(),
        throwsA(isA<StateError>()),
      );
      expect(service.currentUser, isNull);
    });

    //263
    test('reauthenticateWithGoogle cancelado devolve false', () async {
      service.debugAuth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'uid_1', email: 'ana@test.com'),
      );
      service.debugGoogle = _CancelGoogleSignIn();

      expect(await service.reauthenticateWithGoogle(), isFalse);
    });

    //264
    test('reauthenticateWithGoogle reautentica com a credencial do Google',
        () async {
      useFakePlatform(userData: googleUserData(), tokenData: googleTokenData());
      final user = _TrackingReauthUser(uid: 'uid_1', email: 'ana@gmail.com');
      service.debugAuth = MockFirebaseAuth(signedIn: true, mockUser: user);
      service.debugGoogle = GoogleSignIn();

      expect(await service.reauthenticateWithGoogle(), isTrue);
      expect(user.reauthCalls, 1);
      expect(user.lastCredential, isA<AuthCredential>());
      expect(
        user.lastCredential!.providerId,
        'google.com',
        reason: 'A reautenticação deve usar o provedor Google.',
      );
    });

    //265
    test('reauthenticateWithGoogle com conta diferente lança user-mismatch',
        () async {
      useFakePlatform(userData: googleUserData(), tokenData: googleTokenData());
      final user = _MismatchReauthUser(uid: 'uid_1', email: 'ana@gmail.com');
      service.debugAuth = MockFirebaseAuth(signedIn: true, mockUser: user);
      service.debugGoogle = GoogleSignIn();

      await expectLater(
        service.reauthenticateWithGoogle(),
        throwsA(
          isA<FirebaseAuthException>().having(
            (e) => e.code,
            'code',
            'user-mismatch',
          ),
        ),
      );
    });
  });

  group('AuthService · authStateChanges', () {
    //266
    test('emite o usuário logado no stream', () async {
      service.debugAuth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'uid_1', email: 'a@test.com'),
      );

      final user = await service.authStateChanges.first;

      expect(user, isNotNull);
      expect(user!.uid, 'uid_1');
    });

    //267
    test('emite null sem usuário logado', () async {
      service.debugAuth = MockFirebaseAuth();

      final user = await service.authStateChanges.first;

      expect(user, isNull);
    });
  });

  group('AuthService · operações com usuário logado', () {
    setUp(() async {
      await service.register(email: 'a@test.com', password: '123456');
    });

    //268
    test('reauthenticateWithPassword conclui com o usuário logado', () async {
      await service.reauthenticateWithPassword('123456');
    });

    //269
    test('updateDisplayName atualiza o nome do usuário', () async {
      await service.updateDisplayName('Ana Silva');

      expect(service.currentUser!.displayName, 'Ana Silva');
    });

    //270
    test('updatePassword conclui com o usuário logado', () async {
      await service.updatePassword('654321');
    });

    //271
    test('changeEmail chama updateEmail do usuário', () async {
      service.debugAuth = MockFirebaseAuth(
        signedIn: true,
        mockUser: _TrackingEmailUser(uid: 'uid_1', email: 'a@test.com'),
      );

      await service.changeEmail('novo@test.com');

      expect((service.currentUser! as _TrackingEmailUser).updateEmailCalls, 1);
    });

    //272
    test('deleteAccount exclui a conta logada', () async {
      await service.deleteAccount();
    });

    //273
    test('logout desconecta o Firebase Auth', () async {
      await service.logout();

      expect(service.currentUser, isNull);
    });

    //274
    test('logout garante o signOut do Firebase mesmo se o Google falhar', () async {
      service.debugGoogle = _ThrowingGoogleSignIn();

      // O erro do Google se propaga após o finally, mas o Firebase já saiu.
      await expectLater(service.logout(), throwsA(isA<StateError>()));

      expect(service.currentUser, isNull);
    });
  });

  group('AuthService · waitFirstAuthState', () {
    //275
    test('devolve o usuário da sessão restaurada', () async {
      // Sessão restaurada: o Firebase real re-emite o usuário atual no
      // subscribe; simulamos com mock já logado.
      service.debugAuth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'uid_1', email: 'b@test.com'),
      );

      final user = await service.waitFirstAuthState();

      expect(user, isNotNull);
      expect(user!.email, 'b@test.com');
    });

    //276
    test('lança quando o hook debugAuthStateError está definido', () {
      service.debugAuthStateError = StateError('auth quebrado');

      expect(service.waitFirstAuthState, throwsA(isA<StateError>()));
    });
  });

  group('AuthService · validateSession', () {
    //277
    test('sem usuário não há sessão para validar', () async {
      service.debugAuth = MockFirebaseAuth();

      expect(await service.validateSession(), isFalse);
    });

    //278
    test('sessão restaurada válida é mantida', () async {
      service.debugAuth = MockFirebaseAuth(
        signedIn: true,
        mockUser: MockUser(uid: 'uid_1', email: 'b@test.com'),
      );

      expect(await service.validateSession(), isTrue);
      expect(service.currentUser, isNotNull);
    });

    //279
    test('conta excluída/revogada encerra a sessão', () async {
      service.debugAuth = MockFirebaseAuth(
        signedIn: true,
        mockUser: _RevokedUser(uid: 'uid_1', email: 'b@test.com'),
      );

      expect(await service.validateSession(), isFalse);
      expect(service.currentUser, isNull);
    });

    //280
    test('erro de rede mantém a sessão de cache', () async {
      service.debugAuth = MockFirebaseAuth(
        signedIn: true,
        mockUser: _OfflineUser(uid: 'uid_1', email: 'b@test.com'),
      );

      expect(await service.validateSession(), isTrue);
      expect(service.currentUser, isNotNull);
    });
  });

  group('AuthService · ensureUserDocument', () {
    const user = UserModel(id: 'uid_1', name: 'Ana', email: 'ana@test.com');

    //281
    test('cria o documento quando ele não existe', () async {
      final result = await service.ensureUserDocument(user);

      expect(result.id, 'uid_1');
      final doc = await db.collection('users').doc('uid_1').get();
      expect(doc.exists, isTrue);
      expect(doc.get('name'), 'Ana');
    });

    //282
    test('merge não sobrescreve favoritos e telefone já gravados', () async {
      await db.collection('users').doc('uid_1').set({
        'name': 'Nome Antigo',
        'email': 'antigo@test.com',
        'phone': '(11) 99999-0000',
        'address': 'Rua A',
        'photoUrl': 'https://foto.example.com/a.png',
        'favoritePetIds': ['pet_a'],
        'myPublishedPetIds': ['pet_b'],
      });

      final result = await service.ensureUserDocument(user);

      // A garantia devolve o modelo gravado...
      expect(result.id, 'uid_1');
      // ...e o doc existente ganha nome/e-mail novos sem perder o resto.
      final doc = await db.collection('users').doc('uid_1').get();
      expect(doc.get('name'), 'Ana');
      expect(doc.get('email'), 'ana@test.com');
      expect(doc.get('phone'), '(11) 99999-0000');
      expect(doc.get('favoritePetIds'), ['pet_a']);
      expect(doc.get('myPublishedPetIds'), ['pet_b']);
    });
  });
}
