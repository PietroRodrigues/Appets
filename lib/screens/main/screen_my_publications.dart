import 'package:flutter/material.dart';

import 'package:appets/models/mock_pets.dart';
import 'package:appets/models/model_pet.dart';
import 'package:appets/screens/pet/screen_pet_details.dart';
import 'package:appets/widgets/main/widget_page_header.dart';
import 'package:appets/widgets/main/widget_pet_card.dart';
import 'package:appets/widgets/main/widget_responsive_pet_grid.dart';
import 'package:appets/widgets/common/feedback/widget_empty_state.dart';

/// ID do usuário logado simulado (será o Auth UID do Firebase).
const _currentUserId = 'user_pietro_001';

/// Tela que exibe as publicações de pets feitas pelo usuário.
///
/// Filtra apenas os pets cujo [Pet.ownerId] corresponde ao
/// usuário logado. Exibe botão de edição nos cards.
class MyPublicationsScreen extends StatelessWidget {
  const MyPublicationsScreen({
    super.key,
    this.onPublish,
  });

  /// Ação do CTA do estado vazio (abre a tela de publicar pet).
  final VoidCallback? onPublish;


  // ACTIONS
  void _searchPublication(String value) { // Em desenvolvimento.
    debugPrint('Buscando publicação: $value');
  }

  void _onFilterPressed(BuildContext context) { // Em desenvolvimento.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Filtro em desenvolvimento')),
    );
  }

  /// Navega para a tela de edição do pet (em desenvolvimento).
  void _editPet(BuildContext context, Pet pet) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Editando: ${pet.name}'),
      ),
    );
  }


  // UI
  @override
  Widget build(BuildContext context) {
    // Filtra apenas pets publicados pelo usuário logado.
    final myPets = mockPets.where((pet) => pet.ownerId == _currentUserId).toList();

    return Column(
      children: [

        // CABEÇALHO COM BUSCA E FILTRO
        AppPageHeader.title(
          title: 'Minhas Publicações',
          description: 'Gerencie seus pets publicados.',
          hintText: 'Buscar nas publicações',
          onSearchChanged: _searchPublication,
          onFilterPressed: () => _onFilterPressed(context),
        ),


        // CONTEÚDO - GRID DE PUBLICAÇÕES
        Expanded(
          child: myPets.isEmpty
              ? AppEmptyState(
                  icon: Icons.pets_outlined,
                  title: 'Nenhuma publicação encontrada',
                  description:
                      'Publique um pet para encontrá-lo aqui.',
                  actionLabel:
                      onPublish != null ? 'Publicar pet' : null,
                  onAction: onPublish,
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    return ResponsivePetGrid(
                      itemCount: myPets.length,
                      itemBuilder: (context, index) {
                        final pet = myPets[index];

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
                          onEdit: () => _editPet(context, pet),
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
