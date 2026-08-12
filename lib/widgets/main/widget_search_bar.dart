import 'package:flutter/material.dart';

import 'package:appets/core/theme/theme_colors.dart';

/// Barra de busca reutilizável para as telas principais do app.
class AppSearchBar extends StatelessWidget {
  const AppSearchBar({
    super.key,
    this.controller,
    this.hintText,
    this.onChanged,
    this.onFilterPressed,
    this.showFilterButton = true,
  });

  final TextEditingController? controller;

  final String? hintText;

  final ValueChanged<String>? onChanged;

  final VoidCallback? onFilterPressed;

  final bool showFilterButton;

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
                hintText: hintText ?? 'Buscar meu futuro pet',

                prefixIcon: const Icon(Icons.search),

                filled: true,

                fillColor: AppColors.surface,

                contentPadding: const EdgeInsets.symmetric(horizontal: 16),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),

                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),

        if (showFilterButton) ...[
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

                child: const Icon(Icons.tune, color: AppColors.white),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
