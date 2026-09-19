import 'package:flutter/material.dart';

import 'package:appets/core/theme/theme_colors.dart';

/// Chave da faixa da barra de status (usada nos testes).
const statusBarBackdropKey = ValueKey<String>('status_bar_backdrop');

/// Chave da faixa da barra de navegação (usada nos testes).
const systemNavBarBackdropKey = ValueKey<String>('system_nav_bar_backdrop');

/// Pinta faixas coloridas atrás das barras do sistema em todo o app.
///
/// Com o edge-to-edge forçado no Android 15+/16 as barras do sistema ficam
/// transparentes; estas faixas (na cor padrão do aparelho) são desenhadas por
/// cima do conteúdo nas regiões ocupadas pela barra de status e pela barra de
/// navegação (menu) do sistema.
class SystemBarsBackdrop extends StatelessWidget {
  const SystemBarsBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.paddingOf(context);
    final top = padding.top;
    final bottom = padding.bottom;

    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        if (top > 0)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: top,
            child: IgnorePointer(
              child: Container(
                key: statusBarBackdropKey,
                width: double.infinity,
                color: ThemeColors.statusBar,
              ),
            ),
          ),
        if (bottom > 0)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: bottom,
            child: IgnorePointer(
              child: Container(
                key: systemNavBarBackdropKey,
                width: double.infinity,
                color: ThemeColors.statusBar,
              ),
            ),
          ),
      ],
    );
  }
}