import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:appets/core/constants/constants_strings_auth.dart';
import 'package:appets/core/routes/routes_app.dart';
import 'package:appets/core/services/auth_service.dart';
import 'package:appets/core/services/firestore_service.dart';
import 'package:appets/screens/auth/screen_register.dart';
import 'package:appets/widgets/feedback/widget_process.dart';

// Os mocks do firebase_auth_mocks já declaram campos não-finais.
// ignore_for_file: must_be_immutable

/// Auth cujo cadastro sempre falha com um código específico.
class _FailingCreateAuth extends MockFirebaseAuth {
  _FailingCreateAuth(this.code);

  final String code;

  @override
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    throw FirebaseAuthException(code: code);
  }
}

/// Usuário rastreado: conta exclusões e falha ao atualizar o nome.
class _TrackingProfileUser extends MockUser {
  _TrackingProfileUser({super.uid, super.email});

  int deleteCalls = 0;

  @override
  Future<void> updateDisplayName(String? displayName) async {
    throw StateError('update-profile-failed');
  }

  @override
  Future<void> delete() async {
    deleteCalls++;
  }
}

/// Firestore fake cuja gravação do documento de usuário sempre falha.
class _CreateFailDb extends FakeFirebaseFirestore {
  @override
  CollectionReference<Map<String, dynamic>> collection(String path) {
    throw StateError('firestore-write-failed');
  }
}

/// Auth que "cadastra" mantendo [createdUser] como usuário logado.
class _TrackedSignUpAuth extends MockFirebaseAuth {
  _TrackedSignUpAuth({required this.createdUser})
      : super(signedIn: true, mockUser: createdUser);

  final _TrackingProfileUser createdUser;

  @override
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return signInWithCredential(null);
  }
}

Widget _buildApp() {
  return MaterialApp(
    initialRoute: AppRoutes.register,
    routes: {
      AppRoutes.register: (_) => const RegisterScreen(),
      AppRoutes.home: (_) => const Scaffold(body: Text('payload_home')),
    },
  );
}

/// Renderiza o cadastro numa superfície alta para o formulário caber.
Future<void> _pumpRegister(WidgetTester tester) async {
  tester.view.physicalSize = const Size(800, 1400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(_buildApp());
  await tester.pumpAndSettle();
}

/// Preenche os quatro campos do formulário (índices fixos na ordem do build).
Future<void> _fillForm(
  WidgetTester tester, {
  String name = 'Ana Teste',
  String email = 'ana@test.com',
  String password = '123456',
  String confirm = '123456',
}) async {
  await tester.enterText(find.byType(TextFormField).at(0), name);
  await tester.enterText(find.byType(TextFormField).at(1), email);
  await tester.enterText(find.byType(TextFormField).at(2), password);
  await tester.enterText(find.byType(TextFormField).at(3), confirm);
  await tester.pumpAndSettle();
}

Future<void> _tapCreate(WidgetTester tester) async {
  await tester.ensureVisible(find.text(AuthStrings.CREATE_ACCOUNT));
  await tester.tap(find.text(AuthStrings.CREATE_ACCOUNT));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    AuthService.instance.debugAuth = null;
    FirestoreService.instance.debugDb = null;
  });

  testWidgets('formulário vazio mostra os erros antes de chamar o Firebase',
      (tester) async {
    await _pumpRegister(tester);

    await _tapCreate(tester);

    expect(find.text(AuthStrings.NAME_REQUIRED), findsOneWidget);
    expect(find.text(AuthStrings.EMAIL_REQUIRED), findsOneWidget);
    expect(find.text(AuthStrings.PASSWORD_REQUIRED), findsNWidgets(2));
    expect(find.byType(WGProcessLoadingScreen), findsNothing);
  });

  testWidgets('senhas divergentes mostram o erro sob o campo',
      (tester) async {
    await _pumpRegister(tester);

    await _fillForm(tester, confirm: '654321');
    await _tapCreate(tester);

    expect(find.text(AuthStrings.PASSWORD_MISMATCH), findsOneWidget);
    expect(find.byType(WGProcessLoadingScreen), findsNothing);
  });

  testWidgets('e-mail já cadastrado mostra a mensagem específica',
      (tester) async {
    AuthService.instance.debugAuth =
        _FailingCreateAuth('email-already-in-use');

    await _pumpRegister(tester);
    await _fillForm(tester);
    await _tapCreate(tester);

    expect(find.text(AuthStrings.EMAIL_ALREADY_IN_USE), findsOneWidget);
  });

  testWidgets('cadastro válido navega para a Home e grava o documento',
      (tester) async {
    final db = FakeFirebaseFirestore();
    FirestoreService.instance.debugDb = db;
    AuthService.instance.debugAuth = MockFirebaseAuth();

    await _pumpRegister(tester);
    await _fillForm(tester, name: 'Ana Teste', email: 'ana@test.com');
    await _tapCreate(tester);

    expect(find.text(AuthStrings.ACCOUNT_CREATED), findsOneWidget);

    await tester.ensureVisible(find.text('OK'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.text('payload_home'), findsOneWidget);

    final docs = await db.collection('users').get();
    expect(docs.docs, hasLength(1));
    expect(docs.docs.first.get('name'), 'Ana Teste');
  });

  testWidgets('displayName falha, mas o cadastro conclui e vai para a Home',
      (tester) async {
    final createdUser = _TrackingProfileUser(
      uid: 'uid_name',
      email: 'ana@test.com',
    );
    AuthService.instance.debugAuth =
        _TrackedSignUpAuth(createdUser: createdUser);
    final db = FakeFirebaseFirestore();
    FirestoreService.instance.debugDb = db;

    await _pumpRegister(tester);
    await _fillForm(tester, name: 'Ana Teste', email: 'ana@test.com');
    await _tapCreate(tester);

    expect(find.text(AuthStrings.ACCOUNT_CREATED), findsOneWidget);

    await tester.ensureVisible(find.text('OK'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.text('payload_home'), findsOneWidget);
    expect(createdUser.deleteCalls, 0);

    final docs = await db.collection('users').get();
    expect(docs.docs, hasLength(1));
    expect(docs.docs.first.get('name'), 'Ana Teste');
  });

  testWidgets('falha ao gravar o documento mostra erro específico e remove o fantasma',
      (tester) async {
    final createdUser = _TrackingProfileUser(
      uid: 'uid_phantom',
      email: 'ana@test.com',
    );
    AuthService.instance.debugAuth =
        _TrackedSignUpAuth(createdUser: createdUser);
    FirestoreService.instance.debugDb = _CreateFailDb();

    await _pumpRegister(tester);
    await _fillForm(tester);
    await _tapCreate(tester);

    expect(
      find.text(AuthStrings.REGISTER_SAVE_ERROR),
      findsOneWidget,
    );
    expect(createdUser.deleteCalls, 1);
  });
}