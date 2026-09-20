import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:appets/core/constants/constants_strings_shared.dart';
import 'package:appets/core/routes/routes_app.dart';
import 'package:appets/core/services/auth_service.dart';
import 'package:appets/core/services/firestore_service.dart';
import 'package:appets/screens/screen_splash.dart';

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
