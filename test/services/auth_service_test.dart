import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:appets/core/services/auth_service.dart';
import 'package:appets/core/services/firestore_service.dart';
import 'package:appets/models/user_model.dart';

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
    test('currentUser é null e os provedores devolvem false', () {
      expect(service.currentUser, isNull);
      expect(service.usesPasswordProvider, isFalse);
      expect(service.usesGoogleProvider, isFalse);
    });

    test('reauthenticateWithPassword sem usuário é um no-op', () async {
      await service.reauthenticateWithPassword('senha');
    });

    test('reauthenticateWithGoogle sem usuário devolve false', () async {
      expect(await service.reauthenticateWithGoogle(), isFalse);
    });

    test('deleteAccount sem usuário é um no-op', () async {
      await service.deleteAccount();
    });
  });

  group('AuthService · registro e login', () {
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

    test('login autentica o usuário', () async {
      final credential = await service.login(
        email: 'a@test.com',
        password: '123456',
      );

      expect(credential.user, isNotNull);
      expect(service.currentUser, isNotNull);
    });

    test('sendPasswordResetEmail conclui sem erro', () async {
      await service.sendPasswordResetEmail('a@test.com');
    });
  });

  group('AuthService · operações com usuário logado', () {
    setUp(() async {
      await service.register(email: 'a@test.com', password: '123456');
    });

    test('reauthenticateWithPassword conclui com o usuário logado', () async {
      await service.reauthenticateWithPassword('123456');
    });

    test('updateDisplayName atualiza o nome do usuário', () async {
      await service.updateDisplayName('Ana Silva');

      expect(service.currentUser!.displayName, 'Ana Silva');
    });

    test('updatePassword conclui com o usuário logado', () async {
      await service.updatePassword('654321');
    });

    test('deleteAccount exclui a conta logada', () async {
      await service.deleteAccount();
    });

    test('logout desconecta o Firebase Auth', () async {
      await service.logout();

      expect(service.currentUser, isNull);
    });

    test('logout garante o signOut do Firebase mesmo se o Google falhar', () async {
      service.debugGoogle = _ThrowingGoogleSignIn();

      // O erro do Google se propaga após o finally, mas o Firebase já saiu.
      await expectLater(service.logout(), throwsA(isA<StateError>()));

      expect(service.currentUser, isNull);
    });
  });

  group('AuthService · waitFirstAuthState', () {
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

    test('lança quando o hook debugAuthStateError está definido', () {
      service.debugAuthStateError = StateError('auth quebrado');

      expect(() => service.waitFirstAuthState(), throwsA(isA<StateError>()));
    });
  });

  group('AuthService · ensureUserDocument', () {
    const user = UserModel(id: 'uid_1', name: 'Ana', email: 'ana@test.com');

    test('cria o documento quando ele não existe', () async {
      final result = await service.ensureUserDocument(user);

      expect(result.id, 'uid_1');
      final doc = await db.collection('users').doc('uid_1').get();
      expect(doc.exists, isTrue);
      expect(doc.get('name'), 'Ana');
    });

    test('devolve o usuário persistido quando o documento já existe', () async {
      await db.collection('users').doc('uid_1').set({
        'name': 'Versão Persistida',
        'email': 'persistido@test.com',
        'phone': '',
        'address': '',
        'photoUrl': '',
        'favoritePetIds': <String>[],
        'myPublishedPetIds': <String>[],
      });

      final result = await service.ensureUserDocument(user);

      expect(result.name, 'Versão Persistida');
      expect(result.email, 'persistido@test.com');
    });
  });
}
