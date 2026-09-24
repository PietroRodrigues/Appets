import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:appets/core/constants/constants_strings_shared.dart';
import 'package:appets/core/routes/routes_app.dart';
import 'package:appets/core/services/auth_service.dart';
import 'package:appets/core/services/firestore_service.dart';
import 'package:appets/screens/screen_splash.dart';

// Os mocks do firebase_auth_mocks já declaram campos não-finais.
// ignore_for_file: must_be_immutable

/// MockUser que simula uma conta excluída/revogada: o refresh de token
/// (validação de sessão na splash) falha com user-not-found.
class _RevokedMockUser extends MockUser {
  _RevokedMockUser({super.uid});

  @override
  Future<String> getIdToken([bool forceRefresh = false]) async {
    throw FirebaseAuthException(code: 'user-not-found');
  }
}

void main() {
  setUp(() {
    FirestoreService.instance.debugDb = FakeFirebaseFirestore();
    AuthService.instance.debugAuthStateError = null;
  });

  tearDown(() {
    FirestoreService.instance.debugDb = null;
    AuthService.instance.debugAuth = null;
    AuthService.instance.debugAuthStateError = null;
  });

  Widget buildApp(MockFirebaseAuth auth) {
    AuthService.instance.debugAuth = auth;

    return MaterialApp(
      routes: {
        AppRoutes.splash: (_) => const SplashScreen(),
        AppRoutes.home: (_) => const Scaffold(body: Text('TELA HOME')),
        AppRoutes.login: (_) => const Scaffold(body: Text('TELA LOGIN')),
      },
    );
  }

  Future<void> pumpSplash(WidgetTester tester, MockFirebaseAuth auth) async {
    await tester.pumpWidget(buildApp(auth));
    await tester.pump(const Duration(seconds: 1));
  }

  testWidgets('usuário logado é encaminhado para o Home', (tester) async {
    await pumpSplash(
      tester,
      MockFirebaseAuth(signedIn: true, mockUser: MockUser(uid: 'uid_1')),
    );
    await tester.pumpAndSettle();

    expect(find.text('TELA HOME'), findsOneWidget);
  });

  testWidgets('conta excluída/revogada sai da sessão e vai para o Login', (
    tester,
  ) async {
    await pumpSplash(
      tester,
      MockFirebaseAuth(
        signedIn: true,
        mockUser: _RevokedMockUser(uid: 'uid_1'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('TELA LOGIN'), findsOneWidget);
    expect(find.text('TELA HOME'), findsNothing);
  });

  testWidgets('falha na espera do auth mostra aviso de erro e não navega', (
    tester,
  ) async {
    AuthService.instance.debugAuthStateError = StateError('auth quebrado');

    await pumpSplash(tester, MockFirebaseAuth());
    await tester.pumpAndSettle();

    expect(find.text(SharedStrings.APP_START_ERROR_TITLE), findsOneWidget);
    expect(find.text(SharedStrings.RETRY_ACTION), findsOneWidget);
    expect(find.text('TELA HOME'), findsNothing);
    expect(find.text('TELA LOGIN'), findsNothing);
  });

  testWidgets('Tentar de novo reinicia a espera e encaminha para o Home', (
    tester,
  ) async {
    AuthService.instance.debugAuthStateError = StateError('auth quebrado');
    final auth = MockFirebaseAuth(
      signedIn: true,
      mockUser: MockUser(uid: 'uid_1'),
    );

    await pumpSplash(tester, auth);
    await tester.pumpAndSettle();

    expect(find.text(SharedStrings.RETRY_ACTION), findsOneWidget);

    // Recupera e tenta de novo.
    AuthService.instance.debugAuthStateError = null;
    await tester.tap(find.text(SharedStrings.RETRY_ACTION));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.text(SharedStrings.APP_START_ERROR_TITLE), findsNothing);
    expect(find.text('TELA HOME'), findsOneWidget);
  });
}
