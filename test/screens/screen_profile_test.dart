import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:appets/core/constants/constants_strings_shared.dart';
import 'package:appets/core/services/auth_service.dart';
import 'package:appets/core/services/firestore_service.dart';
import 'package:appets/screens/screen_profile.dart';

/// GoogleSignIn que falha no signOut (simula logout sem rede).
class _ThrowingGoogleSignIn extends GoogleSignIn {
  @override
  Future<GoogleSignInAccount?> signOut() async =>
      throw StateError('google fora');
}

void main() {
  late FakeFirebaseFirestore db;

  setUp(() {
    db = FakeFirebaseFirestore();
    FirestoreService.instance.debugDb = db;
    FirestoreService.instance.debugGetUserError = null;
  });

  tearDown(() {
    FirestoreService.instance.debugDb = null;
    FirestoreService.instance.debugGetUserError = null;
  });

  Future<void> pumpProfile(WidgetTester tester) async {
    AuthService.instance.debugAuth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(uid: 'uid_1'),
    );

    await db.collection('users').doc('uid_1').set({
      'name': 'Ana',
      'email': 'ana@test.com',
      'phone': '(11) 99999-9999',
      'address': 'São Paulo',
      'photoUrl': '',
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

  testWidgets('sem erros: carrega e mostra o nome do usuário', (tester) async {
    await pumpProfile(tester);

    expect(find.text('Ana'), findsOneWidget);
    expect(find.text(SharedStrings.LOAD_DATA_ERROR_TITLE), findsNothing);
  });

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
}
