import 'package:flutter/widgets.dart';

import 'package:appets/models/enums/enums_app.dart';

/// Controla a navegação por abas e a ação de voltar para a Home.
class AppNavigation {
  AppNavigation._();

  /// Aba atualmente selecionada (fonte única de verdade).
  static final ValueNotifier<AppPage> selectedPage = ValueNotifier(
    AppPage.home,
  );

  // Esvazia a pilha de navegação e volta para a aba inicial.
  static void goHome(BuildContext context) {
    Navigator.of(context, rootNavigator: true).popUntil(
      (route) => route.isFirst,
    );
    selectedPage.value = AppPage.home;
  }
}
