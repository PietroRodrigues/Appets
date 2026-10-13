import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:appets/core/constants/constants_assets.dart';
import 'package:appets/core/constants/constants_strings_auth.dart';
import 'package:appets/core/constants/constants_strings_delete_account.dart';
import 'package:appets/core/constants/constants_strings_profile.dart';
import 'package:appets/core/constants/constants_strings_shared.dart';
import 'package:appets/core/routes/routes_app.dart';
import 'package:appets/core/services/auth_service.dart';
import 'package:appets/core/services/connectivity_service.dart';
import 'package:appets/core/services/firestore_service.dart';
import 'package:appets/core/services/pet_service.dart';
import 'package:appets/screens/screen_account_data.dart';
import 'package:appets/widgets/fields/widget_editable_tile.dart';

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

/// MockUser que conta as chamadas de updateEmail.
class _TrackingEmailUser extends MockUser {
  _TrackingEmailUser({super.uid, super.email, super.providerData});

  int updateEmailCalls = 0;

  @override
  Future<void> updateEmail(String newEmail) async {
    updateEmailCalls++;
  }
}

/// MockUser que conta as chamadas de updateDisplayName.
class _TrackingDisplayNameUser extends MockUser {
  _TrackingDisplayNameUser({super.uid, super.email, super.providerData});

  int updateDisplayNameCalls = 0;

  @override
  Future<void> updateDisplayName(String? name) async {
    updateDisplayNameCalls++;
  }
}

/// MockUser cuja sincronização do nome no Auth sempre falha.
class _FailingDisplayNameUser extends _TrackingDisplayNameUser {
  _FailingDisplayNameUser({super.uid, super.email, super.providerData});

  @override
  Future<void> updateDisplayName(String? name) async {
    updateDisplayNameCalls++;
    throw FirebaseAuthException(
      code: 'network-request-failed',
      message: 'Sem rede.',
    );
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

/// MockUser cuja troca de e-mail sempre falha (e-mail já em uso).
class _EmailTakenUser extends MockUser {
  _EmailTakenUser({super.uid, super.email, super.providerData});

  @override
  Future<void> updateEmail(String newEmail) async {
    throw FirebaseAuthException(
      code: 'email-already-in-use',
      message: 'E-mail já cadastrado.',
    );
  }
}

/// Metadados com login recente (dispensa reautenticação na exclusão).
class _RecentUserMetadata extends UserMetadata {  _RecentUserMetadata()
    : super(
        DateTime.now().millisecondsSinceEpoch,
        DateTime.now().millisecondsSinceEpoch,
      );
}

/// MockUser excluível, com sessão recente e contagem de exclusões.
class _DeletableUser extends MockUser {
  _DeletableUser()
    : super(
        uid: 'uid_1',
        email: 'a@test.com',
        metadata: _RecentUserMetadata(),
      );

  int deleteCalls = 0;

  @override
  Future<void> delete() async {
    deleteCalls++;
  }
}

/// GoogleSignIn que falha no signOut (evita o plugin real nos testes).
class _ThrowingGoogleSignIn extends GoogleSignIn {
  @override
  Future<GoogleSignInAccount?> signOut() async =>
      throw StateError('google fora');
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

Widget _buildApp() => MaterialApp(
  home: const AccountDataScreen(),
  routes: {
    AppRoutes.login: (_) => const Scaffold(body: Text('tela_login')),
  },
);

/// Logo do Google dentro de um tile (usado no e-mail de contas Google).
Finder _googleLogoInTile() => find.descendant(
  of: find.byType(WGEditableTile),
  matching: find.byWidgetPredicate(
    (w) =>
        w is Image &&
        w.image is AssetImage &&
        (w.image as AssetImage).assetName == AppAssets.GOOGLE_LOGO,
  ),
);

/// Prepara os serviços (Firestore/Auth fakes) e semeia o documento do usuário.
///
/// Devolve o Firestore falso usado, para inspeção nos testes.
Future<FakeFirebaseFirestore> _seed(WidgetTester tester, MockUser user) async {
  final db = FakeFirebaseFirestore();
  FirestoreService.instance.debugDb = db;
  PetService.instance.debugDb = db;
  AuthService.instance.debugAuth = MockFirebaseAuth(
    signedIn: true,
    mockUser: user,
  );
  AuthService.instance.debugGoogle = _ThrowingGoogleSignIn();

  await db.collection('users').doc(user.uid).set({
    'name': 'Ana',
    'email': user.email,
    'phone': '(11) 99999-9999',
    'address': 'São Paulo',
    'photoUrl': '',
    'favoritePetIds': <String>[],
    'myPublishedPetIds': <String>[],
  });
  return db;
}

/// Prepara os serviços e renderiza a tela logada com [user] na raiz.
Future<FakeFirebaseFirestore> _pumpScreen(
  WidgetTester tester,
  MockUser user,
) async {
  final db = await _seed(tester, user);
  await tester.pumpWidget(_buildApp());
  await tester.pumpAndSettle();
  return db;
}

/// Renderiza a tela empurrada sobre uma tela-base ("origem"), permitindo
/// verificar o `pop` (usado no fluxo de descartar alterações).
Future<void> _pumpPushedScreen(WidgetTester tester, MockUser user) async {
  await _seed(tester, user);

  await tester.pumpWidget(
    MaterialApp(
      routes: {
        AppRoutes.login: (_) => const Scaffold(body: Text('tela_login')),
      },
      home: Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => const AccountDataScreen(),
                ),
              ),
              child: const Text('origem'),
            ),
          ),
        ),
      ),
    ),
  );

  await tester.tap(find.text('origem'));
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
  tearDown(() => PetService.instance.debugDb = null);
  tearDown(ConnectivityService.instance.reset);
  //179
  testWidgets('conta Google: secao de seguranca fica invisivel (sem senha)', (
    tester,
  ) async {
    await _pumpScreen(tester, MockUser(uid: 'uid_1', email: 'ana@gmail.com'));

    // A opção "Alterar senha" e a seção inteira não existem em contas Google.
    expect(find.text(ProfileStrings.CHANGE_PASSWORD), findsNothing);
    expect(find.text(ProfileStrings.SECURITY_SECTION), findsNothing);
  });

  //180
  testWidgets('conta com senha: fluxo completo altera a senha', (tester) async {
    final tracking = _TrackingUser(
      uid: 'uid_1',
      email: 'a@test.com',
      providerData: [_passwordProvider('uid_1', 'a@test.com')],
    );
    await _pumpScreen(tester, tracking);

    final changePassword = find.text(ProfileStrings.CHANGE_PASSWORD);
    await tester.ensureVisible(changePassword);
    await tester.tap(changePassword);
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

  //181
  testWidgets('conta com senha: senha atual incorreta aborta o fluxo', (
    tester,
  ) async {
    final failing = _FailingReauthUser(
      uid: 'uid_1',
      email: 'a@test.com',
      providerData: [_passwordProvider('uid_1', 'a@test.com')],
    );
    await _pumpScreen(tester, failing);

    final changePassword = find.text(ProfileStrings.CHANGE_PASSWORD);
    await tester.ensureVisible(changePassword);
    await tester.tap(changePassword);
    await tester.pumpAndSettle();

    await _enterTextAndConfirm(tester, 'errada');

    expect(find.text(AuthStrings.WRONG_PASSWORD_MESSAGE), findsOneWidget);
    expect(failing.updatePasswordCalls, 0);
  });

  //182
  testWidgets('conta Google: e-mail fica bloqueado com cadeado (item 12)', (
    tester,
  ) async {
    await _pumpScreen(
      tester,
      MockUser(
        uid: 'uid_1',
        email: 'ana@gmail.com',
        providerData: [_googleProvider('uid_1', 'ana@gmail.com')],
      ),
    );

    // O toque no e-mail não abre edição.
    await tester.tap(find.text('ana@gmail.com'));
    await tester.pumpAndSettle();

    expect(find.byType(TextFormField), findsNothing);
    expect(
      find.descendant(
        of: find.byType(WGEditableTile),
        matching: find.byIcon(Icons.lock_outline),
      ),
      findsOneWidget,
    );

    // Conta Google: o envelope é substituído pelo logo do Google.
    expect(_googleLogoInTile(), findsOneWidget);
    expect(tester.getSize(_googleLogoInTile()).width, 20);
    expect(
      find.descendant(
        of: find.byType(WGEditableTile),
        matching: find.byIcon(Icons.email_outlined),
      ),
      findsNothing,
    );
  });

  //183
  testWidgets('ordenacao: e-mail vem antes do nome e fica em destaque', (
    tester,
  ) async {
    await _pumpScreen(
      tester,
      MockUser(
        uid: 'uid_1',
        email: 'ana@gmail.com',
        providerData: [_passwordProvider('uid_1', 'ana@gmail.com')],
      ),
    );

    // E-mail renderizado acima do nome.
    final emailY = tester.getTopLeft(find.text('ana@gmail.com')).dy;
    final nameY = tester.getTopLeft(find.text('Ana')).dy;
    expect(emailY, lessThan(nameY));

    // Conta com senha: mantém o envelope (sem logo do Google).
    expect(_googleLogoInTile(), findsNothing);
    expect(
      find.descendant(
        of: find.byType(WGEditableTile),
        matching: find.byIcon(Icons.email_outlined),
      ),
      findsOneWidget,
    );

    // Moldura maior: o tile do e-mail é mais alto que o do nome.
    final emailTile = find
        .ancestor(
          of: find.text('ana@gmail.com'),
          matching: find.byType(WGEditableTile),
        )
        .first;
    final nameTile = find
        .ancestor(of: find.text('Ana'), matching: find.byType(WGEditableTile))
        .first;
    expect(
      tester.getSize(emailTile).height,
      greaterThan(tester.getSize(nameTile).height),
    );
  });

  //184
  testWidgets('salvar nome alterado sincroniza o nome no Auth (item 12)', (
    tester,
  ) async {
    final tracking = _TrackingDisplayNameUser(
      uid: 'uid_1',
      email: 'a@test.com',
      providerData: [_passwordProvider('uid_1', 'a@test.com')],
    );
    await _pumpScreen(tester, tracking);

    await tester.tap(find.text('Ana'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Ana Nova');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    final saveButton = find.text(ProfileStrings.SAVE_CONTACT);
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(tracking.updateDisplayNameCalls, 1);
    expect(find.text(ProfileStrings.CONTACT_SAVED), findsOneWidget);

    final saved = await FirestoreService.instance.getUser('uid_1');
    expect(saved?.name, 'Ana Nova');
  });

  //185
  testWidgets('falha ao sincronizar nome mostra aviso best-effort (item 12)', (
    tester,
  ) async {
    final failing = _FailingDisplayNameUser(
      uid: 'uid_1',
      email: 'a@test.com',
      providerData: [_passwordProvider('uid_1', 'a@test.com')],
    );
    await _pumpScreen(tester, failing);

    await tester.tap(find.text('Ana'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Ana Nova');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    final saveButton = find.text(ProfileStrings.SAVE_CONTACT);
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(failing.updateDisplayNameCalls, 1);
    expect(find.text(ProfileStrings.NAME_SYNC_WARNING), findsOneWidget);

    final saved = await FirestoreService.instance.getUser('uid_1');
    expect(saved?.name, 'Ana Nova');
  });

  //186
  testWidgets('conta com senha: trocar e-mail reautentica e grava (item 42)', (
    tester,
  ) async {
    final tracking = _TrackingEmailUser(
      uid: 'uid_1',
      email: 'a@test.com',
      providerData: [_passwordProvider('uid_1', 'a@test.com')],
    );
    await _pumpScreen(tester, tracking);

    await tester.tap(find.text('a@test.com'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'novo@test.com');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    final saveButton = find.text(ProfileStrings.SAVE_CONTACT);
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    // Diálogo de reautenticação: senha atual confirma a troca.
    await _enterTextAndConfirm(tester, '123456');

    expect(tracking.updateEmailCalls, 1);
    expect(find.text(ProfileStrings.CONTACT_SAVED), findsOneWidget);

    final saved = await FirestoreService.instance.getUser('uid_1');
    expect(saved?.email, 'novo@test.com');
  });

  //187
  testWidgets('conta com senha: cancelar reauth aborta sem gravar (item 42)', (
    tester,
  ) async {
    final tracking = _TrackingEmailUser(
      uid: 'uid_1',
      email: 'a@test.com',
      providerData: [_passwordProvider('uid_1', 'a@test.com')],
    );
    await _pumpScreen(tester, tracking);

    await tester.tap(find.text('a@test.com'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'novo@test.com');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    final saveButton = find.text(ProfileStrings.SAVE_CONTACT);
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    // Cancela o diálogo de senha ("Não"); nada é gravado.
    await tester.tap(find.text(SharedStrings.NO));
    await tester.pumpAndSettle();

    expect(tracking.updateEmailCalls, 0);
    expect(find.text(ProfileStrings.CONTACT_SAVED), findsNothing);

    final saved = await FirestoreService.instance.getUser('uid_1');
    expect(saved?.email, 'a@test.com');
  });

  //188
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

  //189
  testWidgets('salvar dados offline não tenta gravar e mostra aviso', (
    tester,
  ) async {
    ConnectivityService.instance.debugOnline = false;

    await _pumpScreen(tester, MockUser(uid: 'uid_1', email: 'ana@test.com'));

    final saveButton = find.text(ProfileStrings.SAVE_CONTACT);
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(find.text(SharedStrings.NO_CONNECTION), findsOneWidget);
    expect(find.text(ProfileStrings.CONTACT_SAVED), findsNothing);

    // Nenhuma escrita aconteceu: o telefone continua o valor original.
    final saved = await FirestoreService.instance.getUser('uid_1');
    expect(saved?.phone, '(11) 99999-9999');
  });

  //190
  testWidgets('trocar e-mail para um já cadastrado mostra erro específico', (
    tester,
  ) async {
    final taken = _EmailTakenUser(
      uid: 'uid_1',
      email: 'a@test.com',
      providerData: [_passwordProvider('uid_1', 'a@test.com')],
    );
    await _pumpScreen(tester, taken);

    await tester.tap(find.text('a@test.com'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'novo@test.com');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    final saveButton = find.text(ProfileStrings.SAVE_CONTACT);
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    // Reautentica e tenta gravar: o Auth recusa o e-mail em uso.
    await _enterTextAndConfirm(tester, '123456');

    expect(find.text(AuthStrings.EMAIL_ALREADY_IN_USE), findsOneWidget);
    expect(find.text(ProfileStrings.CONTACT_SAVED), findsNothing);

    final saved = await FirestoreService.instance.getUser('uid_1');
    expect(saved?.email, 'a@test.com');
  });

  //191
  testWidgets('alterar telefone propaga para as publicações ao confirmar', (
    tester,
  ) async {
    final db = await _pumpScreen(
      tester,
      MockUser(uid: 'uid_1', email: 'ana@test.com'),
    );
    final petRef = await db.collection('pets').add({
      'ownerId': 'uid_1',
      'ownerPhone': '(11) 99999-9999',
      'name': 'Rex',
      'images': <String>[],
    });

    await tester.tap(find.text('(11) 99999-9999'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), '(11) 98888-7777');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    final saveButton = find.text(ProfileStrings.SAVE_CONTACT);
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    // Pergunta se propaga o novo telefone para as publicações.
    expect(find.text(ProfileStrings.UPDATE_CONTACT_TITLE), findsOneWidget);
    await tester.tap(find.text(SharedStrings.YES));
    await tester.pumpAndSettle();

    final petDoc = await petRef.get();
    expect(petDoc.data()!['ownerPhone'], '(11) 98888-7777');
  });

  //192
  testWidgets('voltar com alterações não salvas pede confirmação', (
    tester,
  ) async {
    await _pumpPushedScreen(tester, MockUser(uid: 'uid_1', email: 'ana@test.com'));

    // Altera o nome localmente, sem salvar.
    await tester.tap(find.text('Ana'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Ana Nova');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.text('Ana Nova'), findsOneWidget);

    // Gesto de voltar do sistema: PopScope intercepta e pede confirmação.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text(ProfileStrings.DISCARD_CHANGES_TITLE), findsOneWidget);

    // Cancelar ("Não") mantém as alterações no rascunho e a tela aberta.
    await tester.tap(find.text(SharedStrings.NO));
    await tester.pumpAndSettle();
    expect(find.text(ProfileStrings.DISCARD_CHANGES_TITLE), findsNothing);
    expect(find.text('Ana Nova'), findsOneWidget);

    // Confirmar ("Sim") descarta as alterações e volta para a tela-base.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await tester.tap(find.text(SharedStrings.YES));
    await tester.pumpAndSettle();
    expect(find.text(ProfileStrings.DISCARD_CHANGES_TITLE), findsNothing);
    expect(find.text('origem'), findsOneWidget);
  });

  //193
  testWidgets('excluir conta: cancelar a primeira confirmação não exclui', (
    tester,
  ) async {
    await _pumpScreen(tester, MockUser(uid: 'uid_1', email: 'a@test.com'));

    final deleteTile = find.text(DeleteAccountStrings.DELETE_ACCOUNT);
    await tester.ensureVisible(deleteTile);
    await tester.tap(deleteTile);
    await tester.pumpAndSettle();

    expect(
      find.text(DeleteAccountStrings.DELETE_ACCOUNT_TITLE),
      findsOneWidget,
    );

    await tester.tap(find.text(SharedStrings.NO));
    await tester.pumpAndSettle();

    expect(
      find.text(DeleteAccountStrings.DELETE_ACCOUNT_FINAL_TITLE),
      findsNothing,
    );
    final saved = await FirestoreService.instance.getUser('uid_1');
    expect(saved, isNotNull);
  });

  //194
  testWidgets('excluir conta: duas confirmações excluem e vão para o login', (
    tester,
  ) async {
    final user = _DeletableUser();
    await _pumpScreen(tester, user);

    final deleteTile = find.text(DeleteAccountStrings.DELETE_ACCOUNT);
    await tester.ensureVisible(deleteTile);
    await tester.tap(deleteTile);
    await tester.pumpAndSettle();

    // Primeira confirmação.
    await tester.tap(find.text(SharedStrings.YES));
    await tester.pumpAndSettle();
    expect(
      find.text(DeleteAccountStrings.DELETE_ACCOUNT_FINAL_TITLE),
      findsOneWidget,
    );

    // Segunda confirmação dispara a tela de carregamento (animada).
    await tester.tap(find.text(SharedStrings.YES));
    for (
      var i = 0;
      i < 40 &&
          find
              .text(DeleteAccountStrings.ACCOUNT_DELETED)
              .evaluate()
              .isEmpty;
      i++
    ) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    expect(find.text(DeleteAccountStrings.ACCOUNT_DELETED), findsOneWidget);
    expect(user.deleteCalls, 1);
    await tester.tap(find.text(SharedStrings.OK));
    await tester.pumpAndSettle();

    expect(find.text('tela_login'), findsOneWidget);
    expect(await FirestoreService.instance.getUser('uid_1'), isNull);
  });

  //195
  testWidgets('excluir conta offline avisa e não exclui', (tester) async {
    ConnectivityService.instance.debugOnline = false;
    final user = _DeletableUser();
    await _pumpScreen(tester, user);

    final deleteTile = find.text(DeleteAccountStrings.DELETE_ACCOUNT);
    await tester.ensureVisible(deleteTile);
    await tester.tap(deleteTile);
    await tester.pumpAndSettle();

    await tester.tap(find.text(SharedStrings.YES));
    await tester.pumpAndSettle();
    await tester.tap(find.text(SharedStrings.YES));
    await tester.pumpAndSettle();

    // Sem conexão: avisa e aborta antes de tocar no Firebase.
    expect(find.text(SharedStrings.NO_CONNECTION), findsOneWidget);
    expect(user.deleteCalls, 0);
    expect(await FirestoreService.instance.getUser('uid_1'), isNotNull);
  });
}
