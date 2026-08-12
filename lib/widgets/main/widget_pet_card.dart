import 'package:flutter/material.dart';

import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/core/theme/theme_text_styles.dart';
import 'package:appets/models/enums/enum_pet_gender.dart';
import 'package:appets/models/model_pet.dart';

/// Card reutilizável para exibir um pet em listas da interface.
class AppPetCard extends StatelessWidget {
  const AppPetCard({
    super.key,
    required this.pet,
    this.onTap,
  });

  final Pet pet;
  final VoidCallback? onTap;

  String get _formattedAge {
    if (pet.age == 1) {
      return '1 ano';
    }

    return '${pet.age} anos';
  }

  String get _formattedGender {
    switch (pet.gender) {
      case AppPetGender.male:
        return 'Macho';

      case AppPetGender.female:
        return 'Fêmea';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      color: AppColors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        onTap: onTap,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final imageHeight = constraints.maxHeight * 0.54;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: imageHeight,
                  width: double.infinity,
                  child: Container(
                    color: AppColors.surface,
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Image.asset(pet.images.first, fit: BoxFit.contain),
                    ),
                  ),
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pet.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.subtitle,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Idade: $_formattedAge',
                          style: AppTextStyles.body.copyWith(fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Gênero: $_formattedGender',
                          style: AppTextStyles.body.copyWith(fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 1),
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
                                pet.city,
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
            );
          },
        ),
      ),
    );
  }
}
