import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:appets/core/constants/constants_strings_auth.dart';
import 'package:appets/core/constants/constants_strings_profile.dart';
import 'package:appets/core/constants/constants_strings_shared.dart';
import 'package:appets/core/services/auth_service.dart';
import 'package:appets/core/services/firestore_service.dart';
import 'package:appets/screens/screen_account_data.dart';

// Os mocks do firebase_auth_mocks já declaram campos não-finais.
// ignore_for_file: must_be_immutable

/// MockUser que conta as chamadas de updatePassword.
class _TrackingUser extends MockUser {
  _TrackingUser({super.uid, super.email, super.providerData});

  int updatePasswordCalls = 0;

  @override
  Future<void> updatePassword(String newPassword) async {
    updatePasswordCalls++;
  }
}

/// MockUser cuja reautenticação por senha sempre falha.
class _FailingReauthUser extends _TrackingUser {
  _FailingReauthUser({super.uid, super.email, super.providerData});

  @override
  Future<UserCredential> reauthenticateWithCredential(
    AuthCredential? credential,
  ) async {
    throw FirebaseAuthException(
      code: 'invalid-credential',
      message: 'Senha incorreta.',
    );
  }
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

Widget _buildApp() => const MaterialApp(home: AccountDataScreen());

/// Prepara os serviços e renderiza a tela logada com [user].
Future<void> _pumpScreen(WidgetTester tester, MockUser user) async {
  final db = FakeFirebaseFirestore();
  FirestoreService.instance.debugDb = db;
  AuthService.instance.debugAuth = MockFirebaseAuth(
    signedIn: true,
    mockUser: user,
  );

  await db.collection('users').doc(user.uid).set({
    'name': 'Ana',
    'email': user.email,
    'phone': '(11) 99999-9999',
    'address': 'São Paulo',
    'photoUrl': '',
    'favoritePetIds': <String>[],
    'myPublishedPetIds': <String>[],
  });

  await tester.pumpWidget(_buildApp());
  await tester.pumpAndSettle();
}

/// Digita [text] no campo do diálogo e confirma (botão "Sim").
Future<void> _enterTextAndConfirm(WidgetTester tester, String text) async {
  await tester.enterText(find.byType(TextField), text);
  await tester.pumpAndSettle();
  await tester.tap(find.text(SharedStrings.YES));
  await tester.pumpAndSettle();
}

void main() {
  tearDown(() => FirestoreService.instance.debugGetUserError = null);
  testWidgets('conta Google: tile de alterar senha fica bloqueado', (
    tester,
  ) async {
    await _pumpScreen(tester, MockUser(uid: 'uid_1', email: 'ana@gmail.com'));

    final tile = find.text(ProfileStrings.CHANGE_PASSWORD);
    expect(tile, findsOneWidget);

    // O toque no tile bloqueado não abre nenhum diálogo.
    await tester.tap(tile);
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsNothing);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('conta com senha: fluxo completo altera a senha', (tester) async {
    final tracking = _TrackingUser(
      uid: 'uid_1',
      email: 'a@test.com',
      providerData: [_passwordProvider('uid_1', 'a@test.com')],
    );
    await _pumpScreen(tester, tracking);

    await tester.tap(find.text(ProfileStrings.CHANGE_PASSWORD));
    await tester.pumpAndSettle();

    // Passo 1: senha atual.
    await _enterTextAndConfirm(tester, '123456');
    // Passo 2: nova senha.
    await _enterTextAndConfirm(tester, '654321');
    // Passo 3: confirmação (igual à nova senha).
    await _enterTextAndConfirm(tester, '654321');

    expect(find.text(ProfileStrings.CHANGE_PASSWORD_SUCCESS), findsOneWidget);
    expect(tracking.updatePasswordCalls, 1);
  });

  testWidgets('conta com senha: senha atual incorreta aborta o fluxo', (
    tester,
  ) async {
    final failing = _FailingReauthUser(
      uid: 'uid_1',
      email: 'a@test.com',
      providerData: [_passwordProvider('uid_1', 'a@test.com')],
    );
    await _pumpScreen(tester, failing);

    await tester.tap(find.text(ProfileStrings.CHANGE_PASSWORD));
    await tester.pumpAndSettle();

    await _enterTextAndConfirm(tester, 'errada');

    expect(find.text(AuthStrings.WRONG_PASSWORD_MESSAGE), findsOneWidget);
    expect(failing.updatePasswordCalls, 0);
  });

  testWidgets(
    'falha na carga sai do loading e mostra estado de erro com retry',
    (tester) async {
      FirestoreService.instance.debugGetUserError = StateError('falha');

      await _pumpScreen(tester, MockUser(uid: 'uid_1'));

      expect(find.text(SharedStrings.LOAD_DATA_ERROR_TITLE), findsOneWidget);

      // Recupera a conexão e tenta de novo: recarrega e mostra o conteúdo.
      FirestoreService.instance.debugGetUserError = null;
      await tester.tap(find.text('Tentar de novo'));
      await tester.pumpAndSettle();

      expect(find.text(SharedStrings.LOAD_DATA_ERROR_TITLE), findsNothing);
      expect(find.text('Ana'), findsWidgets);
    },
  );
}
