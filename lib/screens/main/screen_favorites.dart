import 'package:flutter/material.dart';

import 'package:appets/models/mock_pets.dart';
import 'package:appets/widgets/main/widget_pet_card.dart';
import 'package:appets/widgets/main/widget_page_header.dart';
import 'package:appets/screens/pet/screen_pet_details.dart';
import 'package:appets/widgets/common/feedback/widget_empty_state.dart';

/// Tela que reúne os pets favoritos do usuário.
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({
    super.key,
    this.onExplore,
  });

  /// Ação do CTA do estado vazio (volta para a aba inicial).
  final VoidCallback? onExplore;

  void _searchFavorite(String value) { // Em desenvolvimento.
    debugPrint('Buscando favorito: $value');
  }

  void _onFilterPressed(BuildContext context) { // Em desenvolvimento.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Filtro em desenvolvimento')),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Column(

      children: [
        AppPageHeader.title(
          title: 'Meus favoritos',
          hintText: 'Buscar nos favoritos',
          onSearchChanged: _searchFavorite, // Em desenvolvimento.
          onFilterPressed: () => _onFilterPressed(context), // Em desenvolvimento.
        ),

        Expanded(

          // Temporário até termos o sistema de favoritos.
          child: mockPets.isEmpty
              ? AppEmptyState(
                  icon: Icons.star_border_rounded,
                  title: 'Nenhum favorito ainda',
                  description:
                      'Toque na estrela de um pet para salvá-lo aqui.',
                  actionLabel:
                      onExplore != null ? 'Explorar pets' : null,
                  onAction: onExplore,
                )
              : LayoutBuilder(

            builder: (context, constraints) {

              final width = constraints.maxWidth;

              final crossAxisCount =
                  width < 320 ? 1 :
                  width < 700 ? 2 :
                  3;

              final childAspectRatio =
                  width < 320
                  ? 0.84
                  : width < 700
                  ? 0.68
                  : 0.74;

              return Padding(

                padding: EdgeInsets.symmetric(

                  horizontal: width < 320 ? 10 : 14,

                  vertical: width < 320 ? 10 : 16,

                ),

                child: GridView.builder(
                  padding: const EdgeInsets.only(bottom: 120),

                  itemCount: mockPets.length, // Dados de teste.

                  gridDelegate:
                      SliverGridDelegateWithFixedCrossAxisCount(

                    crossAxisCount: crossAxisCount,

                    crossAxisSpacing:
                        width < 320 ? 8 : 12,

                    mainAxisSpacing:
                        width < 320 ? 8 : 12,

                    childAspectRatio: childAspectRatio,

                  ),

                  itemBuilder: (context, index) {

                    final pet = mockPets[index];

                    return AppPetCard(
                      pet: pet,

                      onTap: () {

                        Navigator.push(

                          context,

                          MaterialPageRoute(

                            builder: (_) =>
                                PetDetailsScreen(pet: pet),

                          ),

                        );

                      },

                    );

                  },

                ),

              );

            },

          ),

        ),

      ],

    );

  }

}
