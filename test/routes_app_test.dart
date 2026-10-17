import 'package:flutter_test/flutter_test.dart';

import 'package:appets/core/routes/routes_app.dart';

void main() {
  group('AppRoutes.routes', () {
    //178
    test('registra todas as rotas nomeadas em um só lugar', () {
      expect(
        AppRoutes.routes.keys,
        containsAll(<String>[
          AppRoutes.splash,
          AppRoutes.login,
          AppRoutes.register,
          AppRoutes.forgotPassword,
          AppRoutes.home,
          AppRoutes.settings,
          AppRoutes.accountData,
          AppRoutes.about,
        ]),
      );
      // Sem rotas declaradas mas não registradas (nem o contrário).
      expect(AppRoutes.routes, hasLength(8));
    });
  });
}
