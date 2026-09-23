import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:appets/core/constants/constants_strings_auth.dart';
import 'package:appets/core/routes/routes_app.dart';
import 'package:appets/core/services/auth_service.dart';
import 'package:appets/core/services/firestore_service.dart';
import 'package:appets/screens/auth/screen_login.dart';

// Os mocks do firebase_auth_mocks já declaram campos não-finais.
// ignore_for_file: must_be_immutable

/// Firestore fake cuja gravação do documento de usuário sempre falha.
class _CreateFailDb extends FakeFirebaseFirestore {
  _CreateFailDb();

  @override
  CollectionReference<Map<String, dynamic>> collection(String path) {
    throw StateError('firestore-write-failed');
  }
}

/// Auth já com um usuário conhecido: o sign-in devolve o mesmo `uid_1`.
MockFirebaseAuth _auth({String email = 'ana@test.com'}) {
  return MockFirebaseAuth(
    signedIn: true,
    mockUser: MockUser(uid: 'uid_1', email: email),
  );
}

Widget _buildApp() {
  return MaterialApp(
    initialRoute: AppRoutes.login,
    routes: {
      AppRoutes.login: (_) => const LoginScreen(),
      AppRoutes.home: (_) => const Scaffold(body: Text('payload_home')),
    },
  );
}

/// Renderiza o login numa superfície alta para o formulário caber.
Future<void> _pumpLogin(WidgetTester tester) async {
  tester.view.physicalSize = const Size(800, 1200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(_buildApp());
  await tester.pumpAndSettle();
}

/// Preenche e-mail e senha (índices fixos na ordem do build).
Future<void> _fillForm(
  WidgetTester tester, {
  String email = 'ana@test.com',
  String password = '123456',
}) async {
  await tester.enterText(find.byType(TextFormField).at(0), email);
  await tester.enterText(find.byType(TextFormField).at(1), password);
  await tester.pumpAndSettle();
}

Future<void> _tapLogin(WidgetTester tester) async {
  await tester.ensureVisible(find.text(AuthStrings.LOGIN_BUTTON));
  await tester.tap(find.text(AuthStrings.LOGIN_BUTTON));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    AuthService.instance.debugAuth = null;
    FirestoreService.instance.debugDb = null;
  });

  testWidgets('login válido navega para a Home e garante o doc no Firestore',
      (tester) async {
    final db = FakeFirebaseFirestore();
    FirestoreService.instance.debugDb = db;
    AuthService.instance.debugAuth = _auth();

    await _pumpLogin(tester);
    await _fillForm(tester);
    await _tapLogin(tester);

    expect(find.text('payload_home'), findsOneWidget);

    // Sem doc prévio, o login cria o documento do usuário (fim do fantasma).
    final doc = await db.collection('users').doc('uid_1').get();
    expect(doc.exists, isTrue);
    expect(doc.get('email'), 'ana@test.com');
  });

  testWidgets('login preserva favoritos, publicações e telefone já gravados',
      (tester) async {
    final db = FakeFirebaseFirestore();
    FirestoreService.instance.debugDb = db;
    AuthService.instance.debugAuth = _auth();

    // Usuário que já usa o app: doc existente com dados que não podem
    // ser perdidos (segundo/terceiro login).
    await db.collection('users').doc('uid_1').set({
      'name': 'Nome Antigo',
      'email': 'antigo@test.com',
      'phone': '(11) 99999-0000',
      'address': 'Rua A',
      'favoritePetIds': ['pet_a', 'pet_b'],
      'myPublishedPetIds': ['pet_b'],
    });

    await _pumpLogin(tester);
    await _fillForm(tester);
    await _tapLogin(tester);

    expect(find.text('payload_home'), findsOneWidget);

    // Merge: atualiza identidade (e-mail), mas não apaga listas/telefone/
    // endereço. (A photoUrl não é verificada: o mock traz uma foto padrão
    // do Auth, comportamento igual ao login por Google.)
    final doc = await db.collection('users').doc('uid_1').get();
    expect(doc.get('name'), 'Nome Antigo');
    expect(doc.get('email'), 'ana@test.com');
    expect(doc.get('phone'), '(11) 99999-0000');
    expect(doc.get('address'), 'Rua A');
    expect(doc.get('favoritePetIds'), ['pet_a', 'pet_b']);
    expect(doc.get('myPublishedPetIds'), ['pet_b']);
  });

  testWidgets('falha ao garantir o doc mostra aviso e não navega', (
    tester,
  ) async {
    FirestoreService.instance.debugDb = _CreateFailDb();
    AuthService.instance.debugAuth = _auth();

    await _pumpLogin(tester);
    await _fillForm(tester);
    await _tapLogin(tester);

    expect(find.text(AuthStrings.LOGIN_ACCOUNT_ERROR), findsOneWidget);
    expect(find.text('payload_home'), findsNothing);

    // Continua na tela de login, pronto para nova tentativa.
    expect(find.text(AuthStrings.LOGIN_BUTTON), findsOneWidget);
  });
}