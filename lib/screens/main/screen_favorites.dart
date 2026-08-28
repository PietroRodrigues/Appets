import 'package:flutter/material.dart';

import 'package:appets/core/constants/constants_strings.dart';
import 'package:appets/core/services/pet_service.dart';
import 'package:appets/models/model_pet.dart';
import 'package:appets/screens/pet/screen_pet_details.dart';
import 'package:appets/widgets/common/feedback/widget_empty_state.dart';
import 'package:appets/widgets/common/feedback/widget_page_loading.dart';
import 'package:appets/widgets/common/feedback/widget_snack_bar.dart';
import 'package:appets/widgets/main/widget_page_header.dart';
import 'package:appets/widgets/main/widget_pet_card.dart';
import 'package:appets/widgets/main/widget_responsive_pet_grid.dart';

/// Tela que reúne os pets favoritos do usuário.
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({
    super.key,
    this.onExplore,
  });

  /// Ação do CTA do estado vazio (volta para a aba inicial).
  final VoidCallback? onExplore;

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Pet> _favoritePets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    // Por enquanto, mostra todos os pets como favoritos.
    // TODO: Implementar sistema real de favoritos no Firestore.
    final pets = await PetService().getAllPets();
    if (mounted) {
      setState(() {
        _favoritePets = pets;
        _isLoading = false;
      });
    }
  }

  /// Busca um pet nos favoritos pelo termo digitado (em desenvolvimento).
  void _searchFavorite(String value) {
    debugPrint('Buscando favorito: $value');
  }

  /// Exibe aviso de que o filtro está em desenvolvimento.
  void _onFilterPressed() {
    AppSnackBar.development(context, AppStrings.filters);
  }

  // Constrói a tela de favoritos (loading, vazio ou grade).
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const AppPageLoading(title: AppStrings.favoritesTitle);
    }

    return Column(
      children: [
        AppPageHeader.title(
          title: AppStrings.favoritesTitle,
          hintText: AppStrings.favoritesSearchHint,
          onSearchChanged: _searchFavorite,
          onFilterPressed: _onFilterPressed,
        ),

        Expanded(
          child: _favoritePets.isEmpty
              ? AppEmptyState(
                  icon: Icons.star_border_rounded,
                  title: AppStrings.emptyFavoritesTitle,
                  description: AppStrings.emptyFavoritesDescription,
                  actionLabel:
                      widget.onExplore != null ? AppStrings.explorePets : null,
                  onAction: widget.onExplore,
                )
              : AppResponsivePetGrid(
                  itemCount: _favoritePets.length,
                  itemBuilder: (context, index) {
                    final pet = _favoritePets[index];

                    return AppPetCard(
                      pet: pet,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PetDetailsScreen(pet: pet),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}
