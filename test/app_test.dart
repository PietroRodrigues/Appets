import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:appets/app.dart';
import 'package:appets/core/routes/routes_app.dart';
import 'package:appets/core/services/auth_service.dart';
import 'package:appets/core/services/connectivity_service.dart';
import 'package:appets/core/theme/theme_app.dart';
import 'package:appets/widgets/feedback/widget_connectivity_banner.dart';
import 'package:appets/widgets/system/widget_system_bars_backdrop.dart';

void main() {
  setUp(() {
    // Evita tocar plugin de conectividade e Firebase de verdade: a splash
    // resolve como visitante (sem usuário) e segue para o login.
    ConnectivityService.instance.debugOnline = true;
    AuthService.instance.debugAuth = MockFirebaseAuth();
  });

  tearDown(() {
    ConnectivityService.instance.reset();
    AuthService.instance.debugAuth = null;
  });

  //1
  testWidgets('configura tema, rota inicial, mapa de rotas e o builder', (
    tester,
  ) async {
    await tester.pumpWidget(const App());

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.debugShowCheckedModeBanner, isFalse);
    expect(app.theme, same(AppTheme.lightTheme));
    expect(app.initialRoute, AppRoutes.splash);
    expect(
      app.routes!.keys,
      containsAll(<String>[
        AppRoutes.splash,
        AppRoutes.login,
        AppRoutes.register,
        AppRoutes.forgotPassword,
        AppRoutes.home,
        AppRoutes.settings,
        AppRoutes.accountData,
      ]),
    );
    expect(app.builder, isNotNull);
    expect(find.byType(SystemBarsBackdrop), findsWidgets);
    expect(find.byType(ConnectivityBanner), findsWidgets);

    // Drena o atraso de 1s da splash (evita timer pendente) e conclui a
    // navegação inicial até o login.
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
  });
}
