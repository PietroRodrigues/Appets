import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:appets/core/constants/constants_strings_home.dart';
import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/widgets/feedback/widget_dialogs.dart';

/// Protege o app de fechar ao tocar o voltar do sistema numa aba raiz.
///
/// O Android encerra a Activity quando um voltar atinge a raiz sem rota
/// para desempilhar. Se o usuário voltar do detalhe e apertar voltar logo
/// em seguida, esse segundo voltar cairia na raiz e fecharia o app.
///
/// Envolve o conteúdo da aba inicial (Home, Favoritos, Publicações e Perfil
/// ficam dentro da [HomeScreen] via IndexedStack). Toda tela empurrada por
/// cima (detalhe, publicar, configurações…) desempilha normalmente; só no
/// voltar da raiz o [`PopScope`] intercepta e abre a confirmação
/// "Deseja sair do aplicativo?" — com "Sim" o app encerra, com "Não" fica.
class WGRootBackExit extends StatelessWidget {
  const WGRootBackExit({super.key, required this.child, this.onExit});

  final Widget child;

  /// Ação executada ao confirmar a saída (padrão: encerra o app).
  final VoidCallback? onExit;

  Future<void> _exitApp(BuildContext context) async {
    final onExit = this.onExit;
    if (onExit != null) {
      onExit();
    } else {
      SystemNavigator.pop();
    }
  }

  Future<void> _onBackInvoked(BuildContext context, bool didPop) async {
    // Uma rota acima (detalhe) foi desempilhada: nada a fazer aqui.
    if (didPop) return;

    // Voltar na raiz: pede confirmação antes de fechar o app.
    final confirmed = await WGDialog.showConfirm(
      context,
      title: HomeStrings.EXIT_CONFIRM_TITLE,
      message: HomeStrings.EXIT_CONFIRM_MESSAGE,
      confirmColor: ThemeColors.error,
    );
    if (!context.mounted || !confirmed) return;
    await _exitApp(context);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<void>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) => _onBackInvoked(context, didPop),
      child: child,
    );
  }
}