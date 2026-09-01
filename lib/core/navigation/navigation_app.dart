import 'package:flutter/widgets.dart';

import 'package:appets/models/enums/enums_app.dart';

/// Controla a navegação por abas e a ação de voltar para a Home.
class AppNavigation {
  AppNavigation._();

  /// Aba atualmente selecionada (fonte única de verdade).
  static final ValueNotifier<AppPage> selectedPage = ValueNotifier(
    AppPage.home,
  );

  /// Sinal de que a lista de pets mudou (ex.: pet publicado com sucesso).
  ///
  /// As telas que exibem pets escutam este notificador e recarregam os
  /// dados quando ele é disparado, sem depender de reiniciar o app.
  static final ValueNotifier<int> petsDataVersion = ValueNotifier<int>(0);

  /// Dispara o sinal de mudança na lista de pets.
  static void notifyPetsChanged() {
    petsDataVersion.value++;
  }

  // Esvazia a pilha de navegação e volta para a aba inicial.
  static void goHome(BuildContext context) {
    Navigator.of(context, rootNavigator: true).popUntil(
      (route) => route.isFirst,
    );
    selectedPage.value = AppPage.home;
  }
}
