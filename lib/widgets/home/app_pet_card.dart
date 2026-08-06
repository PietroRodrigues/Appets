import 'package:flutter/material.dart';

import 'package:appets/core/theme/app_colors.dart';
import 'package:appets/core/theme/app_text_styles.dart';
import 'package:appets/model/enums/app_pet_gender.dart';

class AppPetCard extends StatelessWidget {

  //══════════════════════════════════════════════════════════════
  // CONSTRUCTOR
  //
  // Card reutilizável para exibir informações de um Pet.
  //══════════════════════════════════════════════════════════════

  const AppPetCard({
    super.key,
    required this.imagePath,
    required this.name,
    required this.age,
    required this.gender,
    required this.city,
    this.onTap,
  });

  //══════════════════════════════════════════════════════════════
  // PROPERTIES
  //══════════════════════════════════════════════════════════════

  final String imagePath;
  final String name;
  final int age;
  final AppPetGender gender;
  final String city;
  final VoidCallback? onTap;

  //══════════════════════════════════════════════════════════════
  // PRIVATE METHODS
  //══════════════════════════════════════════════════════════════

  String get _formattedAge {
    if (age == 1) {
      return '1 ano';
    }

    return '$age anos';
  }

  String get _formattedGender {
    switch (gender) {
      case AppPetGender.male:
        return 'Macho';

      case AppPetGender.female:
        return 'Fêmea';
    }
  }

  //══════════════════════════════════════════════════════════════
  // UI
  //══════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {

    return Card(

      elevation: 3,

      color: AppColors.white,

      clipBehavior: Clip.antiAlias,

      shape: RoundedRectangleBorder(

        borderRadius: BorderRadius.circular(16),

      ),

      child: InkWell(

        onTap: onTap,

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            //====================================================
            // Imagem
            //====================================================

            Expanded(

              flex: 6,

              child: Container(

                width: double.infinity,

                color: AppColors.surface,

                child: Padding(

                  padding: const EdgeInsets.all(8),

                  child: Image.asset(

                    imagePath,

                    fit: BoxFit.contain,

                  ),

                ),

              ),

            ),

            //====================================================
            // Informações
            //====================================================

            Expanded(

              flex: 4,

              child: Padding(

                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),

                child: Column(

                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [

                    //------------------------------------------------
                    // Nome
                    //------------------------------------------------

                    Text(

                      name,

                      maxLines: 1,

                      overflow: TextOverflow.ellipsis,

                      style: AppTextStyles.subtitle,

                    ),

                    const SizedBox(height: 6),

                    //------------------------------------------------
                    // Idade
                    //------------------------------------------------

                    Text(

                      'Idade: $_formattedAge',

                      style: AppTextStyles.body,

                    ),

                    const SizedBox(height: 2),

                    //------------------------------------------------
                    // Gênero
                    //------------------------------------------------

                    Text(

                      'Gênero: $_formattedGender',

                      style: AppTextStyles.body,

                    ),

                    const SizedBox(height: 2),

                    //------------------------------------------------
                    // Cidade
                    //------------------------------------------------

                    Row(

                      children: [

                        const Icon(

                          Icons.location_on_outlined,

                          size: 15,

                          color: AppColors.secondary,

                        ),

                        const SizedBox(width: 3),

                        Expanded(

                          child: Text(

                            city,

                            maxLines: 1,

                            overflow: TextOverflow.ellipsis,

                            style: AppTextStyles.body,

                          ),

                        ),

                      ],

                    ),

                  ],

                ),

              ),

            ),

          ],

        ),

      ),

    );

  }

}     