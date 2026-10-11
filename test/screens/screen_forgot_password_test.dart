import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:appets/core/constants/constants_strings_auth.dart';
import 'package:appets/core/services/auth_service.dart';
import 'package:appets/screens/auth/screen_forgot_password.dart';
import 'package:appets/widgets/feedback/widget_process.dart';

// Os mocks do firebase_auth_mocks já declaram campos não-finais.
// ignore_for_file: must_be_immutable

/// Auth cujo envio de recuperação sempre falha com [code].
class _FailingResetAuth extends MockFirebaseAuth {
  _FailingResetAuth(this.code);

  final String code;

  @override
  Future<void> sendPasswordResetEmail({
    required String email,
    ActionCodeSettings? actionCodeSettings,
  }) async {
    throw FirebaseAuthException(code: code);
  }
}

/// Empurra a tela de recuperação sobre uma tela-base ("login") para poder
/// verificar o `pop` de sucesso/voltar.
Future<void> _pumpForgot(WidgetTester tester) async {
  tester.view.physicalSize = const Size(800, 1200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final navKey = GlobalKey<NavigatorState>();
  await tester.pumpWidget(
    MaterialApp(
      navigatorKey: navKey,
      home: const Scaffold(body: Text('payload_login')),
    ),
  );
  navKey.currentState!.push(
    MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
  );
  await tester.pumpAndSettle();
}

Future<void> _fillEmail(WidgetTester tester, String email) async {
  await tester.enterText(find.byType(TextFormField), email);
  await tester.pumpAndSettle();
}

Future<void> _tapSend(WidgetTester tester) async {
  await tester.tap(find.text(AuthStrings.RECOVER_BUTTON));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    AuthService.instance.debugAuth = null;
  });

  testWidgets('formulário vazio mostra o erro antes de chamar o Firebase',
      (tester) async {
    await _pumpForgot(tester);

    await _tapSend(tester);

    expect(find.text(AuthStrings.EMAIL_REQUIRED), findsOneWidget);
    expect(find.byType(WGProcessLoadingScreen), findsNothing);
  });

  testWidgets('e-mail com formato inválido não chama o Firebase',
      (tester) async {
    await _pumpForgot(tester);

    await _fillEmail(tester, 'nao-e-email');
    await _tapSend(tester);

    expect(find.text(AuthStrings.EMAIL_INVALID), findsOneWidget);
    expect(find.byType(WGProcessLoadingScreen), findsNothing);
  });

  testWidgets('e-mail não cadastrado mostra a mensagem específica',
      (tester) async {
    AuthService.instance.debugAuth = _FailingResetAuth('user-not-found');

    await _pumpForgot(tester);
    await _fillEmail(tester, 'nao@test.com');
    await _tapSend(tester);

    expect(find.text(AuthStrings.EMAIL_NOT_REGISTERED), findsOneWidget);
  });

  testWidgets('envio válido avisa o sucesso e volta para o login',
      (tester) async {
    AuthService.instance.debugAuth = MockFirebaseAuth();

    await _pumpForgot(tester);
    await _fillEmail(tester, 'ana@test.com');
    await _tapSend(tester);

    expect(find.text(AuthStrings.RECOVER_LINK_SENT), findsOneWidget);

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.text('payload_login'), findsOneWidget);
  });

  testWidgets('voltar retorna para a tela anterior', (tester) async {
    await _pumpForgot(tester);

    await tester.tap(find.text(AuthStrings.BACK_TO_LOGIN));
    await tester.pumpAndSettle();

    expect(find.text('payload_login'), findsOneWidget);
  });
}
