import 'package:flutter/material.dart';

import 'package:appets/core/theme/app_colors.dart';

class AppSearchBar extends StatelessWidget {

  //══════════════════════════════════════════════════════════════
  // CONSTRUCTOR
  //
  // Barra de pesquisa reutilizável do APPets.
  //
  // Utilizada na:
  // • Home
  // • Pesquisa
  // • Favoritos (futuramente)
  // • Perfil (futuramente)
  //══════════════════════════════════════════════════════════════

  const AppSearchBar({
    super.key,
    this.controller,
    this.onChanged,
    this.onFilterPressed,
  });


  //══════════════════════════════════════════════════════════════
  // PROPERTIES
  //══════════════════════════════════════════════════════════════

  final TextEditingController? controller;

  final ValueChanged<String>? onChanged;

  final VoidCallback? onFilterPressed;


  //══════════════════════════════════════════════════════════════
  // UI
  //══════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {

    return Row(

      children: [

        //--------------------------------------------------------
        // Campo de Pesquisa
        //--------------------------------------------------------

        Expanded(

          child: SizedBox(

            height: 48,

            child: TextField(

              controller: controller,

              onChanged: onChanged,

              decoration: InputDecoration(

                hintText: 'Buscar meu futuro pet',

                prefixIcon: const Icon(
                  Icons.search,
                ),

                filled: true,

                fillColor: AppColors.surface,

                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),

                border: OutlineInputBorder(

                  borderRadius: BorderRadius.circular(30),

                  borderSide: BorderSide.none,

                ),

              ),

            ),

          ),

        ),

        const SizedBox(width: 12),

        //--------------------------------------------------------
        // Botão de Filtros
        //--------------------------------------------------------

        SizedBox(

          width: 48,

          height: 48,

          child: Material(

            color: AppColors.primary,

            borderRadius: BorderRadius.circular(14),

            child: InkWell(

              borderRadius: BorderRadius.circular(14),

              onTap: onFilterPressed,

              child: const Icon(
                Icons.tune,
                color: AppColors.white,
              ),

            ),

          ),

        ),

      ],

    );

  }

}