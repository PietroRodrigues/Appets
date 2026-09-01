import 'package:flutter/material.dart';

import 'package:appets/core/constants/constants_strings.dart';
import 'package:appets/core/services/auth_service.dart';
import 'package:appets/core/services/favorites_service.dart';
import 'package:appets/core/services/firestore_service.dart';
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
  bool _isOrphanCleaning = false;

  // Evita re-consultas disparadas pela própria notificação da limpeza de
  // órfãos enquanto ela já está em andamento.
  bool _isApplyingCleanup = false;

  @override
  void initState() {
    super.initState();
    FavoritesService.instance.favoriteIds.addListener(_reload);
    _loadFavorites();
  }

  @override
  void dispose() {
    FavoritesService.instance.favoriteIds.removeListener(_reload);
    super.dispose();
  }

  // Reage à fonte global de favoritos (favoritar/remover em qualquer tela).
  void _reload() {
    // Ignora as notificações internas da limpeza de órfãos para evitar
    // consultas redundantes e race conditions.
    if (_isApplyingCleanup) return;
    if (mounted) _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    // Ignora re-entrância durante a própria limpeza de órfãos.
    if (_isApplyingCleanup) return;

    final authUser = AuthService().currentUser;
    if (authUser == null) {
      if (mounted) {
        setState(() {
          _favoritePets = [];
          _isLoading = false;
        });
      }
      return;
    }

    final petIds = FavoritesService.instance.current.toList();
    if (petIds.isEmpty) {
      if (mounted) {
        setState(() {
          _favoritePets = [];
          _isLoading = false;
        });
      }
      return;
    }

    // Limpeza lazy de órfãos (pets deletados): apenas para o usuário atual.
    if (!_isOrphanCleaning) {
      _isOrphanCleaning = true;
      try {
        final existing = await PetService().getFavoritePets(petIds);
        final existingIds = existing.map((p) => p.id).toSet();
        final orphans =
            petIds.where((id) => !existingIds.contains(id)).toList();

        if (orphans.isNotEmpty) {
          // Remove do Firestore e, em seguida, da fonte local em uma única
          // notificação (guarda ativa para ignorar a própria notificação).
          for (final orphan in orphans) {
            await FirestoreService().removeFavorite(authUser.uid, orphan);
          }
          _isApplyingCleanup = true;
          try {
            FavoritesService.instance.removeLocalMany(orphans);
          } finally {
            _isApplyingCleanup = false;
          }
        }

        if (!mounted) return;
        setState(() {
          _favoritePets = existing;
          _isLoading = false;
        });
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        AppSnackBar.show(context, AppStrings.favoritesLoadError);
      } finally {
        _isOrphanCleaning = false;
      }
      return;
    }

    try {
      final pets = await PetService().getFavoritePets(petIds);
      if (mounted) {
        setState(() {
          _favoritePets = pets;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        AppSnackBar.show(context, AppStrings.favoritesLoadError);
      }
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
          child: RefreshIndicator(
            onRefresh: _loadFavorites,
            child: _favoritePets.isEmpty
                ? _refreshableEmptyState()
                : AppResponsivePetGrid(
                    physics: const AlwaysScrollableScrollPhysics(),
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
        ),
      ],
    );
  }

  // Estado vazio dentro de um scrollable para permitir o pull-to-refresh
  // mesmo sem itens na lista.
  Widget _refreshableEmptyState() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: AppEmptyState(
                icon: Icons.star_border_rounded,
                title: AppStrings.emptyFavoritesTitle,
                description: AppStrings.emptyFavoritesDescription,
                actionLabel:
                    widget.onExplore != null ? AppStrings.explorePets : null,
                onAction: widget.onExplore,
              ),
            ),
          ),
        );
      },
    );
  }
}
