import 'package:appets/screens/main/screen_profile.dart';
import 'package:flutter/material.dart';
import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/models/enums/enum_app_page.dart';
import 'package:appets/widgets/main/widget_page_header.dart';
import 'package:appets/widgets/main/widget_pet_card.dart';
import 'package:appets/widgets/main/widget_responsive_pet_grid.dart';
import 'package:appets/models/mock_pets.dart';
import 'package:appets/screens/main/screen_favorites.dart';
import 'package:appets/screens/main/screen_my_publications.dart';
import 'package:appets/screens/main/screen_publish_pet.dart';
import 'package:appets/screens/pet/screen_pet_details.dart';
import 'package:appets/widgets/common/feedback/widget_empty_state.dart';
import 'package:appets/widgets/common/layout/widget_scaffold.dart';
import 'package:appets/widgets/main/widget_bottom_navigation.dart';

/// Tela inicial do app com lista de pets, busca e navegação inferior.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Aba ativa da navegação inferior.
  AppPage _currentPage = AppPage.home;

  // Atualiza a tela conforme a aba selecionada.
  void _onNavigation(AppPage page) {
    setState(() {
      _currentPage = page;
    });
  }

  // Ações da tela inicial.
  void _searchPet(String value) { // Em desenvolvimento.
    debugPrint('Buscando pet: $value');
  }

  void _onFilterPressed() { // Em desenvolvimento.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Filtro em desenvolvimento')),
    );
  }

  /// Navega para a tela de publicar pet.
  void _openPublishPet() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PublishPetScreen(),
      ),
    );
  }

  Widget _buildHomeContent() {
    return Column(
      children: [
        AppPageHeader.user(
          userName: 'Pietro',
          hintText: 'Buscar meu futuro pet',
          onSearchChanged: _searchPet, // Em desenvolvimento.
          onFilterPressed: _onFilterPressed, // Em desenvolvimento.
        ),
        Expanded(
          child: mockPets.isEmpty // Dados de teste.
              ? const AppEmptyState(
                  icon: Icons.pets_outlined,
                  title: 'Nenhum pet por aqui',
                  description:
                      'Ainda não há pets publicados. Volte mais tarde!',
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    return ResponsivePetGrid(
                      itemCount: mockPets.length, // Dados de teste.
                      itemBuilder: (context, index) {
                        final pet = mockPets[index];

                        return AppPetCard(
                          pet: pet,
                          heroTag: 'pet-image-${pet.id}',
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
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    // IndexedStack preserva o estado e o scroll de cada aba.
    // A ordem dos filhos deve corresponder ao enum AppPage.
    return IndexedStack(
      index: _currentPage.index,
      children: [
        _buildHomeContent(),
        FavoritesScreen(onExplore: () => _onNavigation(AppPage.home)),
        MyPublicationsScreen(onPublish: _openPublishPet),
        const ProfileScreen(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Mostra FAB apenas na aba de Minhas Publicações.
    final showFab = _currentPage == AppPage.myPublications;

    return AppScaffold(
      // Sem resize: o teclado apenas sobrepõe o conteúdo (a busca fica
      // no topo), evitando re-layout das 4 abas a cada frame da animação.
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: AppBottomNavigation(
        currentPage: _currentPage,
        onTap: _onNavigation,
      ),
      floatingActionButton: showFab
          ? FloatingActionButton(
              onPressed: _openPublishPet,
              backgroundColor: ThemeColors.primary,
              foregroundColor: ThemeColors.white,
              elevation: 8,
              child: const Icon(Icons.add, size: 32),
            )
          : null,
      child: _buildBody(),
    );
  }
}
