import 'package:flutter/material.dart';

import 'package:appets/core/theme/app_colors.dart';
import 'package:appets/model/enums/app_page.dart';

class AppBottomNavigation extends StatelessWidget {

  //══════════════════════════════════════════════════════════════
  // CONSTRUCTOR
  //
  // Barra de navegação principal do APPets.
  //
  // Será utilizada em:
  // • Home
  // • Pesquisa
  // • Publicar Pet
  // • Favoritos
  // • Perfil
  //
  // Cada tela informa qual página está ativa.
  //══════════════════════════════════════════════════════════════

  const AppBottomNavigation({
    super.key,
    required this.currentPage,
    required this.onTap,
  });

  //══════════════════════════════════════════════════════════════
  // PROPERTIES
  //══════════════════════════════════════════════════════════════

  /// Página atualmente selecionada.
  final AppPage currentPage;

  /// Evento disparado ao tocar em uma aba.
  final ValueChanged<AppPage> onTap;

  //══════════════════════════════════════════════════════════════
  // UI
  //══════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {

    return NavigationBarTheme(      

      data: NavigationBarThemeData(

        //----------------------------------------------------------
        // Cor dos ícones
        //----------------------------------------------------------

        iconTheme: WidgetStateProperty.resolveWith((states) {

          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              color: AppColors.navigationActive,
            );
          }

          return const IconThemeData(
            color: AppColors.navigationInactive,
          );

        }),

        //----------------------------------------------------------
        // Cor dos textos
        //----------------------------------------------------------

        labelTextStyle: WidgetStateProperty.resolveWith((states) {

          if (states.contains(WidgetState.selected)) {

            return const TextStyle(
              color: AppColors.navigationActive,
              fontWeight: FontWeight.bold,
            );

          }

          return const TextStyle(
            color: AppColors.navigationInactive,
            fontWeight: FontWeight.normal,
          );

        }),

      ),

      child: NavigationBar(

        //----------------------------------------------------------
        // Página selecionada
        //----------------------------------------------------------

        selectedIndex: currentPage.index,

        //----------------------------------------------------------
        // Conversão do índice para Enum
        //----------------------------------------------------------

        onDestinationSelected: (index) {

          onTap(
            AppPage.values[index],
          );

        },

        //----------------------------------------------------------
        // Aparência
        //----------------------------------------------------------

        backgroundColor: AppColors.primary,

        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,

        indicatorColor: AppColors.navigationIndicator.withValues(
          alpha: 0.1,
        ),

        //----------------------------------------------------------
        // Itens
        //----------------------------------------------------------

        destinations: const [

          NavigationDestination(

            icon: Icon(
              Icons.home_outlined,
              size: 24,
            ),

            selectedIcon: Icon(
              Icons.home,
              size: 28, // cerca de 12% maior
            ),

            label: 'Home',

          ),

          NavigationDestination(

            icon: Icon(
              Icons.add_circle_outline,
              size: 24,
            ),

            selectedIcon: Icon(
              Icons.add_circle,
              size: 28, // cerca de 12% maior
            ),

            label: 'Publicar',

          ),

          NavigationDestination(

            icon: Icon(
              Icons.favorite_border,
              size: 24,
            ),

            selectedIcon: Icon(
              Icons.favorite,
              size: 28, // cerca de 12% maior
            ),

            label: 'Favoritos',

          ),

        ],

      ),

    );

  }

}