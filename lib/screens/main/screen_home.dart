import 'package:flutter/material.dart';

import 'package:appets/core/constants/constants_strings.dart';
import 'package:appets/core/navigation/navigation_app.dart';
import 'package:appets/core/services/auth_service.dart';
import 'package:appets/core/services/firestore_service.dart';
import 'package:appets/core/services/pet_service.dart';
import 'package:appets/core/theme/theme_colors.dart';
import 'package:appets/models/enums/enums_app.dart';
import 'package:appets/models/model_pet.dart';
import 'package:appets/models/user_model.dart';
import 'package:appets/screens/main/screen_favorites.dart';
import 'package:appets/screens/main/screen_my_publications.dart';
import 'package:appets/screens/main/screen_profile.dart';
import 'package:appets/screens/main/screen_publish_pet.dart';
import 'package:appets/screens/pet/screen_pet_details.dart';
import 'package:appets/widgets/common/feedback/widget_empty_state.dart';
import 'package:appets/widgets/common/feedback/widget_page_loading.dart';
import 'package:appets/widgets/common/feedback/widget_snack_bar.dart';
import 'package:appets/widgets/common/layout/widget_layout.dart';
import 'package:appets/widgets/main/widget_bottom_navigation.dart';
import 'package:appets/widgets/main/widget_page_header.dart';
import 'package:appets/widgets/main/widget_pet_card.dart';
import 'package:appets/widgets/main/widget_responsive_pet_grid.dart';

/// Tela inicial do app com lista de pets, busca e navegação inferior.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Pet> _pets = [];
  bool _isLoading = true;
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    AppNavigation.selectedPage.value = AppPage.home;
    _loadData();
  }

  // Carrega os dados do usuário e a lista de pets do servidor.
  Future<void> _loadData() async {
    final authUser = AuthService().currentUser;
    if (authUser != null) {
      _user = await FirestoreService().getUser(authUser.uid);
    }
    final pets = await PetService().getAllPets();
    if (mounted) {
      setState(() {
        _pets = pets;
        _isLoading = false;
      });
    }
  }

  // Fonte única de verdade da aba ativa: AppNavigation.selectedPage.

  // Atualiza a aba selecionada na navegação.
  void _onNavigation(AppPage page) {
    AppNavigation.selectedPage.value = page;
  }

  // Ações da tela inicial.

  /// Busca pets pelo termo digitado (em desenvolvimento).
  void _searchPet(String value) {
    debugPrint('Buscando pet: $value');
  }

  /// Exibe aviso de que o filtro está em desenvolvimento.
  void _onFilterPressed() {
    AppSnackBar.development(context, AppStrings.filters);
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

  // Monta o conteúdo da aba inicial (loading, vazio ou grade de pets).
  Widget _buildHomeContent() {
    if (_isLoading) {
      return AppPageLoading(
        userName: _user?.name ?? AppStrings.defaultUserName,
      );
    }

    return Column(
      children: [
        AppPageHeader.user(
          userName: _user?.name ?? AppStrings.defaultUserName,
          hintText: AppStrings.searchDefaultHint,
          onSearchChanged: _searchPet,
          onFilterPressed: _onFilterPressed,
        ),
        Expanded(
          child: _pets.isEmpty
              ? AppEmptyState(
                  icon: Icons.pets_outlined,
                  title: AppStrings.emptyPetsTitle,
                  description: AppStrings.emptyPetsDescription,
                  actionLabel: AppStrings.emptyPetsAction,
                  onAction: _openPublishPet,
                )
              : AppResponsivePetGrid(
                  itemCount: _pets.length,
                  itemBuilder: (context, index) {
                    final pet = _pets[index];

                    return AppPetCard(
                      pet: pet,
                      heroTag: 'pet-image-${pet.id}',
                      initialIsFavorited:
                          _user?.favoritePetIds.contains(pet.id) ?? false,
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

  // Monta a pilha de abas preservando o estado de cada uma.
  Widget _buildBody(AppPage currentPage) {
    // IndexedStack preserva o estado e o scroll de cada aba.
    // A ordem dos filhos deve corresponder ao enum AppPage.
    return IndexedStack(
      index: currentPage.index,
      children: [
        _buildHomeContent(),
        FavoritesScreen(onExplore: () => _onNavigation(AppPage.home)),
        MyPublicationsScreen(onPublish: _openPublishPet),
        const ProfileScreen(),
      ],
    );
  }

  // Constrói a tela com navegação inferior e FAB contextual.
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppPage>(
      valueListenable: AppNavigation.selectedPage,
      builder: (context, currentPage, _) {
        // Mostra FAB apenas na aba de Minhas Publicações.
        final showFab = currentPage == AppPage.myPublications;

        return AppScaffold(
          // Sem resize: o teclado apenas sobrepõe o conteúdo (a busca fica
          // no topo), evitando re-layout das 4 abas a cada frame da animação.
          resizeToAvoidBottomInset: false,
          bottomNavigationBar: AppBottomNavigation(
            currentPage: currentPage,
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
          child: _buildBody(currentPage),
        );
      },
    );
  }
}
