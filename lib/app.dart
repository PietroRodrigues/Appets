import 'package:flutter/material.dart';

import 'package:appets/core/routes/routes_app.dart';
import 'package:appets/core/theme/theme_app.dart';

import 'package:appets/widgets/feedback/widget_connectivity_banner.dart';
import 'package:appets/widgets/system/widget_system_bars_backdrop.dart';

/// Widget raiz do app: define o tema e o mapa de rotas.
class App extends StatelessWidget {
  const App({super.key});

  // Constrói o app com tema e mapa de rotas.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,

      // Envolve tudo com a faixa global de conectividade e mantém a barra de
      // status na cor do aparelho em todas as telas.
      builder: (context, child) => SystemBarsBackdrop(
        child: ConnectivityBanner(child: child ?? const SizedBox.shrink()),
      ),

      initialRoute: AppRoutes.splash,

      routes: AppRoutes.routes,
    );
  }
}
