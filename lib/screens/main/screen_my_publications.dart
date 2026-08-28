import 'package:flutter/material.dart';

import 'package:appets/core/constants/constants_strings.dart';
import 'package:appets/core/services/auth_service.dart';
import 'package:appets/core/services/pet_service.dart';
import 'package:appets/models/model_pet.dart';
import 'package:appets/screens/pet/screen_pet_details.dart';
import 'package:appets/widgets/common/feedback/widget_empty_state.dart';
import 'package:appets/widgets/common/feedback/widget_page_loading.dart';
import 'package:appets/widgets/common/feedback/widget_snack_bar.dart';
import 'package:appets/widgets/main/widget_page_header.dart';
import 'package:appets/widgets/main/widget_pet_card.dart';
import 'package:appets/widgets/main/widget_responsive_pet_grid.dart';

/// Tela que exibe as publicações de pets feitas pelo usuário.
///
/// Filtra apenas os pets cujo [Pet.ownerId] corresponde ao
/// usuário logado. Exibe botão de edição nos cards.
class MyPublicationsScreen extends StatefulWidget {
  const MyPublicationsScreen({
    super.key,
    this.onPublish,
  });

  /// Ação do CTA do estado vazio (abre a tela de publicar pet).
  final VoidCallback? onPublish;

  @override
  State<MyPublicationsScreen> createState() => _MyPublicationsScreenState();
}

class _MyPublicationsScreenState extends State<MyPublicationsScreen> {
  List<Pet> _myPets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMyPets();
  }

  // Carrega os pets publicados pelo usuário logado.
  Future<void> _loadMyPets() async {
    final user = AuthService().currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }
    final pets = await PetService().getPetsByOwner(user.uid);
    if (mounted) {
      setState(() {
        _myPets = pets;
        _isLoading = false;
      });
    }
  }

  // ACTIONS

  /// Busca uma publicação pelo termo digitado (em desenvolvimento).
  void _searchPublication(String value) {
    debugPrint('Buscando publicação: $value');
  }

  /// Exibe aviso de que o filtro está em desenvolvimento.
  void _onFilterPressed() {
    AppSnackBar.development(context, AppStrings.filters);
  }

  /// Navega para a tela de edição do pet (em desenvolvimento).
  void _editPet(Pet pet) {
    AppSnackBar.show(context, AppStrings.editingPet(pet.name));
  }

  // UI

  // Constrói a tela de publicações (loading, vazio ou grade).
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const AppPageLoading(title: AppStrings.myPublicationsTitle);
    }

    return Column(
      children: [

        // CABEÇALHO COM BUSCA E FILTRO
        AppPageHeader.title(
          title: AppStrings.myPublicationsTitle,
          description: AppStrings.myPublicationsDescription,
          hintText: AppStrings.publicationsSearchHint,
          onSearchChanged: _searchPublication,
          onFilterPressed: _onFilterPressed,
        ),

        // CONTEÚDO - GRID DE PUBLICAÇÕES
        Expanded(
          child: _myPets.isEmpty
              ? AppEmptyState(
                  icon: Icons.pets_outlined,
                  title: AppStrings.emptyPublicationsTitle,
                  description: AppStrings.emptyPublicationsDescription,
                  actionLabel:
                      widget.onPublish != null ? AppStrings.publishPet : null,
                  onAction: widget.onPublish,
                )
              : AppResponsivePetGrid(
                  itemCount: _myPets.length,
                  itemBuilder: (context, index) {
                    final pet = _myPets[index];

                    return AppPetCard(
                      pet: pet,
                      isMyPublication: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PetDetailsScreen(pet: pet),
                          ),
                        );
                      },
                      onEdit: () => _editPet(pet),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
