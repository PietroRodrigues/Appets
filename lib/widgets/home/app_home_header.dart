import 'package:flutter/material.dart';

import 'package:appets/core/theme/app_colors.dart';
import 'package:appets/core/theme/app_text_styles.dart';
import 'package:appets/widgets/home/app_search_bar.dart';

class AppHomeHeader extends StatelessWidget {

  //══════════════════════════════════════════════════════════════
  // CONSTRUCTOR
  //
  // Cabeçalho da Home.
  //
  // Exibe:
  // • Avatar do usuário
  // • Saudação
  // • Nome
  // • Slogan da Home
  //
  // Futuramente poderá exibir a foto do usuário vinda do
  // Firebase Authentication ou Firestore.
  //══════════════════════════════════════════════════════════════

  const AppHomeHeader({
    super.key,
    required this.userName,
    this.onProfileTap,
    this.onSearchChanged,
  });

  //══════════════════════════════════════════════════════════════
  // PROPERTIES
  //══════════════════════════════════════════════════════════════

  final String userName;

  final VoidCallback? onProfileTap;

  final Function(String)? onSearchChanged;

  //══════════════════════════════════════════════════════════════
  // UI

 @override
Widget build(BuildContext context) {

  return Container(

    width: double.infinity,

    decoration: const BoxDecoration(

      color: AppColors.primary,

    ),

    child: SafeArea(

      bottom: false,

      child: Padding(

        padding: const EdgeInsets.fromLTRB(
          20,
          20,
          20,
          24,
        ),

        child: Column(

          children: [

            //------------------------------------------------------
            // Linha Superior
            //------------------------------------------------------

            Row(

              children: [

                //--------------------------------------------------
                // Avatar
                //--------------------------------------------------

                InkWell(

                  onTap: onProfileTap,

                  borderRadius: BorderRadius.circular(30),

                  child: CircleAvatar(

                    radius: 28,

                    backgroundColor: AppColors.white,

                    child: const Icon(

                      Icons.person,

                      color: AppColors.primary,

                      size: 30,

                    ),

                  ),

                ),

                const SizedBox(width: 16),

                //--------------------------------------------------
                // Nome
                //--------------------------------------------------

                Expanded(

                  child: Column(

                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [

                      Text(

                        'Olá,',

                        style: AppTextStyles.body.copyWith(
                          color: AppColors.white,
                        ),

                      ),

                      const SizedBox(height: 2),

                      Text(

                        userName,

                        style: AppTextStyles.heading.copyWith(
                          color: AppColors.white,
                        ),

                      ),

                    ],

                  ),

                ),

              ],

            ),

            const SizedBox(height: 24),

            //------------------------------------------------------
            // Barra de Pesquisa
            //------------------------------------------------------

            AppSearchBar(

              onChanged: onSearchChanged,

            ),

          ],

        ),

      ),

    ),

  );

}

}